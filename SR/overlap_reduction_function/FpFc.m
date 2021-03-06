function [Fp, Fc] = FpFc(f, theta, phi, psi, u, v, T, ...
                         michelson, fabryperot, isBar)

% calculates Fp = d^ab ep_ab, Fc = d^ab ec_ab for an interferometer
% including fabry-perot response
%
% Inputs:
%   f: GW frequency (Hz)
%   theta, phi: source location spherical polar angles (radians)
%              (theta, phi define unit vector n pting toward source; 
%               wave propagates in opposite direction k = -n) 
%   psi: polarisation angle
%   u, v: unit vectors pointing along interferometer arms
%   T: light-travel time down the two arms (assumed equal)  
%   michelson: 'lw', '1st', 'exact' (michelson response)
%   fabryperot: 'id', 'cp', 'fp', 'phaseP', 'phaseM' (fabry-perot response)
%   isBar: flag for bar detector 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try, isBar; catch, isBar=false; end;

% frequency -> laplace transform variable s
w = 2 * pi * f;
s = i * w;

% rotate unit vectors along detector arms into source frame
R = Rz(psi) * Ry(theta) * Rz(phi);
u = R * u;
v = R * v;

ux = u(1);
uy = u(2);
uz = u(3); % note: uz = u.n = - u.k

vx = v(1);
vy = v(2);
vz = v(3); % note: vz = v.n = - v.k

% initialise variables
Au = zeros(size(f));
Av = zeros(size(f));
Bu = zeros(size(f));
Bv = zeros(size(f));
Tu = zeros(size(f));
Tv = zeros(size(f));
Fp = zeros(size(f));
Fc = zeros(size(f));

% calculate michelson response function
switch michelson

  case 'lw' 
    % ignoring phase
    Tu = ones(size(f));
    Tv = ones(size(f));

    % including phase
    %Tu = exp(-s*T);
    %Tv = exp(-s*T);

  case '1st' 
    % ignoring phase
    Tu = 1 + s * T * uz/2;
    Tv = 1 + s * T * vz/2;

    % including phase
    %Tu = 1 - s * T * (1 - uz/2);
    %Tv = 1 - s * T * (1 - vz/2);
    %Tu = exp(-s*T) .* (1 + s * T * uz/2);
    %Tv = exp(-s*T) .* (1 + s * T * vz/2);

  case 'exact' 
    Au =  sinch( s * T * (1 - uz));
    Bu = -sinch(-s * T * (1 + uz));
    Av =  sinch( s * T * (1 - vz));
    Bv = -sinch(-s * T * (1 + vz));

    Tu = (Au - Bu .* exp(-2 * s * T))/2;
    Tv = (Av - Bv .* exp(-2 * s * T))/2;

    % equivalent calculation 
    % note sinc(x)=sin(pi*x)/pi*x
    %Au = exp( s*T*(1 + uz)/2) .* sinc(f*T*(1 - uz));
    %Bu = exp(-s*T*(1 - uz)/2) .* sinc(f*T*(1 + uz));
    %Av = exp( s*T*(1 + vz)/2) .* sinc(f*T*(1 - vz));
    %Bv = exp(-s*T*(1 - vz)/2) .* sinc(f*T*(1 + vz));
    %Tu = exp(-s*T) .* (Au + Bu)/2;
    %Tv = exp(-s*T) .* (Av + Bv)/2;

  otherwise
    error('unrecognized method');

end

% calculate fabry-perot response function
switch fabryperot

  case 'id'
    H_fabryperot = ones(size(f));

  case 'cp'
    q0 = 0.98584073941991; % taken from malik's param.m file
    fcav = (1-q0)/q0 * 1/(4*pi*T);
    H_fabryperot = 1./(1+ s/(2*pi*fcav));

  case 'fp'
    % include the Fabry-Perot effect
    q0 = 0.98584073941991; % taken from malik's param.m file
    H_fabryperot = (1 - q0)./(1 - q0 * exp(-2 * s * T));

  case 'phaseP'
    H_fabryperot = exp(s*T);

  case 'phaseM'
    H_fabryperot = exp(-s*T);

  otherwise
    error('unrecognized choice of fabry-perot response');

end

% contract polarisation tensors with detector tensor
% calculate Fp = (1/2)(Tu u^a u^b - Tv v^a v^b) ep_ab * H_fabryperot 
uuep = ux.^2 - uy.^2;
vvep = vx.^2 - vy.^2;
if isBar
  Fp = Tu .* uuep .* H_fabryperot;
else
  Fp = (1/2) * (Tu .* uuep - Tv .* vvep) .* H_fabryperot;
end

% calculate Fc = (1/2)(Tu u^a u^b - Tv v^a v^b) ec_ab * H_fabryperot
uuec = 2*ux.*uy;
vvec = 2*vx.*vy;
if isBar
  Fc = Tu .* uuec .* H_fabryperot;
else
  Fc = (1/2) * (Tu .* uuec - Tv .* vvec) .* H_fabryperot;
end

return

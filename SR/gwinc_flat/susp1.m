function noise = susp1(varargin)

% v 1.00   G. Gonzalez, 3/30/00
% v 1.01   R. Adhikari, 8/21/03 (cosmetic changes)
% v 1.02   R. Adhikari, 2/23/04 added 'd' as a varargin
% v 1.03   P. Fritschel, 9/7/05, thermoelastic damping loss added 
%                        to the complex Young's modulus
% v 1.1    R. Adhikari, 12/30/08, ported into susp1.m for use in GWINC
%                                 also gives STRAIN noise for 4 masses
%
% Thermal noise of a pendulum suspended by two wires
% as a function of vector frequency f in Hertz.
%
% file MirrorParams.m should have all parameters 
% TNx = sqrt(psd) of center of mass in (strain)/rtHz

  
d = 0;                           % Default beam position is centered

% Parsing input commands
if nargin < 2
   error('Must specify mirror parameters.')
elseif nargin > 1
   f = varargin{1};
   ifo = varargin{2};
   if nargin == 3
       d = varargin{3};
   end
elseif nargin > 3
    error('Too many input parameters. Read the help.')
end

eval('SOSparameters');

w = 2 * pi * f(:);
kb = ifo.Constants.kB;		        % Boltzmann constant
Tb = ifo.Constants.Temp;				% Room temperature


sigma = rhow*c*(2*r)^2/(13.55*kappa);
% thermoelastic damping factor
phite = E*alphate^2*Tb/(rhow*c)*(sigma.*w)./(1+(sigma.*w).^2);

% complex Young's modulus
Ecomplex = E*(1 + i*phiw + i*phite);
EI = Ecomplex*I;  % factor used in formulas   
sqt = sqrt(T^2 + 4 * EI * rho .* w.^2);
k = sqrt(-T + sqt) ./ sqrt(2 * EI);
ke = sqrt(T + sqt) ./ sqrt(2 * EI);

Delta = 1./ke;
D = (1-(k.*Delta).^2).*sin(k*L)-2*(k.*Delta).*cos(k*L);
Kxx = 2*T*k.*(1+(k.*Delta ).^2).*(cos(k*L)+k.*Delta.*sin(k*L))./D;
Kxt = Kxx.*(h+Delta);
Ktx = Kxt+2*T.*(k.*Delta).^2;
Ktt = 2*T*(h+Delta) .* (1+(k.*Delta).^2).*...
              ((1+k.^2*h.*Delta) .* sin(k*L) + k .* (h-Delta).*cos(k*L))./D;     


% matrix determinant
Det = (Kxx - M * w.^2) .* (Ktt-J*w.^2) - Kxt .* Ktx;
Num = (Ktt - J * w.^2) - d * (Kxt + Ktx) + d.^2 * (Kxx - M * w.^2);

% displacement thermal noise
Yxx = i*w.*Num./Det;
TNx = sqrt(4*kb*Tb*real(Yxx)./(w.^2));

% single mass m/rHz -> strain^2/Hz for 4 masses
noise = 4 * (TNx/ifo.Infrastructure.Length).^2;

% Assigns output variables
if nargout == 0
  loglog(f,TNx,'b')
  grid
  xlabel('Frequency [Hz]')
  ylabel('[m/\surdHz]')
  title('Single Mirror Pendulum Thermal Noise')
  legend('Piston')

elseif nargout > 1
  error('Too many output arguments. Think small.')
  
else
  varargout{1} = noise;
end

return




% References:
% 
% 1) Gonzalez & Saulson, Journal of the Acoustical Society of America
%    96, 207 (1994) -- This one is not on the web and is a pain to find,
%                      but its a very clear description of the idea.
%
% 2) Gabriela Gonzalez, Suspension Thermal Noise in LIGO,
%    gr-qc/0006053 - June 30, 2000 -- All the formulas and all the details. 
%
% 3) Braginsky & Levin, How to reduce SUS Thermal Noise,
%    Meas. Sci. Tech., 10 (1999) 598-606  --
%    Talks about the idea of decentering the beam to reduce the
%    thermal noise by canceling some POS with some PITCH
%


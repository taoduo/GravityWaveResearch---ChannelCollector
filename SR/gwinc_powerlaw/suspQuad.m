% [hForce, vForce, hTable, vTable, Ah, Av] = suspQuad(f, ifo)
%   Quadruple pendulum
%    
% f = frequency vector
% ifo = IFO model
%
% hForce, vForce = transfer functions from the force on the TM to TM motion
%   these should have the correct losses for the mechanical system such
%   that the thermal noise is
% dxdF = force on TM along beam line to position of TM along beam line
%      = hForce + theta^2 * vForce
%      = admittance / (i * w)
% where theta = ifo.Suspension.VHCoupling.theta.
% Since this is just suspension thermal noise, the TM internal
% modes and coating properties should not be included.
%
% hTable, vTable = TFs from support motion to TM motion
%
% Ah = horizontal equations of motion
% Av = vertical equations of motion
%
% === Changes with respect to previous version ===
% [mevans Jun3 2015]
%
% 1) tapered geometry now supported (ifo.Suspension.FiberType = 2)
%    Set ifo.Suspension.Fiber.EndRadius to set the radius of the fibers
%    near the ends (used for thermal noise calculation).
%    Set ifo.Suspension.Fiber.EndLength to set the length of the thick
%    part near the ends (used for bounce mode calculation).
% 2) wire material and blade material specification supported
%    ifo.Suspension.Stage.WireMaterial and .BladeMaterial
%    can be a string matching a field in ifo.Suspension (e.g., 'C70Steel')
%    or a struct with the necessary material parameters (Rho, K, C, etc.).
% 3) 

function [hForce, vForce, hTable, vTable, Ah, Av] = suspQuad(f, ifo)

  % Assign Physical Constants
  g         = ifo.Constants.g;

  % extract suspension parameters
  sus = ifo.Suspension;
  
  % Fiber Type (bottom stage) - round, ribbon, or tapered (0, 1, 2)
  if isfield(sus, 'FiberType')
    FiberType = sus.FiberType;
  elseif isnumeric(sus.Type)
    FiberType = sus.Type;
  elseif isfield(sus.Fiber, 'EndRadius')
    FiberType = 2;   % tapered
  else
    warning('Using default round fibers, with no taper (type 0)')
    FiberType = 0;
  end

  ds_w  = sus.Silica.Dissdepth;  % surface loss dissipation depth

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Parameter Assignment
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % NOTE: For historical reasons, the IFO struct numbers stages
  %       from the bottom up (i.e., 1 is the TM), while this
  %       code numbers them from the top down (i.e., 4 is the TM).

  dil0 = nan(1, 4);
  
  for n = 1:4
    % suspension state parameters
    stage = sus.Stage(5 - n);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % main suspension parameters
    mass(n) = stage.Mass;
    len(n)  = stage.Length;
    if isfield(stage, 'Dilution') 
      dil0(n)  = stage.Dilution;
    end
    kv0(n)  = stage.K;       % N/m, vert. spring constant (from blade)

    r_w(n)= stage.WireRadius;
    if n == 4 && isnan(r_w(n))
      if isfield(stage, 'FiberRadius')
        r_w(n) = stage.FiberRadius;
      elseif FiberType == 1
        r_w(n) = sus.Ribbon.Width;  % ribbon, this is not used
      else
        r_w(n) = sus.Fiber.Radius;
      end
    end
    t_b(n) = stage.Blade;   % blade thickness?
    N_w(n) = stage.NWires;  % number of support wires

    if isfield(stage, 'Temp') && ~isempty(stage.Temp)
      Temp(n) = stage.Temp;  % stage temperature
    else
      Temp(n) = sus.Temp;    % use overall suspension temperature
    end
    
    % Fiber Type (bottom stage) - round, ribbon, or tapered = {0, 1, 2}
    %if isfield(stage, 'FiberType')
    %  FiberType(n) = stage.Type;
    %elseif n == 4
    %  FiberType(n) = sus.Type;
    %else
    %  FiberType(n) = 0;  % default to round for upper stages
    %end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % support wire material parameters
    if isfield(stage, 'WireMaterial') && ~isempty(stage.WireMaterial)
      wireMat = stage.WireMaterial;
      if ischar(wireMat)
        wireMat = sus.(wireMat);
      end
    elseif n == 4
      wireMat = sus.Silica;
    else
      wireMat = sus.C70Steel;
    end
    
    % extraction
    alpha_w(n)  = wireMat.Alpha;   % coeff. thermal expansion
    beta_w(n)   = wireMat.dlnEdT;  % temp. dependence Youngs modulus
    rho_w(n)    = wireMat.Rho;     % mass density
    C_w(n)      = wireMat.C;       % heat capacity
    K_w(n)      = wireMat.K;       % W/(m kg)
    Y_w(n)      = wireMat.Y;       % Young's modulus
    phi_w(n)    = wireMat.Phi;     % loss angle

    % surface loss dissipation depth
    if isfield(wireMat, 'Dissdepth') && ~isempty(wireMat.Dissdepth)
      ds_w(n) = wireMat.Dissdepth;
    else
      ds_w(n) = 0;     % ignore surface effects
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % support blade material parameters
    if isfield(stage, 'BladeMaterial') && ~isempty(stage.BladeMaterial)
      bladeMat = stage.BladeMaterial;
      if ischar(bladeMat)
        bladeMat = sus.(bladeMat);
      end
    else
      bladeMat = sus.MaragingSteel;  % n = 4 is not used, so this is fine
    end
    
    % extraction
    alpha_b(n)   = bladeMat.Alpha;   % coeff. thermal expansion
    beta_b(n)    = bladeMat.dlnEdT;  % temp. dependence Youngs modulus
    rho_b(n)     = bladeMat.Rho;     % mass density
    C_b(n)       = bladeMat.C;       % heat capacity
    K_b(n)       = bladeMat.K;       % W/(m kg)
    Y_b(n)       = bladeMat.Y;       % Young's modulus
    phi_b(n)     = bladeMat.Phi;     % loss angle
  end
  
  % weight support by lower stages
  Mg = g * flip(cumsum(flip(mass)));
  
  % Correction for the pendulum restoring force 
  % (fixed by K. Arai Feb. 29, 2012)
  kh0 = Mg ./ len;              % N/m, horiz. spring constant, stage n


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Thermoelastic Calculations for wires and blades
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % wire geometry
  tension = Mg ./ N_w;          % Tension
  xsect = pi * r_w.^2;          % cross-sectional area
  xII = r_w.^4 * pi / 4;        % x-sectional moment of inertia
  mu_h = 4 ./ r_w;              % surface to volume ratio, horizontal
  mu_v = 2 ./ r_w;              % surface to volume ratio, vertical (wire)
  
  % horizontal TE time constant, wires ( WHAT IS THIS CONSTANT 7.37e-2? )
  tau_h = 7.37e-2 * 4 * (rho_w .* C_w .* xsect) ./ (pi * K_w);

  % vertical TE time constant, blades
  tau_v = (rho_b .* C_b .* t_b.^2) ./ (K_b .* pi^2);

  % vertical delta, blades
  delta_v = Y_b .* alpha_b.^2 .* Temp ./ (rho_b .* C_b);

  % deal with ribbon geometry for last stage
  if FiberType == 1
    W   = sus.Ribbon.Width;
    t   = sus.Ribbon.Thickness;
    xsect(4) = W * t;                   % cross-sectional area
    xII(4) = (W * t^3)/12;               % x-sectional moment of inertia
    mu_v(4) = 2 * (W + t) / (W * t);
    mu_h(4) = mu_v(4) * (3 * N_w(4) * W + t) / (N_w(4) * W + t);
    tau_h(4) = (rho_w(4) * C_w(4) * t^2) / (K_w(4) * pi^2);
  end

  % horizontal delta, wires
  delta_h = (alpha_w - tension .* beta_w ./ (xsect .* Y_w)).^2 .* ...
    Y_w .* Temp ./ (rho_w .* C_w);

  % deal with tapered geometry for last stage
  if FiberType == 2
    r_end = sus.Fiber.EndRadius;
    
    % recompute these for
    xsectEnd = pi * r_end^2;      % cross-sectional area (for delta_h)
    xII(4) = pi * r_end^4 / 4;  % x-sectional moment of inertia
    mu_h(4) = 4 ./ r_end;          % surface to volume ratio, horizontal
    
    % use this xsect for thermo-elastic noise
    delta_h(4) = ...
      (alpha_w(4) - tension(4) .* beta_w(4) ./ (xsectEnd .* Y_w(4))).^2 .* ...
      Y_w(4) .* Temp(4) ./ (rho_w(4) .* C_w(4));
  end    

  % bending length, and dilution factors
  d_bend = sqrt(Y_w .* xII ./ tension);
  dil = len ./ d_bend;
  dil(~isnan(dil0)) = dil0(~isnan(dil0));
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Loss Calculations for wires and blades
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % these calculations use the frequency vector
  w = 2 * pi * f;

  for n = 1:4
    % horizontal loss factor, wires
    phih(n, :) = phi_w(n) * (1 + mu_h(n) * ds_w(n)) + ...
      delta_h(n) * tau_h(n) * w ./ (1 + w.^2 * tau_h(n)^2);
    
    % complex spring constant, horizontal
    kh(n, :) = kh0(n) * (1 + 1i * phih(n, :) / dil(n));
    
    % vertical loss factor, blades
    phiv(n, :) = phi_b(n) + ...
      delta_v(n) * tau_v(n) * w ./ (1 + w.^2 * tau_v(n)^2);

    % complex spring constant, vertical
    kv(n, :) = kv0(n) * (1 + 1i * phiv(n, :));		    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%
  % last suspension stage 
  % Equations from "GG" (maybe?)
  %   Suspensions thermal noise in the LIGO gravitational wave detector
  %   Gabriela Gonzalez, Class. Quantum Grav. 17 (2000) 4409?4435
  %
  % Note:
  %  I in GG = xII
  %  rho in GG = rho_w * xsect
  %  delta in GG = d_bend
  %%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%% Vertical (bounce) %%%
  % loss factor, last stage suspension, vertical (no blades)
  phiv(4, :) = phi_w(4) * (1 + mu_v(4) * ds_w(4));

  % vertical Young's modulus
  Y_v  = Y_w(4) * (1 + 1i * phiv(4, :));

  % vertical spring constant, last stage
  k_z = sqrt(rho_w(4) ./ Y_v) .* w;                     % k_z in GG
  kv4 = N_w(4) * xsect(4) * Y_v .* k_z ./ (tan(k_z * len(4)));

  % deal with tapered geometry for last stage
  if FiberType == 2 && isfield(sus.Fiber, 'EndLength')
    l_end = 2 * sus.Fiber.EndLength;
    l_mid = len(4) - l_end;

    kv_mid = N_w(4) * xsect(4) * Y_v .* k_z ./ (tan(k_z * l_mid));
    kv_end = N_w(4) * xsectEnd * Y_v .* k_z ./ (tan(k_z * l_end));
    kv4 = kv_mid .* kv_end ./ (kv_mid + kv_end);
  end  
  
  if isnan(kv0(4))
    kv(4, :) = kv4; % no blades
  else
    kv(4, :) = kv(4, :) .* kv4 ./ (kv(4, :) + kv4); % with blades
  end
  
  %%% Horizontal (pendulum and violins) %%%
  % horizontal Young's modulus
  Y_h  = Y_w(4) * (1 + 1i * phih(4, :));
  
  % simplification factors for later calculations
  ten4 = tension(4);                          % T in GG
  k4 = sqrt(rho_w(4) * xsect(4) / ten4) * w;	% k in GG
  d_bend4 = sqrt(Y_h .* xII(4) ./ ten4);      % complex d_bend(4)
  dk4 = k4 .* d_bend4;

  % simp3a is inherited from the previous version of this suspension
  % thermal noise calculation (part of simp3).
  %
  % I'm not sure where this comes from, but it differs from
  % 1 by less than 1e-6 for frequencies below 100Hz (and less than
  % 1e-3 up to 10kHz).  What's more, the units appear to be wrong.
  % (Missing factor of rho * length?)
  % [mevans June 2015]
  %
  % simp3a = sqrt(1 + d_bend4 .* xsect(4) .* w.^2 / ten4);
  simp3a = 1;

  coskl = simp3a .* cos(k4 * len(4));
  sinkl = sin(k4 * len(4));

  % numerator, horiz spring constant, last stage
  %   numerator of K_xx in eq 9 of GG
  %     = T k (cos(k L) + k delta sin(k L))
  %   for w -> 0, this reduces to N_w * T * k
  kh4num  = N_w(4) * ten4 .* k4 .* simp3a .* ...
    (simp3a.^2 + dk4.^2) .* (coskl + dk4 .* sinkl);
  
  % denominator, horiz spring constant, last stage
  %   D after equation 8 in GG
  %   D = sin(k L) - 2 k delta cos(k L)
  %   for w -> 0, this reduces to k (L - 2 delta)
  kh4den = ((simp3a.^2 - dk4.^2) .* sinkl - 2 * dk4 .* coskl);
  
  % horizontal spring constant, last stage
  %   K_xx in eq 9 of GG
  kh(4, :) = kh4num ./ kh4den;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Equations of motion for the system
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % want TM equations of motion, so index 4
  B = [0 0 0 1]';

  m_list = mass;
  kh_list = kh;
  kv_list = kv;
  
  %m_list=[m1 m2 m3 m4];          % array of the mass
  %kh_list=[kh1; kh2; kh3; kh4];  % array of the horiz spring constants 
  %kv_list=[kv1; kv2; kv3; kv4];  % array of the vert spring constants 

  % Calculate TFs turning on the loss of each stage one by one
  for ii = 1:numel(m_list) % specify the stage to turn on the loss
      
      % horizontal
      k_list = kh_list;
      % only the imaginary part of the specified stage is used.
      k_list = real(k_list) + 1i*imag([k_list(1,:).*(ii==1); k_list(2,:).*(ii==2); k_list(3,:).*(ii==3); k_list(4,:).*(ii==4)]);
      % construct Eq of motion matrix
      Ah = construct_eom_matrix(k_list, m_list, f);
      % calculate TFs
      hForce.singlylossy(ii,:) = calc_transfer_functions(Ah, B, k_list, f);
  
      % vertical
      k_list = kv_list;
      % only the imaginary part of the specified stage is used.
      k_list = real(k_list) + 1i*imag([k_list(1,:).*(ii==1); k_list(2,:).*(ii==2); k_list(3,:).*(ii==3); k_list(4,:).*(ii==4)]);
      % construct Eq of motion matrix
      Av = construct_eom_matrix(k_list, m_list, f);
      % calculate TFs
      vForce.singlylossy(ii,:) = calc_transfer_functions(Av, B, k_list, f);
      
  end  

  % calculate horizontal TFs with all losses on
  Ah = construct_eom_matrix(kh_list, m_list, f);
  [hForce.fullylossy, hTable] = calc_transfer_functions(Ah, B, kh_list, f);
  
  % calculate vertical TFs with all losses on
  Av = construct_eom_matrix(kv_list, m_list, f);
  [vForce.fullylossy, vTable] = calc_transfer_functions(Av, B, kv_list, f);
end

function A = construct_eom_matrix(k, m, f)
  % construct a matrix for eq of motion
  % k is the array for the spring constants
  % f is the freq vector

    w = 2*pi * f;
    
    A = zeros([4,4,numel(f)]);
    for n = 1:3
      % mass and restoring forces (diagonal elements)
      A(n, n, :) = k(n, :) + k(n + 1,:) - m(n) * w.^2;
    
      % couplings to stages above and below
      A(n, n + 1, :) = -k(n + 1, :);
      A(n + 1, n, :) = -k(n + 1, :);
    end
    
    % mass and restoring force of bottom stage
    A(4, 4, :) = k(4, :) - m(4) * w.^2;
end

function [hForce, hTable] = calc_transfer_functions(A, B, k, f)

    X = zeros([numel(B),numel(A(1,1,:))]);

    for j = 1:numel(A(1,1,:));
        X(:,j) = A(:,:,j)\B;
    end

    % transfer function from the force on the TM to TM motion
    hForce     = zeros(size(f));
    hForce(:)  = X(4,:);

    % transfer function from the table motion to TM motion
    hTable     = zeros(size(f));
    hTable(:)  = X(1,:);
    hTable     = hTable .* k(1,:);
end

% [hForce, vForce, hTable, vTable, Ah, Av] = suspQuad(f, ifo)
%   Suspension for quadruple pendulum
%    
% Silica ribbons used in mirror suspension stage; steel in others
% Violin modes included
% Adapted from code by Morag Casey (Matlab) and Geppo Cagnoli (Maple)
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
% modification for the different temperatures between the stages
% K.Arai Mar 1., 2012
%
% possible error found in simp3 (incorrect units?)
%   seems to have little impact...
% M. Evans June 3, 2015

function [hForce, vForce, hTable, vTable, Ah, Av] = suspQuad(f, ifo)

  % Assign Physical Constants
  g         = ifo.Constants.g;
  kB        = ifo.Constants.kB;

  Temp      = ifo.Suspension.Temp;
  if numel(Temp)==1
      Temp = [Temp Temp Temp Temp]; 
      % if only one temp is given, use it for all stages
  end

  alpha_si  = ifo.Suspension.Silica.Alpha;% coeff. thermal expansion
  beta_si   = ifo.Suspension.Silica.dlnEdT; % temp. dependence Youngs modulus
  rho       = ifo.Suspension.Silica.Rho; % mass density
  C         = ifo.Suspension.Silica.C;
  K         = ifo.Suspension.Silica.K;   % W/(m kg)
  ds        = ifo.Suspension.Silica.Dissdepth;  % surface loss dissipation depth

  rho_st    = ifo.Suspension.C70Steel.Rho;
  C_st      = ifo.Suspension.C70Steel.C;
  K_st      = ifo.Suspension.C70Steel.K;
  Y_st      = ifo.Suspension.C70Steel.Y;
  alpha_st  = ifo.Suspension.C70Steel.Alpha;
  beta_st   = ifo.Suspension.C70Steel.dlnEdT;
  phi_steel = ifo.Suspension.C70Steel.Phi;

  rho_m     = ifo.Suspension.MaragingSteel.Rho;
  C_m       = ifo.Suspension.MaragingSteel.C;
  K_m       = ifo.Suspension.MaragingSteel.K;
  Y_m       = ifo.Suspension.MaragingSteel.Y;
  alpha_m   = ifo.Suspension.MaragingSteel.Alpha;
  beta_m    = ifo.Suspension.MaragingSteel.dlnEdT;
  phi_marag = ifo.Suspension.MaragingSteel.Phi;


  % Begin parameter assignment

  % Note that I'm counting stages differently than Morag. Morag's
  % counting is reflected in the variable names in this funcion; my
  % counting is reflected in the index into Stage().
  % Morag's count has stage "n" labeled as 1 and the mirror as stage 4.
  % I'm counting the mirror as stage 1 and proceeding up. The reason
  % for the change is my assumption that th eimplication of referring
  % to stage "n" is that, once you get far enough away from the
  % mirror, you might have additional stages but not change their
  % characteristics. The simplest implementation of this would be to
  % work through the stages sequenctially, starting from 1, until one
  % reached the end, and then repeat the final stage as many times as
  % desired. What I've done with the reordering is prepare for the
  % day when we might do that.

  theta   = ifo.Suspension.VHCoupling.theta;

  m1      = ifo.Suspension.Stage(4).Mass;
  m2      = ifo.Suspension.Stage(3).Mass;
  m3      = ifo.Suspension.Stage(2).Mass;
  m4      = ifo.Suspension.Stage(1).Mass;

  M1      = m1+m2+m3+m4;          % mass supported by stage n
  M2      = m2+m3+m4;             % mass supported by stage ...
  M3      = m3+m4;                % mass supported by stage ...

  L1      = ifo.Suspension.Stage(4).Length;
  L2      = ifo.Suspension.Stage(3).Length;
  L3      = ifo.Suspension.Stage(2).Length;
  L4      = ifo.Suspension.Stage(1).Length;

  dil1    = ifo.Suspension.Stage(4).Dilution;
  dil2    = ifo.Suspension.Stage(3).Dilution;
  dil3    = ifo.Suspension.Stage(2).Dilution;

  kv10    = ifo.Suspension.Stage(4).K; % N/m, vert. spring constant,
  kv20    = ifo.Suspension.Stage(3).K;
  kv30    = ifo.Suspension.Stage(2).K;
  

  % Correction for the pendulum restoring force 
  % replaced m1->M1, m2->M2, m3->M3 
  % K. Arai Feb. 29, 2012
  kh10    = M1*g/L1;              % N/m, horiz. spring constant, stage n
  kh20    = M2*g/L2;              % N/m, horiz. spring constant, stage 1
  kh30    = M3*g/L3;              % N/m, horiz. spring constant, stage 2
  kh40    = m4*g/L4;              % N/m, horiz. spring constant, last stage

  r_st1   = ifo.Suspension.Stage(4).WireRadius;
  r_st2   = ifo.Suspension.Stage(3).WireRadius;
  r_st3   = ifo.Suspension.Stage(2).WireRadius;

  t_m1    = ifo.Suspension.Stage(4).Blade;
  t_m2    = ifo.Suspension.Stage(3).Blade;
  t_m3    = ifo.Suspension.Stage(2).Blade;

  N1 = ifo.Suspension.Stage(4).NWires;  % number of wires in stage n
  N2 = ifo.Suspension.Stage(3).NWires;  % Number of wires in stage 1
  N3 = ifo.Suspension.Stage(2).NWires;  % Number of wires in stage 1
  N4 = ifo.Suspension.Stage(1).NWires;  % Number of wires in stage 1

  Y_si = ifo.Suspension.Silica.Y;

  if ~isfield(ifo.Suspension, 'FiberType')
    ifo.Suspension.FiberType = ifo.Suspension.Type;
  end
  
  if ifo.Suspension.FiberType == 0
    r_fib = ifo.Suspension.Fiber.Radius;
    xsect = pi*r_fib^2; % cross-sectional area
    II4 = r_fib^4*pi/4; % x-sectional moment of inertia
    mu_v = 2/r_fib;  % mu/(V/S), vertical motion
    mu_h = 4/r_fib;  % mu/(V/S), horizontal motion
    tau_si = 7.372e-2*rho*C*(4*xsect/pi)/K; % TE time constant
  else
    W   = ifo.Suspension.Ribbon.Width;
    t   = ifo.Suspension.Ribbon.Thickness;
    xsect = W * t;
    II4 = (W * t^3)/12;
    mu_v = 2 * (W + t)/(W*t);
    mu_h = (3 * N4 * W + t)/(N4*W + t)*2*(W+t)/(W*t);
    tau_si = (rho*C*t^2)/(K*pi^2);
  end


  % loss factor, last stage suspension, vertical
  phiv4   = ifo.Suspension.Silica.Phi*(1 + mu_v*ds);
  Y_si_v  = Y_si * (1 + 1i * phiv4); 		% Vertical Young's modulus, silica

  T4      = m4*g / N4;              	% Tension in last stage

  % TE time constant, steel wire 1-3
  % WHAT IS THIS CONSTANT 7.37e-2?
  tau_steel1      = 7.37e-2*(rho_st*C_st*(2*r_st1)^2)/K_st;
  tau_steel2      = 7.37e-2*(rho_st*C_st*(2*r_st2)^2)/K_st;
  tau_steel3      = 7.37e-2*(rho_st*C_st*(2*r_st3)^2)/K_st;

  % TE time constant, maraging blade 1
  tau_marag1      = (rho_m*C_m*t_m1^2)/(K_m*pi^2);
  tau_marag2      = (rho_m*C_m*t_m2^2)/(K_m*pi^2);
  tau_marag3      = (rho_m*C_m*t_m3^2)/(K_m*pi^2);

  % vertical delta, maraging
  delta_v1        = Y_m*alpha_m^2*Temp(1)/(rho_m*C_m);
  delta_v2        = delta_v1;
  delta_v3        = delta_v1;

  % horizontal delta, steel, stage n
  delta_h1 = Y_st*(alpha_st-beta_st*g*M1/(N1*pi*r_st1^2*Y_st))^2;
  delta_h1 = delta_h1*Temp(1)/(rho_st*C_st);

  delta_h2 = Y_st*(alpha_st-beta_st*g*M2/(N2*pi*r_st1^2*Y_st))^2;
  delta_h2 = delta_h2*Temp(2)/(rho_st*C_st);

  delta_h3 = Y_st*(alpha_st-beta_st*g*M3/(N3*pi*r_st1^2*Y_st))^2;
  delta_h3 = delta_h3*Temp(3)/(rho_st*C_st);

  % solutions to equations of motion
  B       = [     0       0       0       1]';

  w = 2*pi*f;

  % thermoelastic correction factor, silica
  delta_s = Y_si*(alpha_si-beta_si*T4/(xsect*Y_si))^2*Temp(4)/(rho*C);


  % vertical loss factor, maraging
  phiv1   = phi_marag+delta_v1*tau_marag1*w./(1+w.^2*tau_marag1^2);
  phiv2   = phi_marag+delta_v2*tau_marag2*w./(1+w.^2*tau_marag2^2);
  phiv3   = phi_marag+delta_v3*tau_marag3*w./(1+w.^2*tau_marag3^2);

  % horizontal loss factor, steel, stage n
  phih1   = phi_steel+delta_h1*tau_steel1*w./(1+w.^2*tau_steel1^2);
  phih2   = phi_steel+delta_h2*tau_steel2*w./(1+w.^2*tau_steel2^2);
  phih3   = phi_steel+delta_h3*tau_steel3*w./(1+w.^2*tau_steel3^2);

  kv1     = kv10*(1 + 1i*phiv1);		    % stage n spring constant, vertical
  kv2     = kv20*(1 + 1i*phiv2);		    % stage 1 spring constant, vertical
  kv3     = kv30*(1 + 1i*phiv3);		    % stage 2 spring constant, vertical

  kh1     = kh10*(1 + 1i*phih1/dil1);	% stage n spring constant, horizontal
  kh2     = kh20*(1 + 1i*phih2/dil2);	% stage 1 spring constant, horizontal
  kh3     = kh30*(1 + 1i*phih3/dil3);	% stage 2 spring constant, horizontal

  % loss factor, last stage suspension, horizontal
  phih4   = ifo.Suspension.Silica.Phi*(1 + mu_h * ds) + ...
            delta_s * (tau_si * w./(1 + tau_si^2*w.^2));

  % violin mode calculations
  Y_si_h  = Y_si * (1 + 1i*phih4);		    % Horizontal Young's modulus
  simp1   = sqrt(rho./Y_si_h).*w;	        % simplification factor 1 q
  simp2   = sqrt(rho * xsect *w.^2/T4);	    % simplification factor 2 p

  % simplification factor 3 kk
  %  units problem? (1 + II4 * xsect * Y_si_h .* w.^2 / T4^2)  [mevans]
  simp3   = sqrt(T4 * (1 + II4 * xsect * Y_si_h .* w.^2 / T4^2) ./ (Y_si_h * II4));

  a = simp3 .* cos(simp2 * L4);	        	% simplification factor a
  b = sin(simp2 * L4);		    	        % simplification factor b

  % vertical spring constant, last stage
  kv40 = abs(N4 * Y_si_v * xsect / L4);      % this seems to not be used ??
  kv4 = N4 * Y_si_v * xsect * simp1 ./ (tan(simp1 * L4));
  
  % numerator, horiz spring constant, last stage
  kh4num  = N4*II4*Y_si_h.*simp2.*simp3.*(simp2.^2+simp3.^2).*(a+simp2.*b);
  % denominator, horiz spring constant, last stage
  kh4den  = (2 * simp2 .* a + (simp2.^2 - simp3.^2) .* b);
  % horizontal spring constant, last stage
  kh4     = -kh4num ./ kh4den;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Equations of motion for the system
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  m_list=[m1 m2 m3 m4];          % array of the mass
  kh_list=[kh1; kh2; kh3; kh4];  % array of the horiz spring constants 
  kv_list=[kv1; kv2; kv3; kv4];  % array of the vert spring constants 

  % Calculate TFs turning on the loss of each stage one by one
  for ii=1:numel(m_list) % specify the stage to turn on the loss
      
      % horizontal
      k_list = kh_list;
      % only the imaginary part of the specified stage is used.
      k_list = real(k_list) + 1i*imag([k_list(1,:).*(ii==1); k_list(2,:).*(ii==2); k_list(3,:).*(ii==3); k_list(4,:).*(ii==4)]);
      % construct Eq of motion matrix
      Ah = construct_eom_matrix(k_list, m_list, f);
      % calculate TFs
      [hForce.singlylossy(ii,:), hTable] = calc_transfer_functions(Ah, B, k_list, f);
  
      % vertical
      k_list = kv_list;
      % only the imaginary part of the specified stage is used.
      k_list = real(k_list) + 1i*imag([k_list(1,:).*(ii==1); k_list(2,:).*(ii==2); k_list(3,:).*(ii==3); k_list(4,:).*(ii==4)]);
      % construct Eq of motion matrix
      Av = construct_eom_matrix(k_list, m_list, f);
      % calculate TFs
      [vForce.singlylossy(ii,:), vTable] = calc_transfer_functions(Av, B, k_list, f);
      
  end  

  % horizontal
  k_list=kh_list; % all of the losses are on
  % construct Eq of motion matrix
  Ah = construct_eom_matrix(k_list, m_list, f);
  % calculate TFs
  [hForce.fullylossy, hTable] = calc_transfer_functions(Ah, B, k_list, f);
  
  % vertical
  k_list=kv_list; % all of the losses are on
  % construct Eq of motion matrix
  Av = construct_eom_matrix(k_list, m_list, f);
  % calculate TFs
  [vForce.fullylossy, vTable] = calc_transfer_functions(Av, B, k_list, f);
  
end

function A = construct_eom_matrix(k, m, f)
% construct a matrix for eq of motion
% k is the array for the spring constants
% f is the freq vector

    w = 2*pi * f;

    A = zeros([4,4,numel(f)]);

    A(1,2,:) = -k(2,:); A(2,1,:) = A(1,2,:);
    A(2,3,:) = -k(3,:); A(3,2,:) = A(2,3,:);
    A(3,4,:) = -k(4,:); A(4,3,:) = A(3,4,:);
    A(1,1,:) = k(1,:) + k(2,:) - m(1) * w.^2;
    A(2,2,:) = k(2,:) + k(3,:) - m(2) * w.^2;
    A(3,3,:) = k(3,:) + k(4,:) - m(3) * w.^2;
    A(4,4,:) = k(4,:) - m(4) * w.^2;

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
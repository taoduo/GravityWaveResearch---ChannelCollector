function ifo =IFOModel(varargin)
% IFOMODEL returns a structure describing an IFO for use in
% benchmark programs and noise simulator. Part of the gwinc
% package, which provides science-grounded figures of merit for
% comparing interferometric gravitational wave detector designs. 
% 


% parameters for quad pendulum suspension updated 3rd May 2006, NAR
% References:
% LIGO-T000012-00-D
% 	* Differentiate between silica and sapphire substrate absorption
% 	* Change ribbon suspension aspect ratio
% 	* Change pendulum frequency
% * References:
% * 1. Electro-Optic Handbook, Waynant & Ediger (McGraw-Hill: 1993)
% * 2. LIGO/GEO data/experience
% * 3. Suspension reference design, LIGO-T000012-00
% * 4. Quartz Glass for Optics Data and Properties, Heraeus data sheet,
% *    numbers for suprasil
% * 5. Y.S. Touloukian (ed), Thermophysical Properties of Matter 
% *    (IFI/Plenum,1970)
% * 6. Marvin J. Weber (ed) CRC Handbook of laser science and technology, 
% *    Vol 4, Pt 2
% * 7. R.S. Krishnan et al.,Thermal Expansion of Crystals, Pergamon Press
% * 8. P. Klocek, Handbook of infrared and optical materials, Marcel Decker, 
% *    1991
% * 9. Rai Weiss, electronic log from 5/10/2006
% * 10. Wikipedia online encyclopedia, 2006
% * 11. D.K. Davies, The Generation and Dissipation of Static Charge on
% * dielectrics in a Vacuum, page 29
% * 12. Gretarsson & Harry, Gretarsson thesis
% * 13. Fejer
% * 14. Braginsky


%% Infrastructure----------------------------------------------------------

ifo.Infrastructure.Length                     = 3995;             % m;
ifo.Infrastructure.ResidualGas.pressure       = 4.0e-7;           % Pa;
ifo.Infrastructure.ResidualGas.mass           = 3.34765e-27;      % kg; Mass of the hydrogen molecule (ref. 10) 
ifo.Infrastructure.ResidualGas.polarizability = 7.81917*10^-31 ;  % m^3; Gas polarizability  

%% Physical and other constantMaterialss; All in SI units------------------

ifo.Constants.E0      = 8.8541878176e-12;                 % F / m; Permittivity of Free Space
ifo.Constants.hbar    = 1.054572e-34;                     % J - s; (Plancks constant) / (2 * pi)
ifo.Constants.kB      = 1.380658e-23;                     % J / K; Boltzman Constant
ifo.Constants.h       = ifo.Constants.hbar * 2 * pi;      % J - s; Planks constant
ifo.Constants.R       = 8.31447215;                       % J / (K * mol); Gas Constant
ifo.Constants.m_e     = 9.10938291e-31;                   % kg; electron mass
ifo.Constants.c       = 2.99792458e8;                     % m / s; speed of light in vacuum
ifo.Constants.Temp    = 290;                              % K; Temperature of the Vacuum
ifo.Constants.yr      = 365.2422 * 86400;                 % sec; Seconds in a year
ifo.Constants.M_earth = 5.972e24;                         % mass of Earth [kg]
ifo.Constants.R_earth = 6.3781e6;                         % radius of Earth [m]
ifo.Constants.fs      = 16384;                            % Sampling frequency (Hz)
ifo.Constants.AU      = 149597870700;                     % m; Astronomical unit, IAU 2012 Resolution B2
ifo.Constants.parsec  = ifo.Constants.AU * (648000 / pi); % m, IAU 2015 Resolution B2
ifo.Constants.Mpc     = ifo.Constants.parsec * 1e6;       % m, IAU 2015 Resolution B2
ifo.Constants.SolarMassParameter = 1.3271244e20;          % m^3 / s^2; G * MSol, IAU 2015 Resolution B3
ifo.Constants.G       = 6.67408e-11;                      % m^3 / (kg  s^2); Grav. const
                                                          % http://arxiv.org/abs/1507.07956
ifo.Constants.MSol    = ifo.Constants.SolarMassParameter / ifo.Constants.G; % kg; Solar mass
ifo.Constants.g       = 9.806;                            % m / s^2; grav. acceleration 
                                                          % http://physics.nist.gov/cuu/Constants/ 
ifo.Constants.H0      = 67110;                            % ms^(-1)/Mpc; Hubble const.
                                                          % http://arxiv.org/pdf/1303.5076v3.pdf
ifo.Constants.omegaM  = 0.3175;                           % Mass density parameter 
                                                          % http://arxiv.org/pdf/1303.5076v3.pdf
ifo.Constants.omegaLambda = 1 - ifo.Constants.omegaM;     % Cosmological constant density parameter
                                                          % omegaK = 0 (flat universe) is assumed

%% Laser-------------------------------------------------------------------
ifo.Laser.Wavelength                   = 1.064e-6;                                  % m;
ifo.Laser.Power                        = 125;                                       % W;

%% Optics------------------------------------------------------------------
ifo.Optics.SRM.CavityLength         = 55;      % m; ITM to SRM distance
ifo.Optics.PhotoDetectorEfficiency  = 0.9;     % photo-detector quantum efficiency
ifo.Optics.Loss                     = 37.5e-6; % average per mirror power loss
ifo.Optics.BSLoss  = 2e-3;                   % power loss near beamsplitter
ifo.Optics.coupling = 1.0;                   % mismatch btwn arms & SRC modes; used to
                                               % calculate an effective r_srm                                        
%% Parameter describing thermal lensing --------------------------------------
% The presumably dominant effect of a thermal lens in the ITMs is an increased
% mode mismatch into the SRC, and thus an increased effective loss of the SRC.
% This increase is estimated by calculating the round-trip loss S in the SRC as
% 1-S = |<Psi|exp(i*phi)|Psi>|^2, where
% |Psi> is the beam hitting the ITM and
% phi = P_coat*phi_coat + P_subs*phi_subs
% with phi_coat & phi__subs the specific lensing profiles
% and P_coat & P_subst the power absorbed in coating and substrate
%
% This expression can be expanded to 2nd order and is given by
% S= s_cc P_coat^2 + 2*s_cs*P_coat*P_subst + s_ss*P_subst^2
% s_cc, s_cs and s_ss where calculated analytically by Phil Wilems (4/2007)
ifo.TCS.s_cc=7.024; % Watt^-2
ifo.TCS.s_cs=7.321; % Watt^-2
ifo.TCS.s_ss=7.631; % Watt^-2

% The hardest part to model is how efficient the TCS system is in
% compensating this loss. Thus as a simple Ansatz we define the
% TCS efficiency TCSeff as the reduction in effective power that produces
% a phase distortion. E.g. TCSeff=0.99 means that the compensated distortion
% of 1 Watt absorbed is eqivalent to the uncompensated distortion of 10mWatt.
% The above formula thus becomes:
% S= s_cc P_coat^2 + 2*s_cs*P_coat*P_subst + s_ss*P_subst^2 * (1-TCSeff)^2
%
% To avoid iterative calculation we define TCS.SCRloss = S as an input
% and calculate TCSeff as an output.
% TCS.SRCloss is incorporated as an additional loss in the SRC
ifo.TCS.SRCloss=0.00;


%% Seismic and Gravity Gradient Parameters---------------------------------
ifo.Seismic.darmSeiSusFile = 'seismic.mat';  % .mat file containing predictions for darm displacement
ifo.Seismic.KneeFrequency = 10;                         % Hz; frequency where 'flat' seismic noise rolls off
ifo.Seismic.LowFrequencyLevel = 1e-9;                   % m/rtHz; seismic noise level below f_knee
ifo.Seismic.Gamma = .8;                                 % abruptness of changing between the two part at f_knee
ifo.Seismic.Rho = 1.8e3;                                % kg/m^3; density of the ground near the mirror
ifo.Seismic.Beta = 0.6;                                 % quiet times beta = 0.35-0.60, noisy times beta = 0.15-1.4

%% Suspension: SI Units----------------------------------------------------
ifo.Suspension.BreakStress  = 750e6;           % Pa; ref. K. Strain 
ifo.Suspension.Temp = ifo.Constants.Temp;
%ifo.Suspension.VHCoupling.theta = 1e-3;        % vertical-horizontal x-coupling
%This coupling is computed in precompIFO

ifo.Suspension.Silica.Rho    = 2.2e3;          % Kg/m^3;
ifo.Suspension.Silica.C      = 772;            % J/Kg/K;
ifo.Suspension.Silica.K      = 1.38;           % W/m/kg;
ifo.Suspension.Silica.Alpha  = 3.9e-7;         % 1/K;
ifo.Suspension.Silica.dlnEdT = 1.52e-4;        % (1/K), dlnE/dT 
ifo.Suspension.Silica.Phi    = 4.1e-10;        % from G Harry e-mail to NAR 27April06 dimensionless units
ifo.Suspension.Silica.Y      = 7.2e10;        % Pa; Youngs Modulus
% to match bounce mode [mevans, June 2015]
%ifo.Suspension.Silica.Y      = 7.7e10;        % Pa; Youngs Modulus
ifo.Suspension.Silica.Dissdepth = 1.5e-2;      % from G Harry e-mail to NAR 27April06 

ifo.Suspension.C70Steel.Rho    =  7800;
ifo.Suspension.C70Steel.C      =  486;
ifo.Suspension.C70Steel.K      =  49;
ifo.Suspension.C70Steel.Alpha  =  12e-6;
ifo.Suspension.C70Steel.dlnEdT = -2.5e-4;
ifo.Suspension.C70Steel.Phi    =  2e-4;
ifo.Suspension.C70Steel.Y      = 212e9;        % measured by MB for one set of wires
    
ifo.Suspension.MaragingSteel.Rho = 7800;
ifo.Suspension.MaragingSteel.C   = 460;
ifo.Suspension.MaragingSteel.K   = 20; 
ifo.Suspension.MaragingSteel.Alpha  = 11e-6;
ifo.Suspension.MaragingSteel.dlnEdT = 0;
ifo.Suspension.MaragingSteel.Phi  = 1e-4;
ifo.Suspension.MaragingSteel.Y  = 187e9;       

% new Silicon parameters added for gwincDev   RA  Feb 25, 2012 ~~~~~~~~~~~~~~~~~~~
% http://www.ioffe.ru/SVA/NSM/Semicond/Si/index.html
% all properties should be for T ~ 120 K
ifo.Suspension.Silicon.Rho       = 2329;          % Kg/m^3;  density
ifo.Suspension.Silicon.C         = 300;           % J/kg/K   heat capacity
ifo.Suspension.Silicon.K         = 700;          % W/m/K    thermal conductivity
ifo.Suspension.Silicon.Alpha     = 1e-10;         % 1/K      thermal expansion coeff

% from Gysin, et. al. PRB (2004)  E(T) = E0 - B*T*exp(-T0/T)
% E0 = 167.5e9 Pa   T0 = 317 K   B = 15.8e6 Pa/K
ifo.Suspension.Silicon.dlnEdT    = -2e-5;         % (1/K)    dlnE/dT  T = 120K

ifo.Suspension.Silicon.Phi       = 2e-9;          % Nawrodt (2010)      loss angle  1/Q
ifo.Suspension.Silicon.Y         = 155.8e9;         % Pa       Youngs Modulus
ifo.Suspension.Silicon.Dissdepth = 1.5e-3;        % 10x smaller surface loss depth (Nawrodt (2010))


% 0 for cylindrical suspension
% 1 for ribon suspension
% 2 for tapered cylindrical suspension
ifo.Suspension.Type         = 2;

% Note stage numbering: mirror is at beginning of stack, not end
ifo.Suspension.Stage(1).Mass = 39.6;           % kg; current numbers May 2006 NAR
ifo.Suspension.Stage(2).Mass = 39.6;	
ifo.Suspension.Stage(3).Mass = 21.8;
ifo.Suspension.Stage(4).Mass = 22.1; 

% last stage length adjusted for d = 10mm and and d_bend = 4mm
% (since 602mm is the CoM separation, and d_bend is accounted for
%  in suspQuad, so including it here would double count)
ifo.Suspension.Stage(1).Length = 0.602 - 2e-3 * (10 - 4);  % m; 
ifo.Suspension.Stage(2).Length = 0.341;        % m;
ifo.Suspension.Stage(3).Length = 0.277;        % m;
ifo.Suspension.Stage(4).Length = 0.416;        % m;

ifo.Suspension.Stage(1).K = NaN;               % no blade springs on TM
ifo.Suspension.Stage(2).K = 5200;              % N/m; vertical spring constant
ifo.Suspension.Stage(3).K = 3900;              % N/m; vertical spring constant
ifo.Suspension.Stage(4).K = 3400;              % N/m; vertical spring constant

ifo.Suspension.Stage(1).WireRadius = NaN;   % fiber radius on last stage
ifo.Suspension.Stage(2).WireRadius = 310e-6;   % current numbers May 2006 NAR
ifo.Suspension.Stage(3).WireRadius = 350e-6;
ifo.Suspension.Stage(4).WireRadius = 520e-6;

% For Ribbon suspension
ifo.Suspension.Ribbon.Thickness = 115e-6;      % m;
ifo.Suspension.Ribbon.Width     = 1150e-6;     % m;
ifo.Suspension.Fiber.Radius     = 205e-6;      % m;

% For Tapered Fibers
%  EndRadius is tuned to cancel thermo-elastic noise (delta_h in suspQuad)
%  EndLength is tuned to match bounce mode frequency
ifo.Suspension.Fiber.EndRadius  = 400e-6;      % m; nominal 400um
ifo.Suspension.Fiber.EndLength  = 45e-3;       % m; nominal 20mm

ifo.Suspension.Stage(1).Blade = NaN;            % blade thickness
ifo.Suspension.Stage(2).Blade = 4200e-6;        % current numbers May 2006 NAR
ifo.Suspension.Stage(3).Blade = 4600e-6;
ifo.Suspension.Stage(4).Blade = 4300e-6;

ifo.Suspension.Stage(1).NWires = 4;
ifo.Suspension.Stage(2).NWires = 4;
ifo.Suspension.Stage(3).NWires = 4;
ifo.Suspension.Stage(4).NWires = 2;

%% Dielectric coating material parameters----------------------------------

%% high index material: tantala
ifo.Materials.Coating.Yhighn = 140e9;
ifo.Materials.Coating.Sigmahighn = 0.23; 
ifo.Materials.Coating.CVhighn = 2.1e6;               % Crooks et al, Fejer et al
ifo.Materials.Coating.Alphahighn = 3.6e-6;           % 3.6e-6 Fejer et al, 5e-6 from Braginsky
ifo.Materials.Coating.Betahighn = 1.4e-5;              % dn/dT, value Gretarrson (G070161)
ifo.Materials.Coating.ThermalDiffusivityhighn = 33;  % Fejer et al
ifo.Materials.Coating.Phihighn = 2.3e-4; 
ifo.Materials.Coating.Indexhighn = 2.06539;

%% low index material: silica
ifo.Materials.Coating.Ylown = 72e9;
ifo.Materials.Coating.Sigmalown = 0.17;
ifo.Materials.Coating.CVlown = 1.6412e6;             % Crooks et al, Fejer et al
ifo.Materials.Coating.Alphalown = 5.1e-7;            % Fejer et al
ifo.Materials.Coating.Betalown = 8e-6;             % dn/dT,  (ref. 14)
ifo.Materials.Coating.ThermalDiffusivitylown = 1.38; % Fejer et al
ifo.Materials.Coating.Philown = 4.0e-5;
ifo.Materials.Coating.Indexlown = 1.45;

%%Substrate Material parameters--------------------------------------------

ifo.Materials.Substrate.c2  = 7.6e-12;                 % Coeff of freq depend. term for bulk mechanical loss, 7.15e-12 for Sup2
ifo.Materials.Substrate.MechanicalLossExponent=0.77;   % Exponent for freq dependence of silica loss, 0.822 for Sup2 
ifo.Materials.Substrate.Alphas = 5.2e-12;              % Surface loss limit (ref. 12) 
ifo.Materials.Substrate.MirrorY    = 7.27e10;          % N/m^2; Youngs modulus (ref. 4)
ifo.Materials.Substrate.MirrorSigma = 0.167;           % Kg/m^3; Poisson ratio (ref. 4)
ifo.Materials.Substrate.MassDensity = 2.2e3;           % Kg/m^3; (ref. 4)
ifo.Materials.Substrate.MassAlpha = 3.9e-7;            % 1/K; thermal expansion coeff. (ref. 4)
ifo.Materials.Substrate.MassCM = 739;                  % J/Kg/K; specific heat (ref. 4)
ifo.Materials.Substrate.MassKappa = 1.38;              % J/m/s/K; thermal conductivity (ref. 4) 
ifo.Materials.Substrate.RefractiveIndex = 1.45;        % mevans 25 Apr 2008

ifo.Materials.MassRadius = 0.170;                     % m; Peter F 8/11/2005
ifo.Materials.MassThickness = 0.200;                  % m; Peter F 8/11/2005
    
ifo.Optics.Curvature.ITM = 1970;                      % ROC of ITM
ifo.Optics.Curvature.ETM = 2192;                      % ROC of ETM
ifo.Optics.SubstrateAbsorption = 0.5e-4;              % 1/m; bulk absorption coef (ref. 2)
ifo.Optics.pcrit = 10;                                % W; tolerable heating power (factor 1 ATC)
%ifo.Optics.ITM.BeamRadius = 0.055;       % now computed with L and RoC 
%ifo.Optics.ETM.BeamRadius = 0.062;       % now computed with L and RoC  
ifo.Optics.ITM.CoatingAbsorption = 0.5e-6;            % absorption of ITM 
ifo.Optics.ITM.Transmittance  = 0.014;                % Transmittance of ITM
ifo.Optics.ETM.Transmittance  = 5e-6;                 % Transmittance of ETM 
ifo.Optics.SRM.Transmittance  = 0.2;                 % Transmittance of SRM
ifo.Optics.PRM.Transmittance  = 0.03;

% coating layer optical thicknesses - mevans June 2008
ifo.Optics.ITM.CoatingThicknessLown = 0.308;
ifo.Optics.ITM.CoatingThicknessCap = 0.5;

ifo.Optics.ETM.CoatingThicknessLown = 0.27;
ifo.Optics.ETM.CoatingThicknessCap = 0.5;

%ifo.Optics.SRM.Tunephase = 0.23;           % SRM tuning, 795 Hz narrowband
ifo.Optics.SRM.Tunephase = 0.0;                      % SRM tuning
ifo.Optics.Quadrature.dc = pi/2;                      % demod/detection/homodyne phase


%%%%%%

return

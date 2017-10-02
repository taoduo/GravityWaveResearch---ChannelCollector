function source = SourceModel(varargin);

% SOURCEMODEL returns a structure describing gravity wave sources for use in
% benchmark programs and noise simulator. Part of the gwinc
% package, which provides science-grounded figures of merit for
% comparing interferometric gravitational wave detector designs. 
% 


%% Binary Inspiral

source.BinaryInspiral.minZ              = 0.01;    % Min reasonable z
source.BinaryInspiral.maxZ              = 150;     % Max reasonable z
source.BinaryInspiral.minZ2             = 2.23e-7; % z of ~1kpc
source.BinaryInspiral.maxZ2             = 1091;    % z of the CMB
                                                   % e.g. 1.4 - 1.4 MSol for aLIGO is z~0.1; max Z for CE is z~115
                                                   % These values are used as bounds in a root - finding algorithm
                                                   % minZ and maxZ are tried first, if they fail we fall back to 
                                                   % minZ2 and maxZ2. This approach makes things
                                                   % a little (~10%) faster
                                                   % N.B. ALL HORIZONS (AND CORRESPONDING RANGES)
                                                   % BELOW minZ2 ARE SET TO ZERO.
source.BinaryInspiral.thresholdSNR      = 8;       % With which single detector SNR do we wish to determine
                                                   % the range
source.BinaryInspiral.zVecLength        = 1000;    %Range calculations involve integrating over redshift z
                                                   %from zero to the horizon redshift. How many points do
                                                   %you want to evaluate in your integral /
                                                   %linspace?
                                                   %Execution time is roughly linear in this
                                                   %number
                                                   %100 is safe enough if you need speed
source.BinaryInspiral.distRelativeError = 0.001;   %Converting distances to redshifts is done
                                                   %iteratively. The iterations stop when
                                                   %abs(dNew - dOld) / dOld < distRelativeError
                                                   %see dist_to_redshift.m (Only) used in
                                                   % calculate_range to convert range to redshift
source.BinaryInspiral.reachFraction     = 0.1;     % The reach is defined as the distance at
                                                   % which reachFraction of events are
                                                   % detectable. This is an effort to improve
                                                   % upon the misleading horizon metric (which tells us the distance at
                                                   % which we see zero events),
%Load lookup table of cumulative probability distribution of theta/4.
%See See PRD VOLUME 47, NUMBER 6 15 MARCH 1993
%Used to account for antenna and radiation patterns. Needed to convert horizon to range.
%File is created by thetaPMonteCarlo.m
load('probabilityThetaPGreaterThanLookup.mat'); 
source.BinaryInspiral.thetaPVec = thetaPVec;    
source.BinaryInspiral.probabilityThetaPGreaterThan = probabilityThetaPGreaterThan;
clear thetaPVec probabilityThetaPGreaterThan


%% Neutron Star
source.NeutronStar.Mass1 = 1.4; % [MSol]
source.NeutronStar.Mass2 = 1.4; % [MSol]
source.NeutronStar.Spin1 = 0;   % Reduced spin i.e. S/m^2 (IMR only)
source.NeutronStar.Spin2 = 0;   % Reduced spin i.e. S/m^2 (IMR only)
source.NeutronStar.Tidal = 0;   % Apply rough scaling of f_isco to account for tidal
                                % disruption? (non-IMR only, 0 or 1)

%Select the waveform you want - Inspiral, IMRPhenomB, or IMRPhenomD
%source.NeutronStar.Waveform = 'Inspiral';   %Inspiral-only, cutting of at fisco (or higher
                                             %freq. if Tidal=1).
source.NeutronStar.Waveform = 'IMRPhenomB'; %PRL 106, 241101 (2011)
%source.NeutronStar.Waveform = 'IMRPhenomD'; %PRD 93, 044007 (2016)


%% Black Hole
source.BlackHole.Mass1 = 30; % [MSol]
source.BlackHole.Mass2 = 30; % [MSol]
source.BlackHole.Spin1 = 0;  % Reduced spin i.e. S/m^2 (IMR only)
source.BlackHole.Spin2 = 0;  % Reduced spin i.e. S/m^2 (IMR only)

%Select the waveform you want - Inspiral, IMRPhenomB, or IMRPhenomD
%source.BlackHole.Waveform = 'Inspiral';   %Inspiral-only, cutting of at fisco (or higher
                                             %freq. if Tidal=1).
source.BlackHole.Waveform = 'IMRPhenomB'; %PRL 106, 241101 (2011)
%source.BlackHole.Waveform = 'IMRPhenomD'; %PRD 93, 044007 (2016)


% $$$ %% NS/BH 1.4/30 Short Hard Gamma Ray Bursts
% $$$ source.SHGRB.Mass1 = 1.4; % Solar Mass
% $$$ source.SHGRB.Mass2 = 30; % Solar Mass
% $$$ source.SHGRB.Distance = 40; % Megaparces

%% Stochastic
source.Stochastic.powerlaw = 2/3;           % used to be 0. Changed to 2/3.
source.Stochastic.integration_time = 1;           % years
source.Stochastic.confidence = 0.9;               % confidence level for frequentist upper limit
source.Stochastic.referenceFrequency = 25;

%% Pulsar

source.Pulsar.name1 = 'Crab Pulsar';      % First pulsar
source.Pulsar.distance1 = 1.9;            % kiloparsecs          % kiloparsecs
source.Pulsar.I31 = 3e38;                 % Moment of inertia, in mks units
source.Pulsar.rotation_frequency1 = 29.8; % rotational frequency
source.Pulsar.frequency_multiple1 = 2;    % frequency multiplier for GW emission
source.Pulsar.integration_time1 = 1;      % integraton time in years

source.Pulsar.name2 = 'Sco X-1';          % Second pulsar
source.Pulsar.distance2 = 2.8;            % kiloparsecs
source.Pulsar.I32 = 1e38;                 % Moment of inertia, in mks units
source.Pulsar.rotation_frequency2 = 310;  % rotational frequency
source.Pulsar.frequency_multiple2 = 2;    % frequency multiplier for GW emission
source.Pulsar.integration_time2 = 1;      % integraton time in years

%%%%%%

return

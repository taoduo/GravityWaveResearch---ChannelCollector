function ifo = IFOModel_sqz
  % Modified GWINC model with aLIGO-like parameters
  % and freqeuency dependent squeezing
  
  % start with base model
  ifo = IFOModel;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Adjust IFO parameters
  
  % set laser power
  ifo.Laser.Power = 125;
  
  % add Newtonian Noise cancellation
  ifo.Seismic.Omicron = 2;
  
  % Optics
  ifo.Optics.SRM.Transmittance  = 0.35;           % Transmittance of SRM
  
  ifo.Optics.SRM.Tunephase = 0.0;             % SRM tuning
  ifo.Optics.Quadrature.dc = pi/2;            % demod/detection/homodyne phase
  
  % compute ifo info for use in filter cavity calculation
  ifo = precompIFO(ifo);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Squeezer Parameters
  
  % Define the squeezing you want:
  %   None = ignore the squeezer settings
  %   Freq Independent = nothing special (no filter cavties)
  %   Freq Dependent = applies the specified filter cavites
  ifo.Squeezer.Type = 'Freq Dependent';
  ifo.Squeezer.AmplitudedB = 8;              % SQZ amplitude [dB]
  ifo.Squeezer.SQZAngle = 0;                 % SQZ phase [radians]
  ifo.Squeezer.LOAngleRMS = 30e-3;           % quadrature noise [radians]

  ifo.Squeezer.InjectionLoss = 0.05;         % power loss after squeezer
  ifo.Optics.PhotoDetectorEfficiency = 0.9;  % 1 - readout loss
  
  % Parameters for frequency dependent squeezing
  fcParams.L = 16;             % cavity length
  fcParams.Lrt = 16e-6;        % round-trip loss in the cavity
  fcParams.Te = 1e-6;          % end mirror trasmission
  fcParams.Rot = deg2rad(0);   % phase rotation after cavity (why?)
  
  % compute input mirror transmission and detuning
  ifo.Squeezer.FilterCavity = computeFCParams(ifo, fcParams);
end

% ifo = precompIFO(ifo, PRfixed)
%   add precomputed data to the IFO model
%
% To prevent recomputation of these precomputed data, if the
% ifo argument contains ifo.gwinc.PRfixed, and this matches
% the argument PRfixed, no changes are made.
%
% (mevans June 2008)

function ifo = precompIFO(ifo, PRfixed)
  
  % check PRfixed
  if nargin < 2
    PRfixed = true;
  end
  
  if isfield(ifo, 'gwinc') && ...
      isfield(ifo.gwinc, 'PRfixed') && ifo.gwinc.PRfixed == PRfixed
    return
  end
  
  ifo.gwinc.PRfixed = PRfixed;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DERIVED OPTICS VALES
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Calculate optics' parameters
  ifo.Materials.MirrorMass = ...
    pi*ifo.Materials.MassRadius^2*ifo.Materials.MassThickness;
  ifo.Materials.MirrorMass = ifo.Materials.MirrorMass* ...
    ifo.Materials.Substrate.MassDensity;		% Kg
  ifo.Optics.ITM.Thickness = ifo.Materials.MassThickness;

  % check against suspension mass value
  massError = 100 * log(ifo.Materials.MirrorMass / ifo.Suspension.Stage(1).Mass);
  if abs(massError) > 2
    warning('Computed mirror mass and suspensed mass differ:')
    fprintf('  ifo.Suspension.Stage(1).Mass = %.1f\n', ifo.Suspension.Stage(1).Mass)
    fprintf('  ifo.Materials.MirrorMass = %.1f\n', ifo.Materials.MirrorMass)
  end
  
  % set vertical-horizontal coupling
  %  (approximate... depends on site leveling)
  ifo.Suspension.VHCoupling.theta = ifo.Infrastructure.Length / ifo.Constants.R_earth;
  
  % set mirror temperature
  if ~isfield(ifo.Materials.Substrate, 'Temp')
    ifo.Materials.Substrate.Temp = ifo.Constants.Temp;
  end
  
  % beam sizes
  len = ifo.Infrastructure.Length;
  g1 = 1 - len / ifo.Optics.Curvature.ITM; % g-factor of the ITM
  g2 = 1 - len / ifo.Optics.Curvature.ETM; % g-factor of the ETM
  gcav = sqrt(g1 * g2 * (1 - g1 * g2));
  gden = g1 - 2 * g1 * g2 + g2;

  if (g1 * g2 * (1 - g1 * g2)) <= 0
    error('Unstable arm cavity g-factors.  Change ifo.Optics.Curvature')
  elseif gcav < 1e-3
    warning('Nearly unstable arm cavity g-factors.  Reconsider ifo.Optics.Curvature')
  end
  
  lambda = ifo.Laser.Wavelength;
  ws = sqrt(len * lambda / pi);       % not the waist, just a scale factor
  w1 = ws * sqrt(abs(g2) / gcav);
  w2 = ws * sqrt(abs(g1) / gcav);
  
  w0 = ws * sqrt(gcav / abs(gden));   % gaussian beam waist size
  zr = pi * w0^2 / lambda;            % Rayleigh range
  z1 = len * g2 * (1 - g1) / gden;   % location of ITM relative to the waist
  z2 = len * g1 * (1 - g2) / gden;   % location of ETM relative to the waist

  ifo.Optics.ITM.BeamRadius = w1;        % m; 1/e^2 power radius
  ifo.Optics.ETM.BeamRadius = w2;        % m; 1/e^2 power radius

  % coating layer optical thicknesses - mevans 2 May 2008
  ifo.Optics.ITM.CoatLayerOpticalThickness = getCoatDopt(ifo, 'ITM');
  ifo.Optics.ETM.CoatLayerOpticalThickness = getCoatDopt(ifo, 'ETM');

  % compute power on BS
  [pbs, parm, finesse, prfactor, Tpr] = precompPower(ifo, PRfixed);

  ifo.gwinc.pbs = pbs;
  ifo.gwinc.parm = parm;
  ifo.gwinc.finesse = finesse;
  ifo.gwinc.prfactor = prfactor;
  ifo.gwinc.gITM = g1;
  ifo.gwinc.gETM = g2;
  ifo.gwinc.BeamWaist = w0;
  ifo.gwinc.BeamRayleighRange = zr;
  ifo.gwinc.BeamWaistToITM = z1;
  ifo.gwinc.BeamWaistToETM = z2;
  
  % set computed PRM transmission
  ifo.Optics.PRM.Transmittance = Tpr;

  % compute quantum noise parameters
  [fSQL, fGammaIFO, fGammaArm] = precompQuantum(ifo);
  ifo.gwinc.fSQL = fSQL;
  ifo.gwinc.fGammaIFO = fGammaIFO;
  ifo.gwinc.fGammaArm = fGammaArm;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % LOAD SAVED DATA
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % precompute bessels zeros for finite mirror corrections
  global besselzeros;
  if isempty(besselzeros)
    % load saved values, or just compute them
    try
      load besselzeros
    catch
      besselzeros = besselzero(1, 300, 1);
    end
  end
  ifo.Constants.BesselZeros = besselzeros;
  
  % Seismic noise term is saved in a .mat file defined in your respective IFOModel.m
  % It is loaded here and put into the ifo structure.
  %load(ifo.Seismic.darmSeiSusFile)
  
  %ifo.Seismic.darmseis_f = darmseis_f;
  %ifo.Seismic.darmseis_x = darmseis_x;


function [fSQL, fGammaIFO, fGammaArm] = precompQuantum(ifo)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % input numbers
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % physical constants
  hbar = ifo.Constants.hbar; % J s
  c    = ifo.Constants.c;    % m / s
  
  % IFO parameters
  lambda = ifo.Laser.Wavelength;
  Titm   = ifo.Optics.ITM.Transmittance;
  Tsrm   = ifo.Optics.SRM.Transmittance;
  m      = ifo.Materials.MirrorMass;
  L      = ifo.Infrastructure.Length;
  Lsrc   = ifo.Optics.SRM.CavityLength;
  
  % power on BS (W) computed in precompBSPower
  Pbs    = ifo.gwinc.pbs;
  Parm   = ifo.gwinc.parm;
  
  % derived parameters
  w0 = 2 * pi * c / lambda;      % carrier frequency (rad/s)
  gammaArm = Titm * c / (4 * L); % arm cavity pole (rad/s)
  fGammaArm = gammaArm / (2*pi);
  rSR = sqrt(1 - Tsrm);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % IFO equations
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % fSQL as defined in D&D paper (eq 33 in P1400018 and/or PRD paper)
  tSR = sqrt(Tsrm);
  fSQL = (1/(2*pi))*(8/c)*sqrt((Parm*w0)/(m*Titm))*(tSR/(1+rSR)); ...
  
  % gammaIFO in Hz
  fGammaIFO = fGammaArm * ((1 + rSR) / (1 - rSR));
  
end

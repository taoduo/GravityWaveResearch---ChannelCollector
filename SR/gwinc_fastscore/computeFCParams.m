function fcParams = computeFCParams(ifo, fcParams)
% Computes ideal filter cavity Tin, detuning [Hz] and bandwidth
% [Hz] and adds them to the fcParams struct.
%
%
%

  % FC parameters
  c     = ifo.Constants.c; % m / s
  fsrFC = c / (2 * fcParams.L);
  lossFC = fcParams.Lrt + fcParams.Te;
  
  % detuning and cavity bandwidth (D&D paper P1400018 and/or PRD)
  eps = 4 / (2 + sqrt(2 + 2 * ...
    sqrt(1 + (4 * pi * ifo.gwinc.fSQL / (fsrFC * lossFC))^4)));
  s1eps = sqrt(1 - eps);
  
  gammaFC = ifo.gwinc.fSQL / sqrt(s1eps + s1eps^3);     % cavity bandwidth [Hz]
  detuneFC = s1eps * gammaFC;                 % cavity detuning [Hz]
  
  % input mirror transmission
  TinFC = 4 * pi * gammaFC / fsrFC - lossFC;
  if TinFC < lossFC
    error('IFC: Losses are too high! %.1f ppm max.', 1e6 * gammaFC / fsrFC)
  end
  
  % Add to fcParams structure
  fcParams.Ti    = TinFC;
  fcParams.fdetune = -detuneFC;
  fcParams.gammaFC  = gammaFC;
  fcParams.fsrFC = fsrFC;
  
end

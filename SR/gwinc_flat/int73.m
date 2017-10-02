function score = int73(f, psd, ifo, source)
%
% score = int73(f, psd, ifo, source)
%
% Takes the IFO noise and the frequency vector and determines the inspiral range.  IMR waveforms are
% used for BBH and BNS by default. Cosmological effects are included for both BNS and BBH.
%
% Returned range is now in terms of COMOVING distance rather than previous luminosity distance
% (which is still available in the advanced substruct).
%
% Assumptions:
% Uniform rate of mergers per comoving volume per time
% Zero curvature universe Omega_k=0
%
% See https://dcc.ligo.org/LIGO-T1500491 or gwinc/rangeNote/
% 
%
% f      - frequency vector [Hz]
%          The entire frequency vector is used in calculating the range.
%          i.e. there is no fmin which depends on the bounce mode 
% psd    - PSD of strain sensitivity [1/Hz]
% ifo    - GWINC-style ifo structure
% source - GWINC-style source model 
%
% score - output struct containing the following for ns (score.NeutronStar) and analogous for bh
% (score.BlackHole)
%
%    comovingRangeMpc
%    horizonZ
%    
%    And in the advanced substruct (e.g. score.NeutronStar.advanced)
%    
%    comovingHorizonMpc
%    luminosityHorizonMpc
%    rangeZ
%    luminosityRangeMpc
%    sensitiveVolumeMpc3
%    zVec: [1x2000 double]
%    optimalSNRVec: [1x2000 double]
%    fractionDetectableVec: [1x2000 double]
%    comovingRangeToComovingHorizon
%    luminosityRangeToLuminosityHorizon
%    zRangeToZHorizon
%
%
% jmiller@ligo.mit.edu
%


% Binary Neutron Stars -------------------------------------------------
    
inputCheck_int73(source.NeutronStar)
    
[score.NeutronStar.horizonZ,...
 score.NeutronStar.advanced.comovingHorizonMpc,...
 score.NeutronStar.advanced.luminosityHorizonMpc] = ...
    calculate_horizon(f, psd, source.NeutronStar, ifo, source);

[score.NeutronStar.comovingRangeMpc,...
 score.NeutronStar.advanced.rangeZ,...
 score.NeutronStar.advanced.luminosityRangeMpc,...
 score.NeutronStar.advanced.sensitiveVolumeMpc3,...
 score.NeutronStar.advanced.zVec,...
 score.NeutronStar.advanced.optimalSNRVec,...
 score.NeutronStar.advanced.fractionDetectableVec] = ...
    calculate_range(f, psd, source.NeutronStar, score.NeutronStar, ifo, source);

[score.NeutronStar.advanced.comovingRangeToComovingHorizon,...
 score.NeutronStar.advanced.luminosityRangeToLuminosityHorizon,...
 score.NeutronStar.advanced.zRangeToZHorizon] = calculate_rangeToHorizonFactor(score.NeutronStar);

[score.NeutronStar.reachZ,...
 score.NeutronStar.advanced.comovingReachMpc,...
 score.NeutronStar.advanced.luminosityReachMpc] = calculate_reach(score.NeutronStar, ifo, source);

score.NeutronStar = orderfields(score.NeutronStar,{'comovingRangeMpc','horizonZ','reachZ','advanced'});

% Binary Black Holes  -------------------------------------------------

inputCheck_int73(source.BlackHole)

[score.BlackHole.horizonZ,...
 score.BlackHole.advanced.comovingHorizonMpc,...
 score.BlackHole.advanced.luminosityHorizonMpc] = ...
    calculate_horizon(f, psd, source.BlackHole, ifo, source);

[score.BlackHole.comovingRangeMpc,...
 score.BlackHole.advanced.rangeZ,...
 score.BlackHole.advanced.luminosityRangeMpc,...
 score.BlackHole.advanced.sensitiveVolumeMpc3,...
 score.BlackHole.advanced.zVec,...
 score.BlackHole.advanced.optimalSNRVec,...
 score.BlackHole.advanced.fractionDetectableVec] = ...
    calculate_range(f, psd, source.BlackHole, score.BlackHole, ifo, source);

[score.BlackHole.advanced.comovingRangeToComovingHorizon,...
 score.BlackHole.advanced.luminosityRangeToLuminosityHorizon,...
 score.BlackHole.advanced.zRangeToZHorizon] = calculate_rangeToHorizonFactor(score.BlackHole);

[score.BlackHole.reachZ,...
 score.BlackHole.advanced.comovingReachMpc,...
 score.BlackHole.advanced.luminosityReachMpc] = calculate_reach(score.BlackHole, ifo, source);
 
score.BlackHole = orderfields(score.BlackHole,{'comovingRangeMpc','horizonZ','reachZ','advanced'});
end

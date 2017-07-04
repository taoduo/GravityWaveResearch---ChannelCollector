function [reachZ, comovingReachMpc, luminosityReachMpc] = calculate_reach(cbcScore, ifo, source)
%Find the redshift at which source.BinaryInspiral.reachFraction of events are observable
%This version relies on a previous call to calculate_range. See calculate_reach_standalone for an alternative.
%
% reachZ = calculate_reach(cbcScore, ifo source)
%

reachZ = interp1(cbcScore.advanced.fractionDetectableVec, cbcScore.advanced.zVec, source.BinaryInspiral.reachFraction,'pchip');

% Convert z to distance
[luminosityReachMpc, comovingReachMpc]  = redshift_to_dist(reachZ,ifo);

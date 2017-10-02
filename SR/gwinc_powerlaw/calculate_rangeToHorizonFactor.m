function [comovingRangeToComovingHorizon, luminosityRangeToLuminosityHorizon, zRangeToZHorizon] = ...
        calculate_rangeToHorizonFactor(cbcScore)
    

    comovingRangeToComovingHorizon = cbcScore.advanced.comovingHorizonMpc/cbcScore.comovingRangeMpc;
    luminosityRangeToLuminosityHorizon = cbcScore.advanced.luminosityHorizonMpc/ ...
        cbcScore.advanced.luminosityRangeMpc;
    zRangeToZHorizon = cbcScore.horizonZ/cbcScore.advanced.rangeZ;
    
end
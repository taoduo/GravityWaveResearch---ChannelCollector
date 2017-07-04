function [comovingRangeMpc, rangeZ, luminosityRangeMpc, sensitiveVolumeMpc3, zVec, optimalSNRVec, ...
          fractionDetectableVec] = calculate_range(f, psd, cbcStruct, cbcScore, ifo, source)
%
% [comovingRangeMpc, rangeZ, luminosityRangeMpc, sensitiveVolumeMpc3, zVec, optimalSNRVec, ...
%          fractionDetectableVec] = calculate_range(f, psd, cbcStruct, cbcScore, ifo, source)
%
%
% Compute the range for a given interferometer configuration
%
% f         - frequency vector [Hz]
%             The entire frequency vector is used in calculating the range.
%              i.e. there is no fmin which depends on the bounce mode 
% psd       - PSD of strain sensitivity [1 / Hz]
% cbcStruct - e.g. sourceModel.NeutronStar
% cbcScore  - score.NeutronStar/BlackHole from calculate_horizon
% ifo       - GWINC-style ifo structure
% source    - GWINC-style source model 

%Treat case where horizon is zero
%Usually because waveform has no overlap with ifo in frequency space
if cbcScore.horizonZ == 0
    comovingRangeMpc      = 0;
    rangeZ                = 0;
    luminosityRangeMpc    = 0;
    sensitiveVolumeMpc3   = 0;
    zVec                  = zeros(1, source.BinaryInspiral.zVecLength);
    optimalSNRVec         = zeros(1, source.BinaryInspiral.zVecLength);
    fractionDetectableVec = zeros(1, source.BinaryInspiral.zVecLength);
    return
end

%Speed improvement evaluating in advance    
frt3 = f.^(1/3); 
fm23 = f.^(-2/3);
fm76 = f.^(-7/6);

%Range is calculated by doing an integral over redshift. This vector defines the redshifts
%considered
zVec = linspace(0, cbcScore.horizonZ, source.BinaryInspiral.zVecLength);
    
%Compute the comoving volume element (http://arxiv.org/abs/astro-ph/9905116)
dVdz = comovingVolumeElement(zVec,ifo); %Mpc^3

%Inlcude a factor for the difference in clock ticks at the detector and the source
dtsdt0 = 1./(1+zVec);

%Compute the SNR of an optimally located and oriented source at the specified z
for ii = 1:length(zVec)
        optimalSNRVec(ii) = calculate_snr(f, frt3, fm23, fm76, psd ,zVec(ii), cbcStruct, ifo, ...
                                          source);
end

%Calculate the fraction of sources at a given z which
% we can detect given the optimal SNR, the threshold
% SNR and the probability distribution of signal reduction
% due to sky location and orientation
fractionDetectableVec = fractionDetectable(optimalSNRVec, source);

%Detection-weighted comoving sensitive volume
%See https://dcc.ligo.org/LIGO-T1500491 or gwinc/rangeNote/ 
integrandVcBar      = dVdz .* dtsdt0 .* fractionDetectableVec;
sensitiveVolumeMpc3 = trapz(zVec, integrandVcBar);

%Comoving range (V_sphere = 4/3 pi r^3) still works in an expanding universe, see Hogg (29)
comovingRangeMpc = ((3/(4*pi))*sensitiveVolumeMpc3)^(1/3);

%Convert comoving range to luminosity range and z
comoving           = 1;
rangeZ             = dist_to_redshift(comovingRangeMpc, ifo, comoving, ...
                                      source.BinaryInspiral.distRelativeError);
luminosityRangeMpc = comoving_to_luminosity(comovingRangeMpc, rangeZ);

end

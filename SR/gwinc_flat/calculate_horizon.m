function [horizonZ, comovingHorizonMpc, luminosityHorizonMpc] = calculate_horizon(f, ...
                                                      psd, cbcStruct, ifo, source)
%
%  [horizonZ, comovingHorizonMpc, luminosityHorizonMpc] = calculate_horizon(f,  psd, cbcStruct, ifo, source)
%
% Compute the horizon distance for a given interferometer configuration
%
% f         - frequency vector [Hz]
% psd       - PSD of strain sensitivity [1 / Hz]
% cbcStruct - e.g. sourceModel.NeutronStar
% ifo       - GWINC-style ifo structure
% source    - GWINC-style source model 


%Horizon z is obtained by finding the root of the eqn
% SNR(z)=source.BinaryInspiral.thresholdSNR
% These constants give some reasonable bounds for the root-finding algorithm
minZ  = source.BinaryInspiral.minZ;
maxZ  = source.BinaryInspiral.maxZ;
minZ2 = source.BinaryInspiral.minZ2;
maxZ2 = source.BinaryInspiral.maxZ2;

%Speed improvement evaluating in advance    
frt3 = f.^(1/3); 
fm23 = f.^(-2/3);
fm76 = f.^(-7/6);

% The equation to be solved
eq = @(z) calculate_snr(f, frt3, fm23, fm76, psd,  z, cbcStruct, ifo, source)-source.BinaryInspiral.thresholdSNR;

%Compute the redshift and luminosity distance at which the SNR equals the desired value
try   %Narrow (but reasonable for 2G and 3G ifos) bounds
    horizonZ = fzero(eq,[minZ maxZ]);
catch % Wider bounds if the above fails
    
    try
%         fprintf(['\n Couldn''t find horizon for z in [%f, %f], trying z in [%e, %f]). Generally, this ' ...
%                  'message should only appear if you are looking an interferometer with sensitivity ' ...
%                  'very different from a 2G or 3G design. \n'],minZ, maxZ, minZ2, maxZ2);
        horizonZ = fzero(eq,[minZ2 maxZ2]);
    catch 
%         fprintf(['\n Failed to find horizon for z in [%e, %f]. Most likely your waveform cutoff ' ...
%                  'freq. is below the minimum of your freq. vector or your luminosity horizon is less than ' ...
%                  '%e Mpc. HORIZON IS SET TO ZERO. \n'], minZ2, maxZ2, redshift_to_dist(minZ2,ifo));
        horizonZ = 0;
    end
        
end

% Convert z to distance
[luminosityHorizonMpc, comovingHorizonMpc]  = redshift_to_dist(horizonZ,ifo);

end %end calculate_horizon


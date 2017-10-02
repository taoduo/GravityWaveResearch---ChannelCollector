function rho = calculate_snr(f, frt3, fm23, fm76, psd, z, cbcStruct, ifo, source)
%
% rho = calculate_snr(f, psd, z, cbcStruct, ifo, source)
%
% f           - frequency vector [Hz]
% frt3 = f.^(1/3); 
% fm23 = f.^(-2/3);
% fm76 = f.^(-7/6);
% psd         - vector strain sensitivity [1/Hz]
% cbcStruct   - e.g. sourceModel.NeutronStar
% ifo, source - Gwinc-style structures. See IFOModel or SourceModel
%
    
%
%
% Copyright (C) 2012  Alan Weinstein
% Simplified and adapted by Salvatore Vitale and John Miller (2014)
% Full Comspology with IMR ( Salvo, 2015)
% Speed improvements and matlab conversion (John, 2015)

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
% Public License for more details.
%
% A copy of the GNU General Public License may be found at
% http://www.gnu.org/copyleft/gpl.html
% or write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

%Parse constants/input from IFOModel and SourceModel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SNR = source.BinaryInspiral.thresholdSNR;

m1  = cbcStruct.Mass1;
m2  = cbcStruct.Mass2;
s1  = cbcStruct.Spin1;
s2  = cbcStruct.Spin2;



%Main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Select waveform
switch cbcStruct.Waveform
    
  case 'Inspiral'
        %Black holes don't have tidal effects
    if isfield(cbcStruct, 'Tidal')
        tidal = cbcStruct.Tidal;
    else
        tidal = 0;
    end
    
    rho = evaluate_snr_integral(f, Inspiral(f, fm76, m1,m2,z,redshift_to_dist(z, ifo), tidal, ifo),psd);

  case 'IMRPhenomB'
    rho = evaluate_snr_integral(f, IMRPhenomB(f,frt3, fm23, fm76, m1, m2,s1,s2,z,redshift_to_dist(z, ifo), ifo),psd);
  
  case 'IMRPhenomD'
    rho = evaluate_snr_integral(f, IMRPhenomD(f, m1, m2,s1,s2,z,redshift_to_dist(z, ifo), ifo),psd);
end



    

%END MAIN CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out =  evaluate_snr_integral(freq,  amplitude, psd)
%
%  freq: the frequency vector
%  amplitude: the WF amplitude vector up to max(freq)
%  psd: the power spectral density (~e-44)
%  
% Calculates the SNR. See e.g. (B2) of Ajith2008

 snr2Vec = amplitude(:).^2 ./ psd(:); %(:) ensures same dimension
    snr2 = trapz(freq, snr2Vec); 
    
    snr2 = snr2 * 4;
    out  = sqrt(snr2);
  
end % end evaluate_snr_integral
      



  
end %end calculate horizon


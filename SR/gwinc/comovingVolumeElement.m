function [dVdz, Rc, Rl, dRcdz, dRldz] = comovingVolumeElement(z,ifo)
%
% [dVdz, Rc, Rl, dRcdz] = comovingVolumeElement(z,ifo)
%
% Compute the comoving volume of a redshift shell
%
% z     - redshift
% ifo   - GWINC-style ifo struct
%
% dVdz  - d(comoving volume)/ d(redshift)
% Rc    - comoving distance
% Rl    - luminosity distance
% dRcdz - d(comoving distance)/ d(redshift)
% 
%From Hogg 1999 (28)
%dVc = (DH (1+z)^2*DA^2*dOmega*dz)/E(z)
    
  if nargin <2
      ifo.Constants.c           = 2.99792458e8;             % [m / s]
      ifo.Constants.H0          = 67110;                    % [ms^( - 1)/Mpc]
      ifo.Constants.omegaM      = 0.3175;                   % Mass density parameter 
      ifo.Constants.omegaLambda = 1 - ifo.Constants.omegaM; % Cosmological constant density parameter
                                                            % omegaK = 0 (flat universe) is assumed
  end

      
 c        = ifo.Constants.c;
 H0       = ifo.Constants.H0;
 om       = ifo.Constants.omegaM;
 ol       = ifo.Constants.omegaLambda;
 
 [Rl, Rc] = redshift_to_dist(z, ifo);         % get luminosity distance
 
 dVdRc    = 4 * pi * Rc.^2;                   % area of a sphere, using comoving distance
 DH       = c / H0;                           % Hubble distance in Mpc
 dRcdz    = DH ./ sqrt(om * (1 + z).^3 + ol); % comoving distance per redshift = DH for z << 1
 dVdz     = dVdRc .* dRcdz;                   % [Mpc^3]
  
 %just for the record
 dRldz    = dRcdz .* (1 + z) + Rc;
end
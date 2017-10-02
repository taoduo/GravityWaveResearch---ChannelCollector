function [d, dc] =  redshift_to_dist(z,ifo)
%
% [d, dc] = redshift_to_dist(z,[ifo]);
%
% d - luminosity distance IN MPC
%
% dc - comoving distance IN MPC
%
% z   - redshift 
% ifo - GWINC style ifo struct. For constants. Optional
%
% Takes a redshift and returns the corresponding luminosity distance in a flat lambdaCDM universe
% This version is an analytical approximation based on 
% Adachi and Kasai,  Progress of Theoretical Physics, Vol. 127, No. 1, January 2012
% For our parameters results are good to better than ~0.2%

if nargin <2
    ifo.Constants.c = 2.99792458e8; % [m / s]
    ifo.Constants.H0     = 67110;        % [ms^( - 1)]
    ifo.Constants.omegaM = 0.3175;       % Mass density parameter 
    ifo.Constants.omegaLambda = 1 - ifo.Constants.omegaM; % Cosmological constant density parameter
                                                          % omegaK = 0 (flat universe) is assumed
end

clight = ifo.Constants.c;
H0     = ifo.Constants.H0;
om     = ifo.Constants.omegaM;
ol     = ifo.Constants.omegaLambda;

x0     = (1-om)/om;
x      = x0.*(1+z).^(-3);

phi    = (1+1.320*x +0.4415*x.^2 +0.02656*x.^3) ./(1+1.392*x +0.5121*x.^2 +0.03944*x.^3);
phi0   = (1+1.320*x0+0.4415*x0^2+0.02656*x0^3)/(1+1.392*x0+0.5121*x0^2+0.03944*x0^3);

d      =  (2*clight/H0).*(1+z)/sqrt(om).*(phi0-(1+z).^(-1/2).*phi);

dc     = luminosity_to_comoving(d, z);
    
end % end redshift_to_dist

% $$$ % Exact version
% $$$ function [d, dc] =  redshift_to_dist(z,ifo)
% $$$ % Takes a redshift and returns the corresponding luminosity distance in a flat lambdaCDM universe
% $$$  
% $$$ if nargin <2
% $$$     ifo.Constants.c = 2.99792458e8; % [m / s]
% $$$     ifo.Constants.H0     = 67110;        % [ms^( - 1)]
% $$$     ifo.Constants.omegaM = 0.3175;       % Mass density parameter 
% $$$     ifo.Constants.omegaLambda = 1 - ifo.Constants.omegaM; % Cosmological constant density parameter
% $$$                                                               % omegaK = 0 (flat universe) is assumed
% $$$ end
% $$$ 
% $$$ clight = ifo.Constants.c;
% $$$ H0     = ifo.Constants.H0;
% $$$ om     = ifo.Constants.omegaM;
% $$$ ol     = ifo.Constants.omegaLambda;
% $$$ 
% $$$ % Lambda CDM  cosmology;
% $$$     
% $$$     function out = inv_hubble(z)
% $$$         x = 1+z;
% $$$         E = sqrt(om*x.^3+ol);
% $$$         out =   1./E; 
% $$$     end
% $$$     
% $$$  for ii = 1:numel(z);
% $$$     X = clight/(H0);
% $$$     d(ii) =  X*integral(@inv_hubble,0,z(ii))*(1+z(ii));
% $$$     dc(ii) = d(ii)/(1+z(ii));   
% $$$  end
% $$$  
% $$$ end % end redshift_to_dist

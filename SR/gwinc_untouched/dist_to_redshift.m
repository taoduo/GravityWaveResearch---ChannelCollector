function out = dist_to_redshift(d, ifo, comoving, relative_error)
%
% z = dist_to_redshift(d, [ifo, comoving, relative_error])
%
% z - redshift
%
% d   - luminosity distance in Mpc OR comoving distance in Mpc if comoving = 1
% ifo - GWINC style IFO struct. Provides constants. Optional
% relative_error - code is iterative, it will stop when
%                  (abs(redshift_to_dist(z,ifo)-d)/d) < relative_error
%                  Optional
% comoving - 0 or 1 Is the the distance in comoving?
    
if d == 0
    out = 0;
    return
end
    
if nargin <2
    ifo.Constants.c           = 2.99792458e8; % [m / s]
    ifo.Constants.H0          = 67110;        % [ms^( - 1)]
    ifo.Constants.omegaM      = 0.3175;
    ifo.Constants.omegaLambda = 1 - ifo.Constants.omegaM;
end

if nargin < 3
    comoving = 0;
end

if nargin <4
    relative_error = 0.001;
end



clight = ifo.Constants.c;
H0     = ifo.Constants.H0;

%first order guess
%z=d*H0/clight

%Better guess  - H0*d=c*z*(1+0.5*(1-q0)*z)
q0 = ifo.Constants.omegaM - ifo.Constants.omegaLambda; %Deceleration parameter
k  = 0.5 * (1 - q0);
z  = ( - clight + sqrt(clight^2 + 4 * k * clight * H0 * d)) / (2 * k * clight);

%check resulting dist
while 1
    [dtmp, dctmp] = redshift_to_dist(z,ifo);
    if comoving == 1
        tmp = dctmp;
    else
        tmp = dtmp;
    end
    
    x   = abs(tmp-d)/d;
        
    
    if x<relative_error
        break %%%%%%%%%%%%%%%%%%
    end
    
    if d<tmp
        z = z - x * z;
    else
        z = z + x * z;
    end

end

out = z;

end %Function

% $$$ %Slow relative to above
% $$$ function out = dist_to_redshift(d)
% $$$ % Analytic expression is only valid for small d. 
% $$$ % start from first-order guess and the use iteratively the exact z-to-D function till we find the right redshift
% $$$     eq = @(z) d-redshift_to_dist(z,ifo);
% $$$ 
% $$$     %first order guess
% $$$     H0     = 67110.;
% $$$     zGuess = d*H0/clight;
% $$$     
% $$$     z = fzero(eq,zGuess);
% $$$    out = z;
% $$$ 
% $$$ end

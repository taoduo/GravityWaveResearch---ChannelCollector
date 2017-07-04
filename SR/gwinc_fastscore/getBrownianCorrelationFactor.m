function Neff=getBrownianCorrelationFactor(N,separation_w)


% Brownian noise correlation for delay lines

% The Brownian noise from the separate spots on the delay line are somewhat
% correlated. Therefore the effective number of spots (for brownian noise
% calculations) is bigger than N
%
% Input:
% N: number of spots per mirror
% separation_w : neighbouring beam separation, in multiples of w
% 
% Output:
% Neff: use this in stead of the naive N for Brownian noise calculations

% Based on PHYSICAL REVIEW D, VOLUME 65, 082002
% Author: Stefan Ballmer

R=separation_w/(2*sin(pi/N));
Neff=0;
for n=1:N
    x1=R*exp(2i*pi/N*n);
    for m=1:N
        x2=R*exp(2i*pi/N*m);
        dx=abs(x2-x1);
        Neff=Neff+ (besseli(0,dx.^2/2).*exp(-dx.^2/2));
    end
end

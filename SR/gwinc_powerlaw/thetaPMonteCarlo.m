%My own Monte Carlo to get the cumulative probability distribution for theta prime
%See PRD VOLUME 47, NUMBER 6 15 MARCH 1993
clear all
close all

%The more trials the better
nTrials  = 1e8;

%We will interp our final cumulative distribution onto this many points between 0 and 4
%Theta takes values between 0 and 4
nLookup = 1000;


% Set up random variables
costheta = - 1 + (1 + 1) * rand(nTrials, 1);
phi      = 2 * pi * rand(nTrials, 1);
zeta     = 2 * pi * rand(nTrials, 1);
cosi     = - 1 + (1 + 1) * rand(nTrials, 1);

% Define function components
Fplus  = 0.5*cos(2*zeta).*(1+costheta.^2).*cos(2*phi)-sin(2*zeta).*costheta.*sin(2*phi);
Fcross = 0.5*sin(2*zeta).*(1+costheta.^2).*cos(2*phi)+cos(2*zeta).*costheta.*sin(2*phi);

clear costheta phi zeta

%Define the main function
theta  = sqrt(...
             4*(Fplus.^2.*(1+cosi.^2).^2+4*Fcross.^2.*cosi.^2)...
            );

clear cosi Fplus Fcross


%Make cumulative probability of theta
theta = sort(theta);
length(unique(theta)) %Sometimes get repeated values!
cMC   = 1-(1:nTrials)/nTrials;


%Make a lookup table
thetaLookup = linspace(0,4,nLookup);
cLookup = interp1(theta,cMC,thetaLookup,'pchip');


%Test against values in Finn - he gets 1.84
integrand = theta'.^2.*(1-(1:nTrials)/nTrials);
result = trapz(theta, integrand)

%Do the same thing with our lookup table
integrandInterp = thetaLookup.^2.*cLookup;
resultInterp = trapz(thetaLookup, integrandInterp)

%Convert to theta prime = thetaP = theta/4
thetaPVec = thetaLookup/4;
probabilityThetaPGreaterThan = cLookup;

save('probabilityThetaPGreaterThanLookup', 'thetaPVec', 'probabilityThetaPGreaterThan')
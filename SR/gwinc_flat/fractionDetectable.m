function fd = fractionDetectable(optimalSNRVec, source)
%
% fd = fractionDetectable(optimalSNR, source)
%
% Given the optimal SNR for a source at a given distance what fraction
% of events are actually observable taking sky position and orientation into account?
% Returns a statistical estimate of the the fraction of sources which are detectable at a given
% distance. Can be interpreted as the probability that any given source will be detected.
%
% optimalSNRVec - vector of SNR values for your source at each of the redshifts in zVec
%                 Optimal alignment &orientation assumed
% source        - GWINC style source model file
%
%
    
 SNRRatio = source.BinaryInspiral.thresholdSNR./optimalSNRVec;
 %SNRRatio = 4*SNRRatio; %If using theta not theta prime
 

 fd = cumprobThetaNumerical(SNRRatio);
 
 
 function c = cumprobThetaNumerical(x)
 %Prob that thetaP>=x from my thetaPMonteCarlo.m
 %Everything outside the domain of the lookup table [0,1] is 0
     c = interp1(source.BinaryInspiral.thetaPVec, source.BinaryInspiral.probabilityThetaPGreaterThan, x,'pchip',0);
 end
 
 
% $$$ % Analytical approximations for theta (not thetaP) -  should be avoided
% $$$  
% $$$  function p = probThetaAnalytical(theta)
% $$$  % The (wrong) analytical approximation for the probability of getting a theta
% $$$  % Finn 1996, eq. 3.11
% $$$      if theta>0 & theta<4
% $$$          p = (5/256)*theta*(4-theta)^3;
% $$$      else
% $$$          p = 0;
% $$$      end
% $$$      
% $$$  end %thetaAnalytical
% $$$  
% $$$  
% $$$  
% $$$  function c = cumprobThetaAnalytical(x)
% $$$  %Taylor 2012, eq. 13
% $$$  % int_x^inf probTheta dTheta i.e. prob that theta >= x
% $$$      for ii = 1:length(x)
% $$$          if x(ii) <= 0
% $$$              c(ii) = 1;
% $$$          elseif x(ii) > 4
% $$$              c(ii) = 0;
% $$$          else
% $$$              c(ii) = ((1+x(ii)).*(4-x(ii)).^4)/256;
% $$$          end
% $$$      end
% $$$  end
% $$$ 
% $$$ function c = cumprobThetaAnalytical2(w)
% $$$ %Dominik 2015, eq. A2
% $$$ % prob that theta/4 >= w
% $$$     a2 = 0.374222;
% $$$     a4 = 2.04216;
% $$$     a8 = -2.63948;
% $$$     alpha0 = 1.0;
% $$$     
% $$$     for ii = 1:length(w)
% $$$          if w(ii) <= 0
% $$$              c(ii) = 1;
% $$$          elseif w(ii) > 1
% $$$              c(ii) = 0;
% $$$          else
% $$$              c(ii) =   a2*(1-w(ii)/alpha0).^2 + a4*(1-w(ii)/alpha0).^4 +a8*(1-w(ii)/alpha0).^8+...
% $$$                        (1 - a2 - a4 - a8)*(1 - w(ii)/alpha0).^10;
% $$$ 
% $$$          end
% $$$      end
% $$$      
% $$$  end

end

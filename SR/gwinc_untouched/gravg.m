function n = gravg(f, ifo)
% Gravity Gradient Noise
% Written by Enrico Camagna (?)
% added to Bench by Gregg Harry 8/27/03
% Calculates gravity gradient noise for four mirrors
% ** --- Add reference here -- **

  fk    = ifo.Seismic.KneeFrequency;
  a     = ifo.Seismic.LowFrequencyLevel;
  L     = ifo.Infrastructure.Length;
  gamma = ifo.Seismic.Gamma;
  ggcst = ifo.Constants.G;
  rho   = ifo.Seismic.Rho;
  beta  = ifo.Seismic.Beta;
  
  if isfield(ifo.Seismic, 'Omicron')
      omicron = ifo.Seismic.Omicron;
  else
      omicron = 1;
  end

  
  % a sort of theta function (Fermi distr.)
  coeff = 1./(1 + 3.^(gamma.*(f-fk)));

  % modelization of seismic noise
  ground = a*coeff + a*(1-coeff).*(fk./f).^2;

  % effective GG spring frequency, with G gravitational
  fgg = sqrt(ggcst * rho) / (2*pi);

  % fixed numerical factors, 5/9/06, PF
  n = (beta*4*pi/L*(fgg^2./f.^2).*ground).^2;

  %omicron = 10;  % subtraction factor (this should have freq dependence...)
  
  n = n ./ (omicron^2);
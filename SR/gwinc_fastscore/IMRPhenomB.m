function out = IMRPhenomB(freq, freqrt3, fm23, fm76, m1, m2, s1, s2, z, lum_distance,ifo)
%
% IMR waveform of optimally located and oriented source
%
% freq are *observer* (i.e. LIGO) frequencies in Hz
% frt3 = f.^(1/3); 
% fm23 = f.^(-2/3);
% fm76 = f.^(-7/6);
% m1 and m2 are the *intrinsic* (i.e. not redshifted) masses in solar masses
% s1 and s2 are the reduced (aligned) spins in range (-1,+1)
% z is redshift
% lum_distance is the luminosity distance (=(1+z) geometrical distance) in Mpc
%
% See
% ``Inspiral-Merger-Ringdown Waveforms for Black-Hole Binaries with Nonprecessing Spins''
% PRL 106, 241101 (2011)
% Henceforth `Ajith2011'
% and
% ``Higher-order spin effects in the amplitude and phase of gravitational waveforms emitted
% by inspiraling compact binaries: Ready-to-use gravitational waveforms''
% PHYSICAL REVIEW D 79, 104023 (2009)
% Henceforth Ajith2008
% returns the strain amplitude at observer frequency in 1/sqrt(Hz)
    
    
    
    if nargin <11
        ifo.Constants.c       = 2.99792458e8;                     % m / s; speed of light in vacuum
        ifo.Constants.parsec  = ifo.Constants.AU * (648000 / pi); % m, IAU 2015 Resolution B2
        ifo.Constants.SolarMassParameter = 1.3271244e20;          % m^3 / s^2; G * MSol, IAU 2015 Resolution B3
        ifo.Constants.G       = 6.67408e-11;                      % m^3 / (kg  s^2); Grav. const
                                                          % http://arxiv.org/abs/1507.07956
        ifo.Constants.MSol    = ifo.Constants.SolarMassParameter / ifo.Constants.G; % kg; Solar mass
    end

    
    clight = ifo.Constants.c;
    G      = ifo.Constants.G;
    parsec = ifo.Constants.parsec;
    MSol   = ifo.Constants.MSol;
    
    chi       = (m1 * s1 + m2 * s2) / (m1 + m2); % Spin parameter. Our s_i is Chi_i in Ajith2011
    
    


    % Redshift masses
    m1 = m1*(1+z);
    m2 = m2*(1+z);
  
    % Convert lum_distance from Mpc to metres
    lum_distance= lum_distance * 1e6 * parsec;
  
    totalMass = m1 + m2;
    eta       = m1 * m2 / totalMass^2; % Symmetric mass ratio
    mChirp    = eta^(3/5)*totalMass;   %Chirp mass
    piM       = pi* totalMass * MSol * G / clight^3;
    %chi       = (m1 * s1 + m2 * s2) / (m1 + m2); % Spin parameter. Our s_i is Chi_i in Ajith2011. %Moved to main part of code to facilitate error checking
    etap2     = eta^2;
    chip2     = chi^2;
    etap3     = eta^3;
    etap2chi  = etap2 * chi;
    etachip2  = eta * chip2;
    etachi    = eta * chi;
    
    %See (2) and Table 1. in Ajith2011
    
    %f1 in Ajith2011
    fMerg =  1 - 4.4547 * (1 - chi)^0.217 + 3.521 * (1 - chi)^0.26 + ...
             6.4365e-01 * eta   +  8.2696e-01 * etachi   + -2.7063e-01 * etachip2 + ...
            -5.8218e-02 * etap2 + -3.9346e+00 * etap2chi + ...
            -7.0916e+00 * etap3;
    
    %f2 in Ajith2011
    fRing = (1 - 0.63 * (1 - chi)^0.3) / 2 + ...
             1.4690e-01 * eta   + -1.2281e-01 * etachi   + -2.6091e-02 * etachip2 + ...
            -2.4900e-02 * etap2 +  1.7013e-01 * etap2chi + ...
             2.3252e+00 * etap3; 
  
    sigma = (1 - 0.63 * (1 - chi)^0.3) * ((1 - chi)^0.45) / 4 + ...
            -4.0979e-01 * eta   + -3.5226e-02 * etachi   +  1.0082e-01 * etachip2 + ...
             1.8286e+00 * etap2 + -2.0169e-02 * etap2chi + ...
            -2.8698e+00 * etap3;
    
    %f3 in Ajith2011
    fCut  = 0.3236 + 0.04894*chi + 0.01346 * chi^2-...
            0.1331      * eta   - 0.08172     * etachi   + 0.1451      * etachip2 - ...
            0.2714      * etap2 + 0.1279      * etap2chi + ...
            4.922       * etap3;

    fMerg = fMerg / piM;
    fRing = fRing / piM;
    sigma = sigma / piM;
    fCut  = fCut  / piM;
    
    %Make sure objects combine before they ringdown. Do analytical check.
    if fMerg>fRing
        warning('calcHorizon:freqOrder','fMerg (%f Hz) > fRing (%f Hz).\n', fMerg, fRing)
    end
    if fRing>fCut
        warning('calcHorizon:freqOrder2','fRing (%f Hz) > fCut (%f Hz).\n', fRing, fCut)
    end
    
  
    % PN corrections to the frequency domain amplitude of the (2,+/-2) mode
    alpha2   = -323/224 + 451 * eta/168;
    alpha3   = (27/8 - 11 * eta/6) * chi;

    % leading order power law of the merger amplitude
    mergPower = -2/3;

    % spin-dependent corrections to the merger amplitude
    epsilon_1 =  1.4547 * chi - 1.8897;
    epsilon_2 = -1.8153 * chi + 1.6557;

    % normalisation constants to make the inspiral amplitude
    % continuous across the transitions between inspiral, ringdown
    % and merger
    vMerg = (piM * fMerg)^(1/3);
    vRing = (piM * fRing)^(1/3);
    %wm in Ajith2011
    w1 = (1. + alpha2 * vMerg^2 + alpha3 * piM * fMerg) /...
         (1. + epsilon_1 * vMerg + epsilon_2 * vMerg^2);
    %wr in Ajith2011
    w2 = w1 * (pi * sigma / 2.) * (fRing / fMerg)^mergPower ...
          * (1. + epsilon_1 * vRing + epsilon_2 * vRing^2);




    v  = piM^(1/3) * freqrt3;
    v2 = v.^2;
    v3 = piM * freq;

    % C in Ajith2008
    amp0 = (1/lum_distance)*sqrt(5*pi/(24*clight^3))*...
           (G*mChirp*MSol)^(5/6)*pi^(-7/6)*...
           fMerg^(-7/6);
    
    % Divide into inspiral, merger and ringdown
    lowInds  = freq<fMerg;
    highInds = and(freq>=fRing,freq<fCut);
    %highInds = freq>=fRing;
    midInds  = and(freq>=fMerg,freq<fRing);
    %Try this~(lowInd | highInd)
    
    %Apply appropriate waveform and amplitude scaling
    ampEff           = zeros(1, length(freq));
    ampEff(lowInds)  = amp0 * fm76(lowInds) / (fMerg^( - 7 / 6)) .* (1. + alpha2 * v2(lowInds) + alpha3 * v3(lowInds));        
    ampEff(midInds)  = amp0 * w1 * fm23(midInds) / (fMerg^mergPower) .* (1. + epsilon_1 * v(midInds) + epsilon_2 * v2(midInds));
    ampEff(highInds) = amp0 * w2 * LorentzianFn(freq(highInds), fRing, sigma);



    out = ampEff;

    
end % end IMRPhenomB

function out = LorentzianFn(freq, fRing, sigma)
%
% Lorentzian function centred at fRing with FWHM sigma
%

    out = sigma ./ (2 * pi * ((freq - fRing).^2 + sigma^2 / 4));

end


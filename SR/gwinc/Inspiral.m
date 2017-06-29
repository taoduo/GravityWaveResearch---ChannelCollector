function out=Inspiral(freq, fm76, m1, m2, z, lum_distance, tidal, ifo)
%
% Inspiral waveform of optimally located and oriented source
%
% freq are *observer* (i.e. LIGO) frequencies in Hz
% fm76 = f.^(-7/6);
% m1 and m2 are the *intrinsic* (i.e. not redshifted) masses in solar masses
% z is redshift
% lum_distance is the luminosity distance (=(1+z) geometrical distance)
    
% returns the strain at observer frequency
    
    if nargin <8
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

    if tidal
        gStop = 5 - 3 ./ (1 + exp((m1+m2 - 4) * 3));
    else
        gStop = 1;
    end

    % gStop: the merger does not end at fISCO, but somewhat higher
    % for BBH, the factor is about 5 between ISCO and when the signal
    % terminates in the ring-down.  The slope of the signal spectrum
    % is nearly the same as the inspriral, though a bit higher at
    % fPeak = 4 * fISCO (so the below is an underestimate).
    % Depending on tidal disruption in systems with NS, the signal
    % present about fISCO can vary, but it is generally present to
    % at least fStop = 2 * fISCO.  In BH-NS systems, disruption is
    % less likely as BH mass increases, with 10 solar mass or more systems
    % showing little disruption (except when BH spin is very high).
    % 
    % See
    % http://repoz1.nims.re.kr/amaldi11/files/00InvPl/38/ShoemakerAmaldi.pdf (page 7)
    % http://repoz1.nims.re.kr/amaldi11/files/00InvPl/32/ShibataAmaldi15.pdf (page 23)

    %Redshift the masses
    m1 = m1 * (1 + z);
    m2 = m2 * (1 + z);
    
    
    lum_distance= lum_distance* 1e6 * parsec; % from Mpc meters

    totalMass = m1 + m2;

    eta = m1 * m2 / totalMass^2; %Symmetric mass ratio
    
    mChirp = eta^(3/5)*totalMass;

    % Innermost stable circular orbit (ISCO)
    fisco_standard = clight^3/(6*sqrt(6)* pi * G * MSol * totalMass);
    fisco = gStop*fisco_standard; %Apply scaling to account for tidal deformation effects

    
    % Find this warning annoying?
    % Run this
    % warning('off', 'calcHorizon:ISCO');
    if fisco < min(freq)
        
        warning('calcHorizon:ISCO','ISCO (%f Hz) is smaller than the minimum frequency (%f Hz) for the selected masses. Please consider using IMR waveforms. Result may be unreliable.\n', fisco, min(freq))
    end
    
    %Overall amplitude scaling for optimally oriented and located source
    amp0 = (1/lum_distance)*sqrt(5*pi/(24*clight^3))*...
           (G*mChirp*MSol)^(5/6)*pi^(-7/6);

    lowInds      = freq <= fisco;
    out          = zeros(size(freq));
    %out(lowInds) = amp0 * freq(lowInds).^( - 7 / 6);
    out(lowInds) = amp0 * fm76(lowInds);

    
  end % end Inspiral

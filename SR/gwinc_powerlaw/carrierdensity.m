function n = carrierdensity(f,ifo)
    % CARRIERDENSITY - strain noise psd arising from charge carrier density 
    % fluctuations in ITM substrate (for semiconductor substrates).
    
    % show it on the blue gwinc:
    % close all;BlueBird3;hold all;f=logspace(log10(f_LOLO),log10(f_HIHI),100);loglog(f,sqrt(carrierdensity(f,IFOModel_120_1550)),'LineWidth',3);legs=get(legend,'String');legend({legs{:},'','CD Noise'},'FontSize',14)

    w = ifo.Optics.ITM.BeamRadius;
    L = ifo.Infrastructure.Length;
    H = ifo.Materials.MassThickness;
    kBT = ifo.Constants.kB * ifo.Materials.Substrate.Temp;
    hbar = ifo.Constants.hbar;
    c = ifo.Constants.c;
    
    diffElec = ifo.Materials.Substrate.ElectronDiffusion;
    diffHole = ifo.Materials.Substrate.HoleDiffusion;
    mElec = ifo.Materials.Substrate.ElectronEffMass;
    mHole = ifo.Materials.Substrate.HoleEffMass;
    cdDens = ifo.Materials.Substrate.CarrierDensity;
    gammaElec = ifo.Materials.Substrate.ElectronIndexGamma;
    gammaHole = ifo.Materials.Substrate.HoleIndexGamma;
    
    T = ifo.Optics.ITM.Transmittance;
    FSR = c/(2*L); % in Hz
    Finesse = 2*pi/T;
    cavPole = FSR/(2*Finesse); % in Hz
    gPhase = 2*Finesse/pi;

    omega = 2*pi*f;
    
    integrand = @(k,om,D) D*k.^3.*exp(-k.^2*w^2/4)./(D^2*k.^4+om^2);
    
    integralElec = arrayfun(@(om) integral(@(k) integrand(k,om,diffElec),0,Inf),omega);
    integralHole = arrayfun(@(om) integral(@(k) integrand(k,om,diffHole),0,Inf),omega);
    
    % From P1400084 Heinert et al. Eq. 15 
    %psdCD = @(gamma,m,int) 2*(3/pi^7)^(1/3)*kBT*H*gamma^2*m/hbar^2*cdDens^(1/3)*int; %units are meters
    psdCD = @(gamma,m,int) 2/pi*H*gamma^2*cdDens*int; %units are meters
    
    
    psdElec = psdCD(gammaElec,mElec,integralElec);
    psdHole = psdCD(gammaHole,mHole,integralHole);
    
    psdMeters = 2*(psdElec+psdHole);
    
    n = psdMeters./(gPhase*L).^2;

end
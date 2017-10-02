% This script makes the seismic curves saved in seismicnew.mat which then
% get called into gwinc by seismic.m. Units in m/rtHz.
% It uses JeffK's damped quad model to calculate quad vertical and length
% motion, and FabriceM's estimate of BSC_ISI motion.
%
% See README notes in model files for further details of model origin.
%
% A. Effler, J. Kissel Apr 2012
% $Id: makeSeismicEstimate.m,v 1.3 2012-04-07 21:18:04 jkissel Exp $

plotFigs  = false;
printFigs = false;
saveData  = false;

cvsDir          = '/ligo/svncommon/IscCVS/iscmodeling/';
gwincDir        = [cvsDir 'gwinc/'];
bscisiModelFile = '2012-04-03_FM_BSCISI_DispASD.mat';
quadModelFile   = '2012-04-03_JSK_QUAD_DispTF.mat';
plotFileNames   = {'2012-04-03_TestMass_SEISUS_Displacement_Estimate';...
                   '2012-04-03_DARM_SEISUS_Displacement_Estimate'};
saveFileName    = 'seismic_2012-04-03.mat';               

%% Load Pre-defined IFO Parameters
ifo        = IFOModel;     
theta      = ifo.Suspension.VHCoupling.theta;

%% Load BSC-ISI Model
load(bscisiModelFile)

freq = Freq;

% For now, we assume X = Y = Z displacement
% In the future, we can include either real models or measurments
bscisiDisp_ASD.X = abs(X);
bscisiDisp_ASD.Z = abs(X);

clear('Freq','X','README');
%% Load QUAD Model
load(quadModelFile)

% For now, we assume only GND L produces TST L
% In the future, we should include sensor noise, other BSC-ISI
% DOFs coupling to L and V, etc.
quadDisp_TF.GndLtoTstL = squeeze(quadModel.dampedf(out.tst.disp.L,in.gnd.disp.L,:));
quadDisp_TF.GndVtoTstV = squeeze(quadModel.dampedf(out.tst.disp.V,in.gnd.disp.V,:));

clear('quadModel','in','out','pend','README');

%% Calculate total, local test mass displacement in logitudinal (along the beam line) and in (local) vertical

% For now, we assume that L is aligned with X
tstDisp_ASD.L = abs(bscisiDisp_ASD.X) .* abs(quadDisp_TF.GndLtoTstL);
tstDisp_ASD.V = abs(bscisiDisp_ASD.Z) .* abs(quadDisp_TF.GndVtoTstV); 

%% Calculate DARM displacement

% DARM displacement is calculated by adding all four tst masses in
% quadrature, including the vertical displacement scaled by the pre-defined
% vertical-to-longitudinal cross-coupling factor.
darmDisp_ASD = sqrt(4) * sqrt( (tstDisp_ASD.L).^2 + (theta * tstDisp_ASD.V).^2 );

%% Plot Estimate
if plotFigs
    figure(1)
    ll = loglog(freq,[bscisiDisp_ASD.X ...
                      bscisiDisp_ASD.Z ...
                      tstDisp_ASD.L ...
                      tstDisp_ASD.V]);
    xlim([1e-1 1e2])
    ylim([1e-30 1e-5])
    set(gca,'YTick',10.^(-30:5))
    set(ll,'LineWidth',2)
    set(ll(1),'LineWidth',4)
    xlabel('Frequency [Hz]')
    ylabel('Displacement [m/rtHz]')
    title('Test Mass Displacement Model, 2012-04-03')
    legend('BSC-ISI X',...
           'BSC-ISI Z',...
           'Test Mass L',...
           'Test Mass V',...
           'Location','SouthWest')
    
    figure(2)
    loglog(freq,[tstDisp_ASD.L,...
                 theta * tstDisp_ASD.V,...
                 darmDisp_ASD])
    xlim([1e-1 1e2])
    ylim([1e-30 1e-5])
    set(gca,'YTick',10.^(-30:5))
    xlabel('Frequency [Hz]')
    ylabel('Displacement [m/rtHz]')
    title({'DARM Displacement Model, 2012-04-03';...
           ['sqrt(4) * sqrt([Test Mass L]^2 + [' num2str(theta) ' * Test Mass V]^2)']})
    legend('Test Mass L',...
           [num2str(theta) ' * Test Mass V'],...
           'DARM',...
           'Location','SouthWest')
    
    if printFigs
        figure(1)
        FillPage('w')
        IDfig
        saveas(gcf,[gwincDir plotFileNames{1} '.pdf'])
        saveas(gcf,[gwincDir plotFileNames{1} '.png'])
        
        figure(2)
        FillPage('w')
        IDfig
        saveas(gcf,[gwincDir plotFileNames{2} '.pdf'])
        saveas(gcf,[gwincDir plotFileNames{2} '.png'])
    end
end

%% Save collective .mat file
if saveData
    %% Something's screwy with the frequency vector, let's fix that.
    [freq,I,J] = unique(freq);
    darmDisp_ASD = darmDisp_ASD(I);
    
    save([gwincDir saveFileName],'freq','darmDisp_ASD');
end                      
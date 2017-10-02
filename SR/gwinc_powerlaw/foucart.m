% Runs GWINC with some nominal parameters

f_LOLO = 5; % frequency limits
f_HIHI = 5000;

ifo = IFOModel; % this is a data structure that contains the standard aLIGO parameters

[sss,nnn] = gwinc(f_LOLO,f_HIHI,ifo,SourceModel,2); % calculate the tuned aLIGO noise
frequency = nnn.Freq.';
ASD_aligo = sqrt(nnn.Total).';


% now calculate noise for other tunings
             % T_SRM Tunephase Homodynephase
parameters = [  .011       4.7           128    % 1kHz
                .011      3.13           128    % 1.5kHz
                .011      2.35           128 ]; % 2kHz


for j = 1:size(parameters,1)
    
    % apply parameters to ifo model
    ifo.Optics.SRM.Transmittance = parameters(j,1);
    ifo.Optics.SRM.Tunephase = parameters(j,2)*pi/180;
    ifo.Optics.Quadrature.dc = parameters(j,3)*pi/180;
    
    
    [sss,nnn] = gwinc(f_LOLO,f_HIHI,ifo,SourceModel,2); % calculate the tuned aLIGO noise
    
    ASD_tuned{j} = sqrt(nnn.Total).';
end


% make plots

loglog(frequency,[ASD_aligo cell2mat(ASD_tuned)])
xlim([f_LOLO f_HIHI])
ylim([2e-24 1e-21])
legend('aLIGO','1kHz tuned','1.5kHz','2kHz')

% save data
dlmwrite('aLIGO.txt',[frequency ASD_aligo])
dlmwrite('tuned_1kHz.txt',[frequency ASD_tuned{1}])
dlmwrite('tuned_1p5kHz.txt',[frequency ASD_tuned{2}])
dlmwrite('tuned_2kHz.txt',[frequency ASD_tuned{3}])



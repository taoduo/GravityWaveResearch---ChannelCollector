function [y,f]=cddcases()
startup;
tic
% CDD curves
NSNOSRM25=[ 25,  0,          1, 0.014, 0.027, 120/180*pi];
ZERODET25=[ 25,  0       , 0.2, 0.014, 0.027, 116/180*pi];
ZERODET  =[125,  0       , 0.2, 0.014, 0.027, 116/180*pi];
NSNS     =[125, 11/180*pi, 0.2, 0.014, 0.027, 103/180*pi];
BHBH20   =[ 20, 20/180*pi, 0.2, 0.014, 0.027, 105/180*pi];
BHBH     =[4.5, 72/180*pi, 0.2, 0.014, 0.027,  90/180*pi];
KHZ=    [125,4.7/180*pi,0.011,0.014, 0.027, 128/180*pi];


% other tunings
NSNOSRM40=[ 40,  0,          1, 0.014, 0.027, 120/180*pi];
BHBH30= [ 19, 30/180*pi, 0.2, 0.014, 0.027,  78/180*pi];
BHNOSRM=[7.8,  0       ,   1, 0.014, 0.027, 145/180*pi];
EXTREMEHF = [125,63.4/180*pi,0.03,0.21,0.002,135/180*pi];


%conjGradientOptimizer(0,NSNS,[0,0,0,0,1,0])
[y(1,:),f] = callGwinc(NSNOSRM25);
[y(2,:),f] = callGwinc(ZERODET25);
[y(3,:),f] = callGwinc(ZERODET);
[y(4,:),f] = callGwinc(NSNS);
[y(5,:),f] = callGwinc(BHBH20);
[y(6,:),f] = callGwinc(KHZ);

set(0,'DefaultAxesLineStyleOrder',{'-','-.*','-o'})
hndls = loglog(f,sqrt(y));
grid on;
xlabel('Frequency [Hz]');
ylabel('Strain [1/\surdHz]');
title('AdvLIGO tunings');
legstr={'NO SRM','ZERO DET, low P.','ZERO DET, high P.','NSNS Opt.',...
       'BHBH 20deg','High Freq'};
legend(legstr,1);
axis([9,3000,9e-25,3.1e-21]);

set(hndls(1:(end)),'LineWidth',3);
set(hndls(1:end),'LineStyle','-.')
set(hndls(3),'LineStyle','-')
print('-dpng','AdvLIGO_CDD_noise_curves.png');

for ii=1:6
  dat=[f',sqrt(y(ii,:))'];
  name=strrep(legstr{ii},' ','_');
  name=strrep(name,'.','');
  name=strrep(name,',','');
  name=[name,'.txt'];
  disp(['Saving ',name]);
  save(name,'dat','-ASCII','-DOUBLE');
end

toc
return




function [y,f]=callGwinc(x)
shotradmode = 2;
ifo = IFOModel;
src = SourceModel;
tprmind = 5;
scmode = 0;
f_seis = 9; % Seismic Wall Cutoff frequency
f_Nyq = 8192; % Fake Nyquist frequency
variate = [0,0,0,0,0,0]; % This is a great variable name Stefan

    if length(x)>tprmind
      ifo.Optics.Quadrature.dc=x(6);
    end;
    switch variate(tprmind)
      case 1,
        [sss,nnn] = gwinc(f_seis,f_Nyq,ifo,src,shotradmode,...
                    x(1),x(2),x(3),x(4),x(tprmind));
      otherwise,
        [sss,nnn] = gwinc(f_seis,f_Nyq,ifo,src,shotradmode,...
                    x(1),x(2),x(3),x(4));
    end;
   
    y = nnn.Total;
    f = nnn.Freq;
return

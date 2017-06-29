function cases()
startup;

% Optimized for NSNS:
ZEROLOW=[ 25,  0,        0.2, 0.014, 0.027, 103/180*pi];
ZERODET=[125,  0,        0.2, 0.014, 0.027, 116/180*pi];
NOSRM = [ 25,  0,          1, 0.014, 0.027, 110/180*pi];

BHNOSRM=[7.8,  0       ,   1, 0.014, 0.027, 145/180*pi];

% optimized for 1 kHz
KHZ =   [125,4.7/180*pi,0.011,0.014, 0.027, 128/180*pi];

EXTREMEHF = [125,58/180*pi,0.03,0.21,0.002,135/180*pi];

% As if we get 6dB of squeezing
SQUEEZED=[125 * 4,  0,        0.13, 0.014, 0.027, 116/180*pi];

%conjGradientOptimizer(0,NSNS,[0,0,0,0,1,0])
[y(1,:),f] = callGwinc(EXTREMEHF);
[y(2,:),f] = callGwinc(ZEROLOW);
[y(3,:),f] = callGwinc(ZERODET);
[y(4,:),f] = callGwinc(SQUEEZED);


set(0,'DefaultAxesLineStyleOrder',{'-','-.*','-o'})
hndls = loglog(f,sqrt(y));
grid on;
grid minor
xlabel('Frequency [Hz]');
ylabel('Strain [1/\surdHz]');
title('AdvLIGO tunings');
legend('mS Pulsar','IMBH','NS/NS Inspiral','NS/NS Merger',1);
axis([9,8000,9e-25,3.1e-21]);

set(hndls(1:(end)),'LineWidth',3);

gak = [f(:) sqrt(y)'];
save aligo_cases3.txt gak -ascii


return




function [y,f] = callGwinc(x)
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

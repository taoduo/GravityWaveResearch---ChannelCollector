

% Optimized for NSNS:
NSNS=   [125, 11/180*pi, 0.2, 0.014, 0.027, 103/180*pi];
ZERODET=[125,  0       , 0.2, 0.014, 0.027, 116/180*pi];
NSNOSRM=[ 40,  0,          1, 0.014, 0.027, 120/180*pi];

% Optimized for BHBH
BHBH=   [4.5, 72/180*pi, 0.2, 0.014, 0.027,  90/180*pi];
BHBH20= [ 20, 20/180*pi, 0.2, 0.014, 0.027, 105/180*pi];
BHBH30= [ 19, 30/180*pi, 0.2, 0.014, 0.027,  78/180*pi];
BHNOSRM=[7.8,  0       ,   1, 0.014, 0.027, 145/180*pi];

% optimized for 1 kHz
KHZ=    [125,4.7/180*pi,0.011,0.014, 0.027, 128/180*pi];

EXTREMEHF = [125,63.4/180*pi,0.03,0.21,0.002,135/180*pi];


%conjGradientOptimizer(0,NSNS,[0,0,0,0,1,0])
[y(1,:),f] = callGwinc(NSNS);
[y(2,:),f] = callGwinc(ZERODET);
%[y(3,:),f] = callGwinc(NSNOSRM);
%[y(4,:),f] = callGwinc(BHBH);
[y(3,:),f] = callGwinc(BHBH20);
%[y(6,:),f] = callGwinc(BHNOSRM);
[y(4,:),f] = callGwinc(KHZ);

%set(0,'DefaultAxesLineStyleOrder',{'-','-.*','-o'})
figure(8708)
hplot = loglog(f,sqrt(y(1,:)),'r',...
               f,sqrt(y(2,:)),'b',...
               f,sqrt(y(3,:)),'k',...
               f,sqrt(y(4,:)),'g');
grid on
grid minor
hXLabel = xlabel('Frequency [Hz]');
hYLabel = ylabel('Strain [1/\surdHz]');
%title('AdvLIGO tunings');
hLegend = legend('NS/NS','Broadband',...
                 'BH/BH','Pulsars',1);
axis([10,4000,10e-25,3e-21]);

set(hplot(1:(end)),'LineWidth',5);

set( gca                       , ...
    'FontName'   , 'Times'     , ...
    'FontSize'   , 34          );
set([hXLabel, hYLabel], ...
    'FontName'   , 'Times');
set([hLegend]             , ...
    'FontSize'   , 24           );
set([hXLabel, hYLabel]  , ...
    'FontSize'   , 34         );
%set( hTitle                    , ...
%    'FontSize'   , 12          , ...
%    'FontWeight' , 'bold'      );

set(gca, ...
  'Box'         , 'on'     , ...
  'TickDir'     , 'in'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.03 .03 .03], ...
  'YColor'      , [.03 .03 .03], ...
  'YTick'       , logspace(-25,-19,7), ...
  'LineWidth'   , 1.5         );

%% Crazy commands for making a nice plot
orient landscape
set(gcf,'Position',[900 400 1000 700])
set(gcf,'PaperPositionMode','auto')
saveas(gcf, 'CasesRMP', 'fig')
print -depsc -r600 CasesRMP.eps
%[a,b] = system('epstopdf CasesRMP.eps --nocompress --autorotate=All')




% script to calculate overlap reduction functions for fsr search

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
det1 = 'H1'; isBar1 = false;
det2 = 'H2'; isBar2 = false;
flow = 36480;
fhigh = 38527.875;
N = 16384;
f = linspace(flow, fhigh, N);

o11 = overlap(f, det1, det1, 'exact', 'id', 196608, isBar1, isBar2);
o22 = overlap(f, det2, det2, 'exact', 'id', 196608, isBar1, isBar2);
o12 = overlap(f, det1, det2, 'exact', 'id', 196608, isBar1, isBar2);

save overlapH1H2-fsrNEW.mat


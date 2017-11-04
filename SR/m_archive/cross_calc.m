l = load('lowp_pl.mat');
rmpath('./gwinc_powerlaw');
addpath('./gwinc_flat');
opt10 = l.opt10;
ifo = IFOModel;
src = SourceModel;
for i = 1 : length(opt10)
    p = opt10(i, 1);
    ret = gwinc(10, 3000, ifo, src, 2, p, deg2rad(opt10(i, 3)), opt10(i, 2));
    opt10(i, 5) = ret.Omega;
end

opt15 = l.opt15;
for i = 1 : length(opt15)
    p = opt15(i, 1);
    ret = gwinc(15, 3000, ifo, src, 2, p, deg2rad(opt15(i, 3)), opt15(i, 2));
    opt15(i, 5) = ret.Omega;
end

opt20 = l.opt20;
for i = 1 : length(opt20)
    p = opt20(i, 1);
    ret = gwinc(20, 3000, ifo, src, 2, p, deg2rad(opt20(i, 3)), opt20(i, 2));
    opt20(i, 5) = ret.Omega;
end
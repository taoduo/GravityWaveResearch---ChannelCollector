addpath('./gwinc_flat');
powers = 2 : 0.5 : 2.5;
opt_10 = zeros(length(powers), 4); % four cols: power, transmission, phase and omega
opt_15 = zeros(length(powers), 4); 
opt_20 = zeros(length(powers), 4);

minTransmission = 0;
finenessTransmission = 0.001;
maxTransmission = 1;
minPhase = 0;
finenessPhase = 1;
maxPhase = 180;

for i = 1 : length(powers)
    p = powers(i);
    opt_10(i, 1) = p;
    opt_15(i, 1) = p;
    opt_20(i, 1) = p;
    [opt_10(i, 4), opt_10(i, 2), opt_10(i, 3), ~] = scan_src( ...
        finenessTransmission, minTransmission, maxTransmission, ...
        finenessPhase, minPhase, maxPhase, ...
        p, sprintf('%.1f_10Hz.mat', p), '', 10);
    [opt_15(i, 4), opt_15(i, 2), opt_15(i, 3), ~] = scan_src( ...
        finenessTransmission, minTransmission, maxTransmission, ...
        finenessPhase, minPhase, maxPhase, ...
        p, sprintf('%.1f_15Hz.mat', p), '', 15);
    [opt_20(i, 4), opt_20(i, 2), opt_20(i, 3), ~] = scan_src( ...
        finenessTransmission, minTransmission, maxTransmission, ...
        finenessPhase, minPhase, maxPhase, ...
        p, sprintf('%.1f_20Hz.mat', p), '', 20);
end
save(sprintf('opt_%.1f_%.1f.mat', powers(1), powers(end)), 'opt_10', 'opt_15', 'opt_20');

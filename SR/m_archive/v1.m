addpath('./gwinc_flat');
powers = 2 : 0.5 : 2.5;
opt10 = zeros(length(powers), 4); % four cols: power, transmission, phase and omega
opt15 = zeros(length(powers), 4); 
opt20 = zeros(length(powers), 4);

minTransmission = 0;
finenessTransmission = 0.001;
maxTransmission = 1;
minPhase = 0;
finenessPhase = 1;
maxPhase = 180;

for p = powers
    i = int32(p / 0.5);
    opt10(i, 1) = p;
    opt15(i, 1) = p;
    opt20(i, 1) = p;
    [opt10(i, 4), opt10(i, 2), opt10(i, 3), ~] = scan_src( ...
        finenessTransmission, minTransmission, maxTransmission, ...
        finenessPhase, minPhase, maxPhase, ...
        p, sprintf('%.1f_10Hz.mat', p), '', 10);
    [opt15(i, 4), opt15(i, 2), opt15(i, 3), ~] = scan_src( ...
        finenessTransmission, minTransmission, maxTransmission, ...
        finenessPhase, minPhase, maxPhase, ...
        p, sprintf('%.1f_15Hz.mat', p), '', 15);
    [opt20(i, 4), opt20(i, 2), opt20(i, 3), ~] = scan_src( ...
        finenessTransmission, minTransmission, maxTransmission, ...
        finenessPhase, minPhase, maxPhase, ...
        p, sprintf('%.1f_20Hz.mat', p), '', 20);
end
save(sprintf('opt_%.1f_%.1f.mat', powers(1), powers(end)), 'opt10', 'opt15', 'opt20');

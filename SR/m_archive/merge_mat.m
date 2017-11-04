% merge the opt mat files and append the power row
files = dir('opt_*_*.mat'); 
res10 = zeros(9, 4);
res15 = zeros(9, 4);
res20 = zeros(9, 4);

ind = 1;
for i = 1 : length(files)
    d = load(files(i).name);
    d10 = d.opt10;
    res10(ind, :) = d10(1, :);
    
    d15 = d.opt15;
    res15(ind, :) = d15(1, :);
    
    d20 = d.opt20;
    res20(ind, :) = d20(1, :);
    ind = ind + 1;
end

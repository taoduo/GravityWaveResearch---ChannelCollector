% merge the opt mat files and append the power row
files = dir('opt_20_*.mat'); 
dat = zeros(40, 5);
ind = 1;
for i = 1 : length(files)
    disp(files(i).name)
    c = strsplit(files(i).name, '_');
    low = str2double(c{3});
    d = load(files(i).name);
    d = d.opt_20;
    for p = 1 : size(d, 1)
        dat(ind, :) = [low, d(p,:)];
        ind = ind + 1;
        low = low + 5;
    end
end

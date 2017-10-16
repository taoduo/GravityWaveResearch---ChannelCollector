% handle all mat in a folder all named e.g."2.0_10Hz.mat"
mat = dir('./stuff/*.mat'); 
for q = 1 : length(mat)
    % prepare the file
    load(strcat(mat(q).folder, '/', mat(q).name));
    dataArray = dataArray(~isinf(dataArray(:, 4)), :);
    % get info from file name
    [~, name, ~] = fileparts(strcat(mat(q).folder, '/', mat(q).name));
    tstr = strsplit(name, '_');
    pwr = str2double(tstr(1));
    i = int32(pwr / 0.5);
    cutf = tstr(2);
    % get the min Omega row
    [~, ind] = min(dataArray(:, 4));
    % save it to corresponding file
    if strcmp(cutf, '10Hz')
        opt_tot_10(i, 1) = pwr;
        opt_tot_10(i, 2) = dataArray(ind, 1);
        opt_tot_10(i, 3) = dataArray(ind, 2);
        opt_tot_10(i, 4) = dataArray(ind, 4);
    elseif strcmp(cutf, '15Hz')
        opt_tot_15(i, 1) = pwr;
        opt_tot_15(i, 2) = dataArray(ind, 1);
        opt_tot_15(i, 3) = dataArray(ind, 2);
        opt_tot_15(i, 4) = dataArray(ind, 4);
    elseif strcmp(cutf, '20Hz')
        opt_tot_20(i, 1) = pwr;
        opt_tot_20(i, 2) = dataArray(ind, 1);
        opt_tot_20(i, 3) = dataArray(ind, 2);
        opt_tot_20(i, 4) = dataArray(ind, 4);
    end
end


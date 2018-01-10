function channel(data_path, search, line, output_path)
	% Search for a line in a channel at data_path
	% data_path: the path to the mat file
	% search: configurations of this search (high / low /filter)
	% comb: parameters of the comb
	% output_path: the output path down to the jpg image

	freqs = [];
	coh = [];
	load(data_path);
	[~, channel_name, ~] = fileparts(data_path);
	freqGap = freqs(2) - freqs(1);
	[fp, cp] = search.chopData(data_path, freqs, coh, line); % 2Hz band
    if (fp == false)
		return;
    end
	if (search.filter ~= 0)
		offset = line.resolution;
        % get the indices
        window_low = floor((line.line - search.zoom) / freqGap) + 1;
		line_low = floor((line.line - offset) / freqGap) + 1;
		line_high = min(length(coh), ceil((line.line + offset) / freqGap) + 1);
        window_high = min(length(coh), ceil((line.line + search.zoom) / freqGap) + 1);
        % bg calculate
        background = coh([window_low:line_low - 1, line_high + 1:window_high]);
		% filter
        % get the line part
        fcp = coh(line_low : line_high);
		filt_max = max(fcp);
        filt_min = min(fcp);
        % get params of the model
        disp(background);
        pd = fitdist(background, 'Normal');
        ctr = pd.mu;
        stdd = pd.sigma;
        z0 = (0 - ctr) / stdd;
        z1 = (1 - ctr) / stdd;
        totarea = vpa(normcdf(vpa(z1)) - normcdf(vpa(z0)));
        % deviation calculation
        if (abs(filt_max - ctr) >= abs(filt_min - ctr))
            maxDev = filt_max - ctr;
        else
            maxDev = filt_min - ctr;
        end
        zdev = maxDev / stdd;
        if (maxDev > 0)
            logp = log10(vpa((normcdf(vpa(z1)) - normcdf(vpa(zdev))) / vpa(totarea)));
        else
            logp = log10(vpa((normcdf(vpa(zdev)) - normcdf(vpa(z0))) / vpa(totarea)));
        end
        if (logp < -16 && maxDev >= 0.025) % p-value should be less than 10^-16
            % output the significance as 
            % channel <tab> log p value            
            [weekpath,~,~] = fileparts(output_path);
            fd = fopen(fullfile(weekpath, 'sig.txt'), 'a');
            fprintf(fd, strcat(channel_name, '\t', num2str(ceil(p)), '\n'));
            fclose(fd);
            output(channel_name, fp, cp, line.line, output_path);
        end
	else
		output(channel_name, fp, cp, line.line, output_path);
	end
	clear;
end

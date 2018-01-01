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
        bg_avg = mean(background);
        bg_var = var(background);
		% filter
        fcp = coh(line_low : line_high);
		filt_max = max(fcp);
		if (abs(filt_max - bg_avg) >= bg_var * search.filter)
			output(channel_name, fp, cp, line.line, output_path);
		end
	else
		output(channel_name, fp, cp, line.line, output_path);
	end
	clear;
end

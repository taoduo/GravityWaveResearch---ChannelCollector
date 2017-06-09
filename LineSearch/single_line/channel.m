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
	[fp, cp] = search.chopData(data_path, freqs, coh, line);

	if (search.filter ~= 0)
		all_avg = mean(cp);
		offset = line.resolution;
		fl = floor((line.line - offset) / freqGap) + 1;
		fh = ceil((line.line + offset) / freqGap) + 1;
		fcp = coh(fl : fh);
		filt_max = max(fcp);
		if (filt_max >= all_avg * search.filter)
			output(channel_name, fp, cp, line.line, output_path);
		end
	else
		output(channel_name, fp, cp, line.line, output_path);
	end
	clear;
end

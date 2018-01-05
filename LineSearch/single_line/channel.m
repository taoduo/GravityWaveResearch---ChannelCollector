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
        bg_std = std(background);
        bg_omega = bg_std / sqrt(1 - 2 / pi);
		% filter
        fcp = coh(line_low : line_high);
		filt_max = max(fcp);
        md = median(cp);
        if (md < 0.5)
            if (abs(filt_max - bg_avg) >= bg_omega * search.filter)
                % output the significance as 
                % channel <tab> significance <tab> confidence
                sig = abs(filt_max - bg_avg) / bg_omega;
                p = erf(sig / sqrt(2));
                [weekpath,~,~] = fileparts(output_path);
                fd = fopen(fullfile(weekpath, 'sig.txt'), 'a');
                fprintf(fd, strcat(channel_name, '\t', num2str(sig), '\t', num2str(p), '\n'));
                fclose(fd);
                output(channel_name, fp, cp, line.line, output_path);
            end
        else
            if (abs(filt_max - bg_avg) <= 1 - bg_omega * search.filter)
                % output the significance as 
                % channel <tab> significance <tab> confidence
                sig = abs(filt_max - bg_avg) / bg_omega;
                p = erf(sig / sqrt(2));
                [weekpath,~,~] = fileparts(output_path);
                fd = fopen(fullfile(weekpath, 'sig.txt'), 'a');
                fprintf(fd, strcat(channel_name, '\t', num2str(sig), '\t', num2str(p), '\n'));
                fclose(fd);
                output(channel_name, fp, cp, line.line, output_path);
            end
        end
	else
		output(channel_name, fp, cp, line.line, output_path);
	end
	clear;
end

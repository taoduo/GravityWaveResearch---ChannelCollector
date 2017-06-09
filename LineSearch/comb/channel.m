function channel(data_path, search, comb, output_path)
	% Search for a comb in a channel at data_path
	% data_path: the path to the mat file
	% search: configurations of this search (high / low /filter)
	% comb: parameters of the comb
	% output_path: the output path down to the jpg image

	freqs = [];
	coh = [];
	load(data_path);
	freqGap = freqs(2) - freqs(1);
	[fp, cp] = search.chopData(freqs, coh, data_path);
	if (fp == false)
		return;
	end
	lines = comb.getLines();
	markPos = lines(lines >= search.low & lines <= search.high);
	if (search.filter ~= 0)
				sigCount = 0; % count the number of significant lines
				if (length(markPos) > 0)
						thres = mean(cp) * search.filter;
						for p = lines
								if ((ceil(p / freqGap) <= length(coh) && coh(ceil(p / freqGap)) >= thres) || (floor(p / freqGap) <= length(coh) && coh(floor(p / freqGap)) >= thres))
										sigCount = sigCount + 1;
								end
						end
				else
					disp(['Search range does not contain any line of the comb.']);
					search.dump();
					comb.dump();
				end
				if (sigCount < size(lines) / 3)
						return;
				end
	end
	[~, channel_name, ~] = fileparts(data_path);
	output(channel_name, fp, cp, search, comb, markPos, output_path);
	clear;
end

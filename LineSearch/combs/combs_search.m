function combs_search( dataPath, lowFreq, highFreq, combFreq, offset, filter_multiplier, output_path )
	% Search for a comb in all weeks, all channels
	% data_path: the path that contains all weeks folder
	% lowFreq: the lower search bound
	% highFreq: the higher search bound
	% combFreq: the gap between harmonics of the comb
	% offset: the start frequency of the comb
	% filter_multiplier: the filter (how much a significant data should be greater than the average)
	% output_path: the folder where all the week folders locate in
		% the output_path will be created
		% the structure is output_path/<weeks>/<figures>

	mkdir(output_path);
	files = dir(data_path);
	dirFlags = [files.isdir];
	weeks = files(dirFlags);
	weeks(1:2) = [];  
	for week = weeks'
		full_data = strcat(data_path, '/', week.name, '/data');
		outp = strcat(output_path, '/', week.name);
		mkdir(outp);
		if (exist(full_data))
			week_search(full_data, low, high, line_freq, outp, auto_filter_thresold);
		end
	end
	clear;
end

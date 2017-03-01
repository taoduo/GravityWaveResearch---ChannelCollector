function week_search(data_path, low, high, line_freq, output_path, auto_filter_thresold)
	% search for a line in all channels in a week at data_path
		% data_path: the path to the folder of mat files
		% low: the lower search bound
		% high: the higher search bound
		% line_freq: the frequency of the line, marked in figures
		% output_path: the folder where all the figures for this week to be saved at
	% apply_auto_filter: filter out irrelevant channels automatically, details see
	matFiles = dir(fullfile(data_path, '*.mat'));
	disp(['working on week ', data_path]);
	for file = matFiles'
		coh = [];
		freqs = [];
		fp = strcat(data_path, '/', file.name);
		[pathstr, namestr, ext] = fileparts(fp);
		op = strcat(output_path, '/', namestr, '.jpg');
		channel(fp, low, high, line_freq, op, auto_filter_thresold);
	end
	clear;
end

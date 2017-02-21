function line_search(data_path, low, high, line_freq, output_path, auto_filter_thresold)
	% search for a line in all weeks at data_path
	%  the data directory structure:
	%   data_path/<weeks_in_gps_time>/data/<data_of_this_week>
	% data_path: the path that contains all weeks folder
	% low: the lower search bound
	% high: the higher search bound
	% line_freq: the frequency of the line, marked in figures
	% output_path: the folder where all the week folders locate in
	%  the output_path will be created
	%  the structure is output_path/<weeks>/<figures>
	% apply_auto_filter: automatically filters out irrelevant channels, details see channel.m

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

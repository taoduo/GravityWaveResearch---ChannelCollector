function line_search_selected(data_path, low, high, line_freq, output_path, auto_filter_thresold, selected_weeks)
	% search for a line in selected weeks at data_path
	%  the data directory structure:
	%   data_path/<weeks_in_gps_time>/data/<data_of_this_week>
	% data_path: the path that contains all weeks folder
	% low: the lower search bound
	% high: the higher search bound
	% line_freq: the frequency of the line, marked in figures
	% output_path: the folder where the line_xx folder locates in
	%  the output_path will be created
	%  the structure is output_path/line_xx/<weeks>/<figures>
	%	 notices that we create the folder inside since we use the same folder name for all lines
	% apply_auto_filter: automatically filters out irrelevant channels, details see channel.m
	% selected_weeks: the weeks selected for search, as folder name.
	output_path = strcat(output_path, '/line_', num2str(line_freq));
	mkdir(output_path);
	files = dir(data_path);
	dirFlags = [files.isdir];
	for week = selected_weeks'
		full_data = strcat(data_path, '/', week, '/data');
		fprintf(week);
		outp = strcat(output_path, '/', week);
		if exist(full_data)
			week_search(full_data, low, high, line_freq, outp, auto_filter_thresold);
		else
			mkdir(strcat(outp, '_NODATA'));
		end
	end
	clear;
end

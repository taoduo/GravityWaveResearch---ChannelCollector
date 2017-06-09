function multiple_line_search(data_path, search, lines, output_path)
	% search for multiple lines in lines_array in all weeks at data_path
		%  the data directory structure:
		%  data_path/<weeks_in_gps_time>/data/<data_of_this_week>
	% data_path: the path that contains all weeks folder
	% search: the search configurations, which means that the search configurations for all the line should be the same
	% lines: the array of lines
	% output_path: the folder where all the line folders locate in
		%  the output_path will be created
		%  the structure is output_path/<lines>/<weeks>/<figures>
	mkdir(output_path);
	for line = lines
		line_search(data_path, search, line, output_path);
	end
end

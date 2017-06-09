function multiple_line_search(data_path, lines_array, output_path, auto_filter_thresold, resolution, selected_weeks)
	% search for multiple lines in lines_array in all weeks at data_path
		%  the data directory structure:
		%   data_path/<weeks_in_gps_time>/data/<data_of_this_week>
	% data_path: the path that contains all weeks folder
	% lines_array: [low1, high1, line1; low2, high2, line2; ...]
	% output_path: the folder where all the line folders locate in
		%  the output_path will be created
		%  the structure is output_path/<lines>/<weeks>/<figures>
	% apply_auto_filter: automatically filters out irrelevant channels, details see channel.m
	% resolution: the resolution of the line. The program will search within range of "line plusminus resolution"
	mkdir(output_path);
	for i = 1 : size(lines_array, 1)
		line_data = lines_array(i, :);
		search = Search(line_data(1), line_data(2), auto_filter_thresold, selected_weeks);
		line = Line(line_data(3), resolution);
		if nargin == 5
			line_search(data_path, search, line, output_path);
		end
		if nargin == 6
			line_search(data_path, search, line, output_path);
		end
	end
end

function multiple_line_search(data_path, lines_array, output_path, auto_filter_thresold)
	% search for multiple lines in lines_array in all weeks at data_path
		%  the data directory structure:
		%   data_path/<weeks_in_gps_time>/data/<data_of_this_week>
		% data_path: the path that contains all weeks folder
		% lines_array: [low1, high1, line1; low1, high2, line2; ...]
	% output_path: the folder where all the line folders locate in
		%  the output_path will be created
		%  the structure is output_path/<lines>/<weeks>/<figures>
	% apply_auto_filter: automatically filters out irrelevant channels, details see channel.m
	mkdir(output_path);
	for i = 1 : size(lines_array, 1)
		line = lines_array(i, :);
		line_search(data_path, line(1), line(2), line(3), strcat(output_path, '/line_', num2str(line(3))), auto_filter_thresold);
	end
end

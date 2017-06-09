function line_search(data_path, search, line, output_path)
	% Search for a line in all weeks, all channels
	% data_path: the path that contains all weeks folder
	% search: configurations of this search
	% comb: parameters of the line (see the structure Line)
	% output_path: the folder where all the week folders locate in
		% the output_path will be created
		% the structure is output_path/<weeks>/<plots>
	output_path = strcat(output_path, '/line_', num2str(line.line));
	mkdir(output_path);
	files = dir(data_path);
	dirFlags = [files.isdir];
	if length(search.selected_weeks) == 0 % search all weeks
		weeks = files(dirFlags);
		weeks(1:2) = [];
		for week = weeks'
			full_data = strcat(data_path, '/', week.name, '/data');
			outp = strcat(output_path, '/', week.name);
			if exist(full_data)
				week_search(full_data, search, line, outp);
			else
				mkdir(strcat(outp, '_NODATA'));
			end
		end
	else
		for w = search.selected_weeks' % search the selected weeks
			week = transpose(w);
			full_data = strcat(data_path, '/', week, '/data');
			outp = strcat(output_path, '/', week);
			if exist(full_data)
				week_search(full_data, search, line, outp);
			else
				mkdir(strcat(outp, '_NODATA'));
			end
		end
	end
	clear;
end

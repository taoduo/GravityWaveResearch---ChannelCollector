function comb_search(data_path, search, comb, output_path)
	% Search for a comb in all weeks, all channels
	% data_path: the path that contains all weeks folder
	% search: configurations of this search (high / low /filter)
	% comb: parameters of the comb (see the structure Comb)
	% output_path: the folder where all the week folders locate in
		% the output_path will be created
		% the structure is output_path/<weeks>/<plots>

	output_path = strcat(output_path, '/comb_', num2str(comb.comb));
	files = dir(data_path);
	dirFlags = [files.isdir];
	weeks = files(dirFlags);
	weeks(1:2) = [];  % remove the two folders . and ..
	for week = weeks'
		week_data = strcat(data_path, '/', week.name, '/data');
		week_output = strcat(output_path, '/', week.name);
		if (exist(week_data)) % sometimes they do not have the data folder
			mkdir(output_path);
			week_search(week_data, search, comb, week_output);
		end
	end
end

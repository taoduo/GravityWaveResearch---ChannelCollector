function week_search(data_path, search, comb, output_path)
	% Search for a comb in all channels in a week at data_path
	% data_path: the path that contains all weeks folder
	% search: configurations of this search (high / low /filter)
	% comb: parameters of the comb (see the structure Comb)
	% output_path: the folder where all the week folders locate in
		% the output_path  be created
		% the structure is output_path/<weeks>/<figures>
	mkdir(output_path);
	matFiles = dir(fullfile(data_path, '*.mat'));
	disp(['working on week ', data_path]);
	for channel = matFiles'
		channel_data = strcat(data_path, '/', channel.name);
		[~, namestr, ~] = fileparts(data_path);
		channel_output = strcat(output_path, '/', namestr, '.jpg');
		channel(channel_data, search, comb, channel_output);
	end
end

function week_search(data_path, search, line, output_path)
	% Search for a line in all channels in a week at data_path
	% data_path: the path that contains all weeks folder
	% search: configurations of this search (high / low /filter)
	% line: parameters of the line (see the structure Comb)
	% output_path: the folder where all the week folders locate in
		% the output_path  be created
		% the structure is output_path/<weeks>/<plots>
	mkdir(output_path);
	matFiles = dir(fullfile(data_path, '*.mat'));
	disp(['working on week ', data_path]);
	for chn = matFiles'
		channel_data = strcat(data_path, '/', chn.name);
		[~, namestr, ~] = fileparts(channel_data);
		channel_output = strcat(output_path, '/', namestr, '.jpg');
		channel(channel_data, search, line, channel_output);
	end
	clear;
end

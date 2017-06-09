This module search for a line in data of all weeks.
To use, call

1. To use, call
`multiple_line_search(data_path, lines_array, output_path, auto_filter_thresold, resolution, [selection_weeks])`
	* data_path: the path that contains all weeks folder
	* lines_array: [low(lower search bound), high(higher search bound), line(frequency of the line)]
	* output_path: the folder where all the week folders locate in
		- the output_path will be created
		- the structure is output_path/\<weeks\>/\<figures\>
	* auto_filter_thresold: automatically filters out irrelevant channels, details see channel.m
	* resolution: the resolution of the line. This would require that all lines within a single `multiple_line_search()` call should have the same resolution.
	* selected_weeks: optional argument. The weeks selected for search, as folder name.
2. hierarchical structure of the files: multiple_line_search -> line_search -> week_search -> channel -> output

Details for those files are found in the in-file documents. They can be used for other types of searches

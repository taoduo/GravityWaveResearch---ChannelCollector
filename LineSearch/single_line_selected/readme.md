This module search for a line in data of selected weeks.


1. To use, call
`multiple_line_search_selected(data_path, lines_array, output_path, auto_filter_thresold, selected_weeks)`
	* data_path: the path that contains all weeks folder
	* lines_array: [low(lower search bound), high(higher search bound), line(frequency of the line)]
	* output_path: the folder where all the week folders locate in
		- the output_path will be created
		- the structure is output_path/\<weeks\>/\<figures\>
	* auto_filter_thresold: automatically filters out irrelevant channels, details see channel.m
	* selected_weeks: the weeks selected for search, as folder name.
2. hierarchical structure of the files: multiple_line_search_selected -> line_search_selected -> week_search -> channel -> output

Details for those files are found in the in-file documents. They can be used for other types of searches

function arr = line_array(lines, run, observatory, resolution)
	% Create an array of Line object
	for i = length(lines) : -1 : 1
		arr(i) = Line(lines(i), run, observatory, resolution);
	end
end

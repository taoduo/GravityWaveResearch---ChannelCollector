function arr = line_array(lines, resolution)
	% Create an array of Line object
	for i = 1 : length(lines)
		arr(i) = Line(lines(i), resolution);
	end
end

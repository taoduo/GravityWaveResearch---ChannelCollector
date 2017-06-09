function arr = line_array(lines, resolution)
	% Create an array of Line object
	arr = zeros(1, length(lines));
	for i = 1 : length(lines)
		line = Line(lines(i), resolution);
		arr(i) = line;
	end
end

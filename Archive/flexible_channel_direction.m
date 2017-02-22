function [ npath ] = flexible_channel_direction( path )
% file to path does not exist, see if exist in other directions
% if so return the one that exists
% if not return empty
[parent, filename, ext] = fileparts(path);
matches = strfind(filename, '_X_');
nf = isempty(matches);
if nf
    matches = strfind('_Y_', filename);
    nf = isempty(matches);
end
if nf
    matches = strfind('_Z_', filename);
    nf = isempty(matches);
end

npath = '';
if ~nf
    pos = matches(1);
    px = strcat(parent, '/', strcat(filename(1 : pos - 1), '_X_', filename(pos + 3: length(filename))), ext);
    py = strcat(parent, '/', strcat(filename(1 : pos - 1), '_Y_', filename(pos + 3: length(filename))), ext);
    pz = strcat(parent, '/', strcat(filename(1 : pos - 1), '_Z_', filename(pos + 3: length(filename))), ext);
    if exist(px, 'file')
        npath = px;
    elseif exist(py, 'file')
        npath = py;
    elseif exist(pz, 'file')
        npath = pz;
    end
end
end

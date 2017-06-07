function [] = check_memory()
  [r,w] = unix('free | grep Mem');
  stats = str2double(regexp(w, '[0-9]*', 'match'));
  freemem = (stats(3)+stats(end))/1e6;
  disp(num2str(freemem));
end

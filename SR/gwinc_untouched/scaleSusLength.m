% ifo = scaleSusMass(ifo, massScaleFactor)
%    compute new suspension parameters for longer suspensions
%
% This function scales the suspension parameters (length, etc.)
% for longer suspensions.

function ifo = scaleSusLength(ifo, lengthScale)

  % extract the suspension parameters
  sus = ifo.Suspension;
  
  % Note stage numbering: mirror is 1, top mass is at end
  for n = 1:numel(sus.Stage)
    % length
    sus.Stage(n).Length = sus.Stage(n).Length * lengthScale;

  end
    
  % assign new sus back to ifo struct
  ifo.Suspension = sus;
  
end

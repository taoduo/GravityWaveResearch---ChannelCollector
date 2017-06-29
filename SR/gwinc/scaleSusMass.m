% ifo = scaleSusMass(ifo, massScaleFactor)
%    compute new suspension parameters for heavier masses
%
% This function scales the suspension parameters (wire radius,
% blade springs, fiber taper, etc.) for larger masses.

function ifo = scaleSusMass(ifo, massScale)

  % extract the suspension parameters
  sus = ifo.Suspension;
  
  % related scale factors
  sqrtMass = sqrt(massScale);
  lenScale = massScale^(1/3);
  
  % Note stage numbering: mirror is 1, top mass is at end
  for n = 1:numel(sus.Stage)
    % mass
    sus.Stage(n).Mass = sus.Stage(n).Mass * massScale;

    % vertical spring constant
    sus.Stage(n).K = sus.Stage(n).K * massScale;
    
    % blade thickness
    %  K scales as width * (thickness / length)^3
    %  assume that the length of the blade scales with the
    %  size of the masses (e.g., mass^(1/3)), 
    %  then K scales as width * thickness^3 / mass.
    %  We need K to scale as mass, so let thickness and width
    %  scale with sqrt(mass).
    sus.Stage(n).Blade = sus.Stage(n).Blade * sqrtMass;

    % wire area scales with mass
    sus.Stage(n).WireRadius = sus.Stage(n).WireRadius * sqrtMass;
  end
  
  %%%%%%%%%%
  % last stage parameters
  sus.Ribbon.Thickness = sus.Ribbon.Thickness * sqrtMass;
  sus.Ribbon.Width     = sus.Ribbon.Width * sqrtMass;
  sus.Fiber.Radius     = sus.Fiber.Radius * sqrtMass;
  
  % taper avoids thermal noise by maintaining T / A
  % T scales with mass, so A must also (which is fortunate)
  sus.Fiber.EndRadius  = sus.Fiber.EndRadius * sqrtMass;
  
  % assign new sus back to ifo struct
  ifo.Suspension = sus;
  
  %%%%%%%%%%
  % mirror parameters, maintain aspect ratio
  ifo.Materials.MassRadius = ifo.Materials.MassRadius * lenScale;
  ifo.Materials.MassThickness = ifo.Materials.MassThickness * lenScale;

end

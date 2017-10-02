function luminosityDistance = comoving_to_luminosity(comovingDistance, z)

    luminosityDistance = comovingDistance.*(1+z);
    
end
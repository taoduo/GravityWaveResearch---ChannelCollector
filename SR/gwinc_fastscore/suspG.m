function n = suspG(f, ifo)

load susGiles4080.mat

if (ifo.Suspension.Type == 40)
    ff = sus40.f;
    hh = sus40.h;

else (ifo.Suspension.Type == 80)
   ff = sus80.f;
   hh = sus80.h;
end

n = interp1(ff, hh, f, [], 0);
n = n.^2;
end

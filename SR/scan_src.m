% scan configurations
finenessReflectivity = 0.001;
minReflectivity = 0.0;
maxReflectivity = 1 - finenessReflectivity;
finenessPhase = 1 / 360 * 2 * pi;
maxPhase = 2 * pi;

% scan results
optOmega = 1;
optReflectivity = 0;
optPhase = 0;


bnsArray = zeros(int64((maxReflectivity / finenessReflectivity) * (maxPhase / finenessPhase)), 3);
n = 1;

for reflectivity = minReflectivity : finenessReflectivity : maxReflectivity 
    for phase = 0 : finenessPhase : maxPhase
        ifo = IFOModel;
        src = SourceModel;
        try
            score = gwinc(10, 3000, ifo, src, 2, 125, phase, 1 - reflectivity - ifo.Optics.Loss);
            bnsArray(n,:) = [reflectivity, rad2deg(phase), score.NeutronStar.comovingRangeMpc];
            n = n + 1;
            if optOmega > score.Omega
                optOmega = score.Omega;
                optPhase = phase;
                optReflectivity = reflectivity;
            end
            % fprintf('refl:%f\tphase:%d\tOptOmega:%1.4e\n', reflectivity, int32(rad2deg(phase)), optOmega);
        catch e
            fprintf('refl:%f\tphase:%d\tERROR\n', reflectivity, int32(rad2deg(phase)));
        end
    end
end
save('results.mat');
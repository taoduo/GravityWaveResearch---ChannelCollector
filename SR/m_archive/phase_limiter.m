% update the results with raw mat files
for p = ["0.5", "1.0", "1.5", "2.0"]
    for c = ["10Hz", "15Hz", "20Hz"]
        load(strcat("./a/", p, "_", c, ".mat"))
        dataArray(dataArray(:,2)>90,:) = [];
        [v,ind] = min(dataArray(:,4));
        trans = dataArray(ind, 1);
        phase = dataArray(ind, 2);
        omega = dataArray(ind, 3);
        t = gwinc(10, 3000, IFOModel, SourceModel, 2, str2double(p), deg2rad(phase), trans);
        omegaAlt = t.Omega;
        ind1 = int32(str2double(p) / 0.5);
        if c == "10Hz"
            opt_10(ind1, 2) = trans;
            opt_10(ind1, 3) = phase;
            opt_10(ind1, 4) = omega;
            opt_10(ind1, 5) = omegaAlt;
        elseif c == "15Hz"
            opt_15(ind1, 2) = trans;
            opt_15(ind1, 3) = phase;
            opt_15(ind1, 4) = omega;
            opt_15(ind1, 5) = omegaAlt;
        elseif c == "20Hz"
            opt_20(ind1, 2) = trans;
            opt_20(ind1, 3) = phase;
            opt_20(ind1, 4) = omega;
            opt_20(ind1, 5) = omegaAlt;
        end
    end
end

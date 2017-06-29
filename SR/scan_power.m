p = 1 : 400;
powerArray = zeros(numel(p), 3);

for i = 1 : numel(p)
    score=gwinc(10,3000,IFOModel,SourceModel,2,p(i),0,0.33);
    powerArray(i,:) = [p(i), score.Omega, score.NeutronStar.comovingRangeMpc];
end

save('power.mat', 'powerArray');
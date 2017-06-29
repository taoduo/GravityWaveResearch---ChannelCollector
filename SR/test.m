ifo = IFOModel;
sm = SourceModel;
iter = [2,3,4,5];
times = zeros(1, numel(iter));
for i = 1 : numel(iter)
    t = cputime;
    for j = 1 : iter(i)
        score = gwinc(10, 3000, ifo, sm, 2, 125, 0, 0.33);
    end
    times(i) = cputime - t;
end
scatter(iter, times);
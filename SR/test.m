ifo = IFOModel;
sm = SourceModel;
iter = [10,20,30,40,50];
times = zeros(1, numel(iter));
for i = 1 : numel(iter)
    t = cputime;
    for j = 1 : iter(i)
        score = gwinc(10, 3000, ifo, sm, 2, 125, 0, 0.33);
    end
    times(i) = cputime - t;
end
scatter(iter, times);
p = polyfit(iter, times,2);
fprintf('avg time:%f', p(2));
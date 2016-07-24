fig=figure;
hax=axes;
x=0:0.1:10;
hold on
plot(x,sin(x))
SP={2,3}; %your point goes here
for i = 1 : length(SP)
    line([i i],get(hax,'YLim'),'Color',[1 0 0])
end
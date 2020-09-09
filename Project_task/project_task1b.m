load bostemp

days = (1:31*24)/24;
window = 50;
filter = ones(1,window)/window;
filterY = conv(tempC, filter, 'same');
plot(days,tempC,days,filterY)


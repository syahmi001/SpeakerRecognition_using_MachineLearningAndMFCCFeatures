days = (1:31*24)/24;
hoursPerDay = 24;
coeff24hMA = ones(1, hoursPerDay)/hoursPerDay;
avg24hTempC = filter(coeff24hMA, 1, tempC);
fDelay = (length(coeff24hMA)-1)/2;
plot(days,tempC, ...
     days-fDelay/24,avg24hTempC)
axis tight
legend('Hourly Temp','24 Hour Average','location','best')
ylabel('Temp (\circC)')
xlabel('Time(days)')
title('Graph Temperature VS days (31 days)')
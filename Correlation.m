% Computation of the correlation between the S&P 500 and the VIX indexes
clc
clear all

% Download the data
sp500 = readtable("S&P_500_daily.csv");
vix = readtable("VIX_daily.csv");

% Create S&P 500 and VIX arrays
dates_sp500 = table2array(sp500(:,1));
values_sp500 = table2array(sp500(:,5));
dates_vix = table2array(vix(:,1));
values_vix = table2array(vix(:,5));

% Check if the dates are equal between S&P 500 and VIX
a = isequal(dates_sp500,dates_vix);
if a == 0
    disp("CHECK IF DATES ARE SIMILAR")
    return
end

% Compute the correlation
correlation = corr(values_sp500, values_vix);

% Plot the S&P 500 and the VIX in the same graph
title("S&P 500 VS VIX")
yyaxis left
plot(datetime(dates_sp500), values_sp500, 'b'), xlabel("Dates"), ylabel("S&P 500")
hold on
yyaxis right
plot(datetime(dates_sp500), values_vix, 'r'), xlabel("Dates"), ylabel("VIX")
hold off
legend("S&P 500","VIX")
saveas(gcf, "S&P500_VIX.jpg")
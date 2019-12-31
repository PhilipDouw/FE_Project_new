function [price, iv] = evaluateSpline(u, tau, g, gamma, close, strike, ...
    interestrate, maturity, dividendyield)
% function to evaluate smoothing spline based on g and gamma

T = length(tau);
price = zeros(size(maturity));
for t = 1:T
    pos_maturity = maturity==tau(t);
    price(pos_maturity) = fitSpline(strike(pos_maturity), u(:,t), g(:,t), gamma(:,t));
end

iv = blsimpv(close, strike, interestrate, maturity, price, [], dividendyield);

end

function [call_price, kappa, tau, forward, interestrate, dividendyield] = ...
    pre_smoother(kappa, moneyness, maturity, ...
    implied_volatility, forward, interestrate, dividendyield, forward_smooth,...
    maturity_interp, forward_interp, interestrate_interp, dividendyield_interp)
% function to perform pre-smoothing using thin-plate splines. The function
% estimates the call-price function for each observed maturity and added
% maturity_interp at any observed moneyness (for any maturity).
% Input:
% * kappa              = (Mx1)  = moneyness at which splines are evaluated,
%                                 if empty, use unique(moneyness)
% * moneyness          = (Nx1)  = moneyness (K/F) of options
% * maturity           = (Nx1)  = maturity (T-t/365.25) of options
% * implied_volatility = (Nx1)  = implied volatility of options
% * forward            = (Nx1)  = forward value of underlying corresponding
%                                   to maturity
% * interestrate       = (Nx1)  = annualized continuously compounded interest rate
%                                   corresponding to maturity
% * dividendyield      = (Nx1) = annualized continuous dividend yield
%                                   correponding to maturity
% * maturity_interp = (Tix1) = maturities at which to interpolate ivs
% * forward_interp  = (Tix1) = forwards corresponding to maturity_interp
% * interestrate_interp  = (Tix1) = interest rates corresponding to maturity_interp
% * dividendyield_interp = (Tix1) = dividend yields corresponding to maturity_interp
% Output:
% * call_price = (KxT) = smoothed prices for each kappa-tau combination
% * kappa      = (Kx1) = moneynesses at which prices have been estimated
% * tau        = (Tx1) = maturities at which prices have been estimated

% thin-plate spline
x = [moneyness'; maturity'];
y = (implied_volatility.^2 .* maturity)';
warning('off');
[thin_plate_spline] = tpaps(x,y, 1);
warning('on');

% get moneyness points
if isempty(kappa)
    kappa = sort(unique(moneyness));
end

% get maturity points and resort data so that it corresponds to tau
[tau, idx] = unique(maturity);
forward = forward(idx);
interestrate = interestrate(idx);
dividendyield = dividendyield(idx);

% add maturity_interp to maturity 
if ~isempty(maturity_interp)
    tau           = [tau;           maturity_interp];
    forward       = [forward;       forward_interp];
    interestrate  = [interestrate;  interestrate_interp];
    dividendyield = [dividendyield; dividendyield_interp];
end

% sort tau
[tau, idx]   = sort(tau);
forward = forward(idx);
interestrate = interestrate(idx);
dividendyield = dividendyield(idx);

[X,Y] = meshgrid(kappa,tau);
X = reshape(X,1,numel(X));
Y = reshape(Y,1,numel(Y));
XY = [X; Y];
total_variance_interpolated = fnval(thin_plate_spline,XY);

% remove all kappas where total variance is non-positive
if any(total_variance_interpolated<=0)
    pos_neg = total_variance_interpolated<=0;
    kappas_neg = unique(X(pos_neg));
    pos_delete = ismember(X,kappas_neg);
    total_variance_interpolated = total_variance_interpolated(~pos_delete);
    X = X(~pos_delete);
    Y = Y(~pos_delete);
    kappa = kappa(~ismember(kappa, kappas_neg));
end
    
implied_volatility_interpolated = sqrt(total_variance_interpolated./Y)';



% first option uses regular option price, second uses forward prices
[~, idx] = ismember(Y,tau);
call_price = exp(-interestrate(idx).*Y') .* forward(idx).*blsprice(1, X', 0, Y', implied_volatility_interpolated, 0);

% ensure that output dimensions are correct
call_price    = reshape(call_price,   length(tau), length(kappa))'; %each column is one smile
tau = tau(:);
kappa = kappa(:);
end
function [u, tau, g, gamma] = ivs_smoothed(put_price, close, strike, ...
    maturity, interestrate, dividendyield, implied_volatility, ...
    maturity_interp, forward_interp, interestrate_interp, dividendyield_interp)
% function to perform arbitrage-free smoothing of the implied volatility
% surface according to Fengler (2009). The first step is a regular (rough)
% interpolation of the ivs to obtain values on a regular moneyness-maturity
% grid. The second step uses smoothing spines under constraints to obtain a
% smooth and arbitrage-free pricing surface which is then translated to
% implied volatilities.
% Input:
% * put_price   = (Nx1)  = market prices of call options
% * close        = (Nx1)  = closing price of underlying (all the same value or scalar)
% * strike       = (Nx1)  = strike price of call options
% * maturity     = (Nx1)  = time to maturity of the call options
% * interestrate = (Nx1)  = annualized continuously compounded interest rate
%                           corresponding to maturity (can be scalar)
% * dividendyield = (Nx1) = annualized continuous dividend yield
%                           correponding to maturity (can be scalar)
% * implied_volatility = (Nx1) = implied volatilities of options
% * maturity_interp = (Tix1) = maturities at which to interpolate ivs
% * forward_interp  = (Tix1) = forwards corresponding to maturity_interp
% * interestrate_interp  = (Tix1) = interest rates corresponding to maturity_interp
% * dividendyield_interp = (Tix1) = dividend yields corresponding to maturity_interp
% Output:
% * u   = (Kx1) = nodes of the spline
% * tau = (Tx1) = maturities at which the spline was constructed
% * g   = (KxT) = value at nodes of the spline
% * gamma = (KxT) = second derivative of spline at nodes

% make sure that input vectors are column vectors
put_price = put_price(:);
close = close(:);
strike = strike(:);
maturity = maturity(:);
interestrate = interestrate(:);
dividendyield = dividendyield(:);

% make vectors out of scalar input
N = length(put_price);
if numel(close)==1
    close = close*ones(N,1);
end
if numel(interestrate)==1
    interestrate = interestrate*ones(N,1);
end
if numel(dividendyield)==1
    dividendyield = dividendyield*ones(N,1);
end

% make sure that input has the correct dimensions
if~(size(put_price) == size(close) == size(strike) == size(maturity) == ...
        size(interestrate) == size(dividendyield))
    error('Non-conforming Input');
end

if nargin == 7
    maturity_interp = [];
    forward_interp  = [];
    interestrate_interp = [];
    dividendyield_interp = [];
else
    maturity_interp = maturity_interp(:);
    forward_interp  = forward_interp(:);
    interestrate_interp = interestrate_interp(:);
    dividendyield_interp = dividendyield_interp(:);  
end

if isempty(implied_volatility)
    implied_volatility = blsimpv(close, strike, interestrate, maturity, put_price, [], dividendyield);
end


% step 1: pre-smoother
forward = close.*exp((interestrate-dividendyield).*maturity);
moneyness = strike./forward;
kappa = (ceil(min(moneyness*10))/10):0.05:(floor(max(moneyness*10))/10);
[put_price, kappa, tau, forward_tau, interestrate_tau, dividendyield_tau] = ...
    pre_smoother(kappa, moneyness, maturity, implied_volatility, forward, interestrate, dividendyield, ...
    maturity_interp, forward_interp, interestrate_interp, dividendyield_interp);

% step2: iterative smoothing of pricing surface
T = length(tau);
K = length(kappa);

g = zeros(K,T);
gamma = zeros(K,T);
u = zeros(K,T);
S = unique(close);

for t = T:-1:1
    u(:,t) = kappa*forward_tau(t);
    y = put_price(:,t);
    
    n = length(u(:,t));
    h = diff(u(:,t));
    % inequality constraints A x <= b
    % -(g_2 - g_1)/h_1 + h_1/6 gamma(2) <= e^(-tau*r)
    %  (g_n - g_(n-1))/h_(n-1) + h_(n-1)/6 gamma(n-1) <= 0
    A = [1/h(1) -1/h(1) zeros(1,n-2) h(1)/6 zeros(1,n-3);
        zeros(1,n-2) -1/h(n-1) 1/h(n-1) zeros(1,n-3) h(n-1)/6];
    b = [exp(-tau(t)*interestrate(t)); 0];
    
    % set-up lb
    lb = [max(S*exp(-dividendyield_tau(t)*tau(t))-u(:,t)'*exp(-interestrate_tau(t)*tau(t)),0) zeros(1,n-2)];
    
    
    % set-up ub
    if t==T
        ub = [S*exp(-dividendyield_tau(t)*tau(t)) inf(1,2*n-3)];
    else
        ub = [exp(0.5*(dividendyield_tau(t)+dividendyield_tau(t+1))*(tau(t+1)-tau(t)))*g(:,t+1)' inf(1,n-2)];
    end
    
    
    
    [g(:,t), gamma(:,t)] = quadratic_program(u(:,t), y, A, b, lb, ub);
    
    
end


end
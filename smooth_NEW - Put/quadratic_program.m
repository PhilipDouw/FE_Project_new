function [g, gamma] = quadratic_program(u, y, A, b, lb, ub, lambda)
% function to estimate the quadratic program of the Implied Volatility
% Surface smoothing algorithm as described on p.18 of Fengler (2005).
% Input:
%   u      = (nx1)    = moneyness of nodes
%   y      = (nx1)    = call prices at nodes
%   A      = (mx2n-2) = Matrix for linear inequality (Ax <= b)
%   b      = (mx1)    = Vector of inequality values
%   lb     = (2n-2x1) = lower bound
%   ub     = (2n-2x1) = upper bound
%   lambda = scalar = Smoothing parameter
% Output:
%   g     = (nx1) = vector of smoothed call option prices
%   gamma = (nx1) = vector of second derivatives at nodes

n = length(u);

if nargin == 6
    lambda = 1e-2;
end

% ensure column vectors
u = u(:);
y = y(:);

% check that input is consistent
if length(y) ~= length(u)
    error('length of y is incorrect');
end

if any(ub-lb<0)
    pos_neg = ub-lb<0;
    lb(pos_neg) = ub(pos_neg);
end

% set up estimation and restriction matrices
h = diff(u,1);

Q = zeros(n,n-2);
for j = 2:(n-1)
    Q(j-1,j-1) = h(j-1)^(-1);
    Q(j,  j-1) = -h(j-1)^(-1) - h(j)^(-1);
    Q(j+1,j-1) = h(j)^(-1);
end
R = zeros(n-2,n-2);
for i = 2:(n-1)
    R(i-1,i-1) = 1/3*(h(i-1)+h(i));
    if i < n-1
        R(i-1,i+1-1) = 1/6*h(i);
        R(i+1-1,i-1) = 1/6*h(i);
    end
end

% set-up problem min_x -y'x + 0.5 x'Bx

% linear term
y = [y;zeros(n-2,1)];

%quadratic term
B = [diag(ones(n,1)) zeros(n,size(R,2)); zeros(size(R,1),n) lambda*R]; 

% initial guess
x0 = y; 
x0(n+1:end) = 1e-3;

% equality constraint Aeq x = beq
Aeq = [Q; -R']';
beq = zeros(size(Aeq,1),1);

% estimate the quadratic program
options = optimoptions('quadprog');
options = optimoptions(options, 'Algorithm', 'interior-point-convex', 'Display','off');
x = quadprog(B, -y, A, b, Aeq, beq, lb, ub, x0, options);

% First n values of x are the points g_i
g = x(1:n);

% Remaining values of x are the second derivatives
gamma = [0; x(n+1:2*n-2); 0];
    
end
function y = fitSpline(v, u, g, gamma)
% Fit the natural cubic splines according to Green and Silverman, 1994, 
% Equation (2.22).
% Input:
% * v     = (mx1) = coordinates at which to evaluate the spline
% * u     = (nx1) = coordinates of spline nodes
% * g     = (nx1) = spline value at nodes
% * gamma = (nx1) = second derivatives of spline at nodes
% Output:
% * y     = (mx1) = Values of spline at v

v = v(:);
u = u(:);
g = g(:);
gamma = gamma(:);

% make sure that input is sorted
[u, idx] = sort(u);
g = g(idx);
gamma = gamma(idx);

% Inputs
n = length(u);
m = length(v);
y = zeros(m,1);

for s=1:m
    for i=1:n-1
        h = u(i+1) - u(i);
        if (u(i) <= v(s)) && (v(s) <= u(i+1))
               y(s) = ((v(s)-u(i))*g(i+1) + (u(i+1)-v(s))*g(i))/h ...
                    - 1/6*(v(s)-u(i))*(u(i+1)-v(s)) ...
                    * ( (1+(v(s)-u(i))/h)*gamma(i+1) + (1+(u(i+1)-v(s))/h)*gamma(i)) ;
        end
    end
    
    if v(s) < min(u)
        dg = (g(2)-g(1))/(u(2)-u(1)) - 1/6*(u(2)-u(1))*gamma(2);
        y(s) = g(1) - (u(1) - v(s))*dg;
    end
    
    if v(s) > max(u)
        dg = (g(n)-g(n-1))/(u(n)-u(n-1)) + 1/6*(u(n)-u(n-1))*gamma(n-1);
        y(s) = g(n) + (v(s) - u(n))*dg;
    end
end

end
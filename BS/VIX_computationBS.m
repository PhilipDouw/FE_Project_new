% Matrix with folowing columns:
    % 1: Strikes from K_min to K_max
    % 2: Put prices
    % 3: Call prices
    % 4: Difference Put-Call
    % 5: Interval between strikes
    % 6: Call / Put and midpoint prices used for VIX calculation
    % 7: Contribution by strike

    
function [Matrix, VIX, VIXerror] = VIX_computationBS(S , K_min, K_max, interval, r, T, sigma)
    
    [Matrix, F_zero, K_zero] = PutCallBS(S , K_min, K_max, interval, r, T, sigma);

    % 7th column: the contribution of each OTM option:
    x = 0;
    for k = 1 : length(Matrix)
        Matrix(k,7) = (interval/(Matrix(k,1))^2) * exp(r * T) * Matrix(k,6);
        x = x + Matrix(k,7);
    end

    % Whole VIX Index formula:
    sigmaVIXsquared = 2 / T * sum(x) - 1 / T * (F_zero / K_zero - 1)^2;

    % final VIX calculation:
    VIX = 100* sqrt(sigmaVIXsquared);

    % Calculating the error:
    VIXerror = VIX/100 - sigma;
end
    
 
   
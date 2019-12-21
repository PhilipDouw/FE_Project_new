% Calculating VIX using simulated option prices via Bates:
    
function [Matrix, VIX, VIXerror] = VIX_computationBates(S , K_min, K_max, interval, r, T, sigma)
    
    [Matrix, F_zero, K_zero] = PutCallBates(S , K_min, K_max, interval, r, T, sigma);
    
    % Need to convert time which is set in months for bates to time in years
    
    Temp = T/12;

    % 7th column: the contribution of each OTM option:
    x = 0;
    for k = 1 : length(Matrix)
        Matrix(k,7) = (interval/(Matrix(k,1))^2) * exp(r * Temp) * Matrix(k,6);
        x = x + Matrix(k,7);
    end

    % Whole VIX Index formula:
    sigmaVIXsquared = 2 / Temp * sum(x) - 1 / Temp * (F_zero / K_zero - 1)^2;

    % final VIX calculation:
    VIX = 100* sqrt(sigmaVIXsquared);

    % Calculating the error:
    VIXerror = VIX/100 - sigma;
end
    
 
   
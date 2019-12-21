function [Matrix, ExpansionError] = ExpansionBS(S , K_min, K_max, interval, r, T, sigma)
    
    [Matrix, F_zero, K_zero] = PutCallBS(S , K_min, K_max, interval, r, T, sigma);
    
    ExpansionError = 2/T * [[(F_zero / K_zero - 1) - 1/2*(F_zero / K_zero - 1)^2] - log(F_zero / K_zero)];
    
end
% Truncation error:

function [TruncError,TruncErrPercentage] = TruncationBates(S, K_min, K_max, r, T, sigma)

Temp = T/12;

% Truncation error formula:
TruncError = -2/T * exp(r*Temp) * [(integral(@(K) putBates(S, K, r, T, sigma)/K^2,0,K_min,'ArrayValued',true)) + ...
            +(integral(@(K) callBates(S, K, r, T, sigma)/K^2,K_max,inf,'ArrayValued',true))];

% Calculating Truncation error in percentage of sigma:
TruncErrPercentage = TruncError / sigma;

end
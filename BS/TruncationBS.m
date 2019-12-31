% Truncation error:

function [TruncError,TruncErrPercentage] = TruncationBS(S, K_min, K_max, r, T, sigma)

    % Truncation error formula:
    TruncError = -2/T * exp(r*T) * [(integral(@(K) putBS(S, K, r, T, sigma)/K^2,0,K_min,'ArrayValued',true)) + ...
                +(integral(@(K) callBS(S, K, r, T, sigma)/K^2,K_max,inf,'ArrayValued',true))]

    % Calculating Truncation error in percentage of sigma:
    TruncErrPercentage = TruncError / sigma;

end
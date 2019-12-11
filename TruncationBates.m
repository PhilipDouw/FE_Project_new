function [TruncError,TruncErrPercentage] = TruncationBates(S, K_min, K_max, r, T, sigma)
      
TruncError = -2/T * exp(r*T) * [(integral(@(K) putBates(S, K, r, T, sigma)/K^2,0,K_min,'ArrayValued',true)) + ...
                   +(integral(@(K) callBates(S, K, r, T, sigma)/K^2,K_max,inf,'ArrayValued',true))]

TruncErrPercentage = TruncError / sigma

end
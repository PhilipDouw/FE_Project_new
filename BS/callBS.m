function Call = callBS(S, K, r, T, sigma)

    [Call, Put] = blsprice(S, K, r, T, sigma); 

end
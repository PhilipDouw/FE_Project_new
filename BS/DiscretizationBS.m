% Discretisation error:

function DiscrError = DiscretizationBS(S, K_min , K_max, interval, r, T, sigma)

    [Matrix, F_zero, K_zero] = PutCallBS(S , K_min, K_max, interval, r, T, sigma);

    % 7th column: the contribution of each OTM option:
    x = 0;
    for k = 1 : length(Matrix)
        Matrix(k,7) = (interval/(Matrix(k,1))^2) * Matrix(k,6);
        x = x + Matrix(k,7);
    end

    % Discretisation error formula:

    DiscrError = 2/T * exp(r * T) * ( sum(x) - ([(integral(@(K) putBS(S, K, r, T, sigma)/K^2,K_min,K_zero,'ArrayValued',true)) + ...
               +(integral(@(K) callBS(S, K, r, T, sigma)/K^2,K_zero,K_max,'ArrayValued',true))]) );

end
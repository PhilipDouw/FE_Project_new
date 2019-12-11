function DiscrError = DiscretizationBates(S , K, K_min , K_max, interval, r, T, sigma)

Matrix = PCMatrixBates(S, K_min, K_max, interval, r, T, sigma);

    sum = 0;
    j = 1;
    for x = 1 : 1 : length(Matrix);
            if Matrix(j,1) < S;
                Matrix(j,5) = Matrix(j,2);

                sum = sum + ( (interval/(Matrix(x,1))^2) * Matrix(x,2) );
                Matrix(j,6) = sum;

            elseif Matrix(x,1) == S;
                midpointIndex = x;
                Matrix(j,5) = (Matrix(j,2) + Matrix(j,3))/2;
                Matrix(:,7) = midpointIndex;

                sum = sum + ( (interval/(Matrix(x,1))^2) * (Matrix(x,2) + Matrix(x,3))/2 );
                Matrix(j,6) = sum;

            else
                Matrix(j,5) = Matrix(j,3);
                sum = sum + ( (interval/(Matrix(x,1))^2) * Matrix(x,3) );
                Matrix(j,6) = sum;
            end
            j = j + 1;

end

%DiscrError = 2/T * exp(r * T) * ( Matrix(end,6) - ([(integral(@(K) putBS(S, K, r, T, sigma)/K^2,Kmin,K,'ArrayValued',true)) + ...
 %   +(integral(@(K) callBS(S, K, r, T, sigma)/K^2,K,Kmax,'ArrayValued',true))]) )
x = 10;

end
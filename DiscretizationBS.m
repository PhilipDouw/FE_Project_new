function DiscrError = DiscretizationBS(S, K_min , K_max, interval, r, T, sigma)

[Matrix, a, b] = PCMatrixBS(S, K_min, K_max, interval, r, T, sigma)

% Finding the row s.t. min|C-P|    
midpointIndex = find(Matrix(:,4) == min(abs(Matrix(:,4))));

% Calculating F0 (whole forumla)
F_zero = Matrix(midpointIndex,1) +  exp(r * T) * Matrix(midpointIndex,4);

% Finding the corresponding K0
%index = find(F_zero > Matrix(:,1),1,'last');
%K_zero = Matrix(index, 1);
K_zero = F_zero;
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

    

DiscrError = 2/T * exp(r * T) * ( Matrix(end,6) - ([(integral(@(K) putBS(S, K, r, T, sigma)/K^2,K_min,K_zero,'ArrayValued',true)) + ...
           +(integral(@(K) callBS(S, K, r, T, sigma)/K^2,K_zero,K_max,'ArrayValued',true))]) )


end
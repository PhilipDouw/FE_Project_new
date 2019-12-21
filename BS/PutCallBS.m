% Matrix with folowing columns:
    % 1: Strikes from K_min to K_max
    % 2: Put prices
    % 3: Call prices
    % 4: Difference Put-Call
    % 5: Interval between strikes
    % 6: Call / Put and midpoint prices used for VIX calculation

function [Matrix, F_zero, K_zero] = PutCallBS(S , K_min, K_max, interval, r, T, sigma)
    
    i = 1;
    for k = K_min : interval : K_max
        
        Matrix(i,1) = k;
        Matrix(i,2) = putBS(S, k, r, T, sigma);
        Matrix(i,3) = callBS(S, k, r, T, sigma);
        Matrix(i,4) = Matrix(i,3) - Matrix(i,2); % Call minus Put
        Matrix(i,5) = interval;
        
        i = i + 1;
        
    end

    % Finding the row s.t. min|C-P|: 
    midpointIndex = find(abs(Matrix(:,4)) == min(abs(Matrix(:,4))));

    % Calculating F zero (whole forumla):
    F_zero = Matrix(midpointIndex,1) +  exp(r * T) * Matrix(midpointIndex,4);

    % Finding the corresponding K zero:
    index = find(F_zero >= Matrix(:,1),1,'last');
    K_zero = Matrix(index, 1);

    % Choosing the corresponding OTM P/C price for calculation:

    for j = 1 : 1 : length(Matrix)
        if Matrix(j,1) < K_zero         %OTM Put
            Matrix(j,6) = Matrix(j,2);          

        elseif Matrix(j,4) == K_zero    %ATM option
            Matrix(j,6) = (Matrix(j,2) + Matrix(j,3))/2;

        else                            %OTM Call
            Matrix(j,6) = Matrix(j,3); 
        end
    end

end
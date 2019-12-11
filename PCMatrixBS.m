% Matrix with folowing columns:
    % 1: K from Kmin to Kmax
    % 2: put prices / mean(bid,ask)
    % 3: call prices / mean(bid,ask)
    % 4: Difference Put Call
    % 5: interval between K's
    % 6: call / put midpoint price used for calculation
    % 7: Contribution of each option

    
function [Matrix, VIX, VIXerror] = PCMatrixBS(S , K_min, K_max, interval, r, T, sigma)
    
    i = 1;
    for K = K_min : interval : K_max
        
        Matrix(i,1) = K;
        Matrix(i,2) = putBS(S, K, r, T, sigma);
        Matrix(i,3) = callBS(S, K, r, T, sigma);
        Matrix(i,4) = Matrix(i,3) - Matrix(i,2);%Call minus Put
        Matrix(i,5) = interval;
        
        i = i + 1;
        
    end

    % Finding the row s.t. min|C-P|    
    midpointIndex = find(Matrix(:,4) == min(abs(Matrix(:,4))));
    
    % Calculating F0 (whole forumla)
    F_zero = Matrix(midpointIndex,1) +  exp(r * T) * Matrix(midpointIndex,4);
       
   % Finding the corresponding K0
   % index = find(Matrix(:,1) <= F_zero)
   % index = index(end,1)
   % K_zero = Matrix(index, 1);
   K_zero = F_zero 
    % Choosing the corresponding OTM P/C price for calculation
 
    for j = 1 : 1 : length(Matrix)
        if Matrix(j,1) < K_zero      %OTM Put
            Matrix(j,6) = Matrix(j,2);          
      
        elseif Matrix(j,4) == K_zero     %ATM option
            Matrix(j,6) = (Matrix(j,2) + Matrix(j,3))/2;
            
        else                         %OTM Call
            Matrix(j,6) = Matrix(j,3); 
    end
    
    % 7th column: the contribution of each OTM option
    for x = 1 : length(Matrix)
        Matrix(x,7) = (interval/(Matrix(x,1))^2) * exp(r * T) * Matrix(x,6); 
    end

% Whole VIX Index formula
sigmaVIXsquared = 2 / T * Matrix(end,7) * exp(r*T) - 1 / T * (F_zero / K_zero - 1)^2;


% final VIX calculation
VIX = 100* sqrt(sigmaVIXsquared);
 
% EasyVIX = 100* sqrt((2/T) * sum)  To check if the above calculation is correct

% Calculating the error
VIXerror = VIX/100 - sigma;
    end
    
 
   
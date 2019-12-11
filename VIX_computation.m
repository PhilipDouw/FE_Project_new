% Matrix with folowing columns:
    % 1: K from Kmin to Kmax
    % 2: put prices / mean(bid,ask)
    % 3: call prices / mean(bid,ask)
    % 4: Difference Put Call
    % 5: interval between K's
    % 6: call / put midpoint price used for calculation
    % 7: Contribution of each option

    
function [Matrix, VIX, VIXerror] = VIX_computation(S , Kmin, Kmax, interval, r, T, sigma)
    
    i = 1;
    for k = Kmin : interval : Kmax
        
        Matrix(i,1) = k;
        Matrix(i,2) = putBS(S, k, r, T, sigma);
        Matrix(i,3) = callBS(S, k, r, T, sigma);
        Matrix(i,4) = Matrix(i,3) - Matrix(i,2);%Call minus Put
        Matrix(i,5) = interval;
        
        i = i + 1;
        
    end

    % Finding the row s.t. min|C-P|    
    midpointIndex = find(Matrix(:,4) == min(abs(Matrix(:,4))));
    
    % Calculating F0 (whole forumla)
    F_zero = Matrix(midpointIndex,1) +  exp(r * T) * Matrix(midpointIndex,4);
       
   % Finding the corresponding K0
    index = find(F_zero > Matrix(:,1),1,'last');
    K_zero = Matrix(index, 1);
    
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
    x = 0;
    for k = 1 : length(Matrix)
        Matrix(k,7) = (interval/(Matrix(k,1))^2) * exp(r * T) * Matrix(k,6);
        x = x + Matrix(k,7);
    end
    
    
% Whole VIX Index formula
sigmaVIXsquared = 2 / T * sum(x) - 1 / T * (F_zero / K_zero - 1)^2;

% final VIX calculation
VIX = 100* sqrt(sigmaVIXsquared);

% Calculating the error
VIXerror = VIX/100 - sigma;
end
    
 
   
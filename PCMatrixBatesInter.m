function [Matrix, yy] = PCMatrixBatesInter(S, K_min, K_max, interval, T, r, sigma)



i = 1;
for K = K_min:interval:K_max
    
        Matrix(i,1) = K;
        Matrix(i,2) = putBates(S, K, r, T, sigma);
        Matrix(i,3) = callBates(S, K, r, T, sigma);
        Matrix(i,4) = Matrix(i,3) - Matrix(i,2); % Call minus Put

    i = i + 1;
end


% Finding the row s.t. min|C-P|    
midpointIndex = find(min(abs(Matrix(:,4))));

% Calculating F0 (whole forumla)
F_zero = Matrix(midpointIndex,1) +  exp(r * T) * Matrix(midpointIndex,4);

% Finding the corresponding K0
index = find(F_zero > Matrix(:,1),1,'last');
K_zero = Matrix(index, 1);

% Choosing the corresponding OTM P/C price for calculation

for j = 1 : 1 : length(Matrix)
    if Matrix(j,1) < K_zero      %OTM Put
        Matrix(j,5) = Matrix(j,2);   

    elseif Matrix(j,4) == K_zero     %ATM option
        Matrix(j,5) = (Matrix(j,2) + Matrix(j,3))/2;

    else                         %OTM Call
        Matrix(j,5) = Matrix(j,3); 
    end
end

% Calculating implied volatility

Timp = T/12

l = 1
for l = 1 : length(Matrix)
    
    if Matrix(l,1) < K_zero
        
        Matrix(l,6) = blsimpv(S,Matrix(l,1),r,Timp,Matrix(l,5), 'Class', {'Put'});
        
    else
        
        Matrix(l,6) = blsimpv(S,Matrix(l,1),r,Timp,Matrix(l,5), 'Class', {'Call'});
    end
    
    l = l + 1;
    
end

KK = K_min:0.25:K_max

yy = interp1(Matrix(:,1),Matrix(:,6),KK,'spline')

figure(1)

scatter(KK,yy)

zz = diff(yy)

KKz = KK(1,[2:end])

figure(2)

scatter(KKz, zz)

% = K_min:0.25:K_max;


%yy = interp1(Matrix(:,1),Matrix(:,6),KK,'spline')

%plot(Matrix(:,1),Matrix(:,6),KK,yy,'.')
%hold on

Matrix([2:end],7) = diff(Matrix(:,6))

figure(3)

scatter(Matrix([2:end],1),Matrix([2:end],7))

figure(4)

scatter(Matrix(:,1),Matrix(:,6))
end
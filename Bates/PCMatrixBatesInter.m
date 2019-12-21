% Smooth interpolation Bates:

function [Matrix, yy] = PCMatrixBatesInter(S, K_min, K_max, interval, T, r, sigma)


[Matrix, F_zero, K_zero] = PutCallBates(S , K_min, K_max, interval, r, T, sigma)

Temp = T/12;

l = 1
for l = 1 : length(Matrix)
    
    if Matrix(l,1) < K_zero
        
        Matrix(l,7) = blsimpv(S,Matrix(l,1),r,Temp,Matrix(l,6), 'Class', {'Put'});
        
    else
        
        Matrix(l,7) = blsimpv(S,Matrix(l,1),r,Temp,Matrix(l,6), 'Class', {'Call'});
    end
    
    l = l + 1;
    
end

for m = 1 : length(Matrix)
    
    Matrix(m,7) = round(Matrix(m,7),10);
    
end

KK = K_min:0.25:K_max

yy = interp1(Matrix(:,1),Matrix(:,7),KK,'spline')

figure(1)

xlabel('Strike Price') 
ylabel('Implied Volatility ') 

scatter(KK,yy,'.')

zz = diff(yy)


KKz = KK(1,[2:end])

figure(2)

xlabel('Strike Price') 
ylabel('Diff Implied Volatility ') 

scatter(KKz, zz,'.')


Matrix([2:end],8) = diff(Matrix(:,7))

figure(3)

xlabel('Strike Price') 
ylabel('Implied Volatility ') 

scatter(Matrix([2:end],1),Matrix([2:end],8),'.')

figure(4)

xlabel('Strike Price') 
ylabel('Diff Implied Volatility ') 

scatter(Matrix(:,1),Matrix(:,7),'.')
end
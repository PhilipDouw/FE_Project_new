% Options simulation - PUT Prices
function [Call, Put, Strikes, Call_3D, Put_3D] = PCMatrixBates(S, K_min, K_max, interval, r, sigma)

Settle = datenum('01-Jan-2019');
x = [1];
ExDates = (3 : 3 : 24)';
ExDates = [x;ExDates];
Maturity = datemnth(Settle, ExDates);

V0 = 0.04;
ThetaV = 0.04;
Kappa = 2;
RhoSV = -0.5;
JumpVol = 0.4;
MeanJ = exp(-0.5+JumpVol.^2/2)-1;
JumpFreq = 0.2;
OptSpec = 'Put';

Strikes = (K_min : interval : K_max)';
Put = zeros(length(Strikes),1);

for i = 1 : length(Maturity)   
    M = Maturity(i,1);
    for j = 1 : length(Strikes)
        K = Strikes(j,1);
        Put(j,i) = optByBatesFD(r,S,Settle,M,OptSpec,K,V0,ThetaV,...
                   Kappa,Sigma,RhoSV,MeanJ,JumpVol,JumpFreq);
        j = j + 1
    end
    i = i + 1
end

% Plot the graph
Put_3D = surf(Maturity, Strikes, Put)

% Options simulation - CALL Prices

OptSpec = 'Call';

Strikes = (K_min : interval : K_max)';
Call = zeros(length(Strikes),1);

for i = 1 : length(Maturity)   
    M = Maturity(i,1);
    for j = 1 : length(Strikes)
        K = Strikes(j,1);
        Call(j,i) = optByBatesFD(r,S,Settle,M,OptSpec,K,V0,ThetaV,...
                   Kappa,SigmaV,RhoSV,MeanJ,JumpVol,JumpFreq);
        j = j + 1
    end
    i = i + 1
end

% Plot the graph
Call_3D = surf(Maturity, Strikes, Call)
end
function Put = putBates(S, K, r, T, sigma)

Settle = datenum('01-Jan-2019');
Maturity = datemnth(Settle, T);
M = Maturity;
V0 = 0.04;
ThetaV = 0.04;
Kappa = 2;
RhoSV = -0.5;
JumpVol = 0.4;
MeanJ = exp(-0.5+JumpVol.^2/2)-1;
JumpFreq = 0.2;
OptSpec = 'Put';

Put = optByBatesFD(r,S,Settle,M,OptSpec,K,V0,ThetaV,...
                   Kappa,sigma,RhoSV,MeanJ,JumpVol,JumpFreq);

end
function Call = callBates(S, K, r, T, sigma)

    % Setting parameters that we won't change from here on:

    Settle = datenum('01-Jan-2019');
    Maturity = datemnth(Settle, T);
    M = Maturity;
    V0 = 0.01;
    ThetaV = 0.01;
    Kappa = 2;
    RhoSV = -0.5;
    JumpVol = 0.2;
    MeanJ = exp(-0.5+JumpVol.^2/2)-1;
    JumpFreq = 0.2;
    OptSpec = 'Call';

    % Calculating Put option:
    
    Call = optByBatesFD(r,S,Settle,M,OptSpec,K,V0,ThetaV,...
                       Kappa,sigma,RhoSV,MeanJ,JumpVol,JumpFreq);

end
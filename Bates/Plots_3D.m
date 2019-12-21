function [Call, Put, Strikes, Call_3D, Put_3D] = Plots_3D(S, K_min, K_max, interval, r, sigma)

    Settle = datenum('01-Jan-2019');
    x = [1];
    ExDates = (3 : 3 : 24)';
    ExDates = [x;ExDates];
    Maturities = datemnth(Settle, ExDates);
    M = Maturities;
    V0 = 0.01;
    ThetaV = 0.01;
    Kappa = 2;
    RhoSV = -0.5;
    JumpVol = 0.2;
    MeanJ = exp(-0.5+JumpVol.^2/2)-1;
    JumpFreq = 0.2;

    % Create the empty arrays
    Strikes = (K_min : interval : K_max)';
    Put = zeros(length(Strikes),1);
    Call = zeros(length(Strikes),1);

    % Create two loops to take compute the prices of the Puts and Calls
    % with different maturities and strikes:
    for i = 1 : length(Maturities)   
    M = Maturities(i,1);
    for j = 1 : length(Strikes)
        K = Strikes(j,1);
        OptSpec = 'Put';
        Put(j,i) = optByBatesFD(r,S,Settle,M,OptSpec,K,V0,ThetaV,...
                   Kappa,sigma,RhoSV,MeanJ,JumpVol,JumpFreq);
        OptSpec = 'Call';
        Call(j,i) = optByBatesFD(r,S,Settle,M,OptSpec,K,V0,ThetaV,...
                   Kappa,sigma,RhoSV,MeanJ,JumpVol,JumpFreq);
        j = j + 1;
    end
    i = i + 1;
    end
    
    % Convert dates to coherent format:
    Maturities = datetime(Maturities, 'ConvertFrom', 'datenum', 'Format', 'dd-MM-yyyy')
    
    % Plot the graphs:
    figure(1)
    Put_3D = surf(Maturities, Strikes, Put);
    title('Puts'), xlabel('Maturities'), ylabel('Strikes'), zlabel('Prices')
    saveas(gcf, 'Put_3D.fig');
    grid
    figure(2)
    Call_3D = surf(Maturities, Strikes, Call);
    title('Calls'), xlabel('Maturities'), ylabel('Strikes'), zlabel('Prices')
    saveas(gcf, 'Call_3D.fig');
    grid
end
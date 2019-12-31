% This script outputs graphs that show the impact of parameter changes
% on the errors.

clear all
clc

%% Changing the range between K_min and K_max:

% Parameters

S = 100;
interval = 1;
r = 0;
T = 1;
sigma = 0.2; % Can't be higher than 0.53

K_min = 1990;
KminGoal = 1800;
K_max = 2010;
KmaxGoal = 2200;

% Calculations:

% Setting number of loops:

NumSteps = (K_min - KminGoal)/interval;

% Calculating every error each time the wanted parameter changes:

for i = 1:1:NumSteps

    % VIX:
    
    [MatrixVIX, VIX, VIXerror] = VIX_computationBates(S ,K_min ,K_max, interval, r, T,sigma);
    
    % Truncation:
    
    [TruncError, TruncErrPercentage] = TruncationBates(S ,K_min ,K_max, r, T,sigma);
    
    % Discretization:
    
    DiscrError = DiscretizationBates(S ,K_min ,K_max, interval, r, T,sigma);
    
    % Expansion:
    
    [MatrixDisc, ExpansionError] = ExpansionBates(S , K_min, K_max, interval, r, T, sigma);
    
    % Putting everything into a matrix:
    
    Kmin_KmaxModification(i, 1) = VIXerror;
    Kmin_KmaxModification(i, 2) = TruncErrPercentage;
    Kmin_KmaxModification(i, 3) = DiscrError;
    Kmin_KmaxModification(i, 4) = ExpansionError;
    Kmin_KmaxModification(i, 5) = K_max - K_min;
    
    
    K_min = K_min - interval;
    K_max = K_max + interval;
end

% Creating the Graphs:

figure(1)

VIXErrorGraph = scatter(Kmin_KmaxModification(:,5),Kmin_KmaxModification(:,1), '.')

hold on
TruncErrorGraph = scatter(Kmin_KmaxModification(:,5),Kmin_KmaxModification(:,2), '.')

hold on
DiscrErrorGraph = scatter(Kmin_KmaxModification(:,5),Kmin_KmaxModification(:,3), '.')

hold on
ExpanErrorGraph = scatter(Kmin_KmaxModification(:,5),Kmin_KmaxModification(:,4), '.')

legend('Total Error', 'Truncation Error', 'Discretization Error', 'Expansion Error', 'Location','southeast')

xlabel('[Kmax - Kmin]') 
ylabel('Error') 

hold off
grid

%% Changing sigma:

S = 100;
interval = 1;
r = 0;
T = 1;
K_min = 80;
K_max = 120;
sigma = 0.05;
MinSigma = 0.05;
MaxSigma = 0.5; % Can't be higher than 0.53

% Calculations:

% Setting number of loops:

SigmaSteps = (MaxSigma - MinSigma)*10;

% Calculating every error each time the wanted parameter changes:

for j = 1:1:SigmaSteps
    
    % VIX:
    
    [MatrixVIX, VIX, VIXerror] = VIX_computationBates(S , K_min, K_max, interval, r, T, sigma);
    
    % Truncation:
    
    [TruncError, TruncErrPercentage] = TruncationBates(S ,K_min ,K_max, r, T,sigma);
    
    % Discretization:
    
    DiscrError = DiscretizationBates(S ,K_min ,K_max, interval, r, T,sigma);
    
    % Expansion:
    
    [MatrixDisc, ExpansionError] = ExpansionBates(S , K_min, K_max, interval, r, T, sigma);  
    
    % Putting everything into a matrix:
    
    SigmaModification(j, 1) = VIXerror;
    SigmaModification(j, 2) = TruncErrPercentage;
    SigmaModification(j, 3) = DiscrError;
    SigmaModification(j, 4) = ExpansionError;
    SigmaModification(j, 5) = sigma;
    
    sigma = sigma + 0.01;
    
    
end

% Creating the Graph:

figure(2)

VIXErrorGraph = scatter(SigmaModification(:,5),SigmaModification(:,1), '.')

hold on
TruncErrorGraph = scatter(SigmaModification(:,5),SigmaModification(:,2), '.')

hold on
DiscrErrorGraph = scatter(SigmaModification(:,5),SigmaModification(:,3), '.')

hold on
ExpanErrorGraph = scatter(SigmaModification(:,5),SigmaModification(:,4), '.')

legend('Total Error', 'Truncation Error', 'Discretization Error', 'Expansion Error', 'Location','southwest')

xlabel('Sigma') 
ylabel('Error') 

hold off
grid


%% Changing Delta K:

S = 2000;
interval = 1;
Min_interval = 1;
Max_interval = 10;
r = 0;
T = 30/360;
K_min = 1500;
K_max = 2500;
sigma = 0.2; % Can't be higher than 0.53

% Calculations:

% Setting number of loops:

DeltaK_steps = 10 * Max_interval/Min_interval;

% Calculating every error each time the wanted parameter changes:

for j = 1:1:DeltaK_steps
    
    % VIX:
    
    [MatrixVIX, VIX, VIXerror] = VIX_computationBates(S , K_min, K_max, interval, r, T, sigma);

    % Truncation:
    
    [TruncError, TruncErrPercentage] = TruncationBates(S ,K_min ,K_max, r, T,sigma);
    
    % Discretization:
    
    DiscrError = DiscretizationBates(S ,K_min ,K_max, interval, r, T,sigma);
    
    % Expansion:
    
    [MatrixDisc, ExpansionError] = ExpansionBates(S , K_min, K_max, interval, r, T, sigma);
    
    % Putting everything into a matrix:
    
    DeltaKModification(j, 1) = VIXerror;
    DeltaKModification(j, 2) = TruncErrPercentage;
    DeltaKModification(j, 3) = DiscrError;
    DeltaKModification(j, 4) = ExpansionError;
    DeltaKModification(j, 5) = interval;
    
    interval = interval + 0.025;
    
    
end

% Creating the Graph:

figure(3)

VIXErrorGraph = scatter(DeltaKModification(:,5),DeltaKModification(:,1), '.')

hold on
TruncErrorGraph = scatter(DeltaKModification(:,5),DeltaKModification(:,2), '.')

hold on
DiscrErrorGraph = scatter(DeltaKModification(:,5),DeltaKModification(:,3), '.')

hold on
ExpanErrorGraph = scatter(DeltaKModification(:,5),DeltaKModification(:,4), '.')

legend('Total Error', 'Truncation Error', 'Discretization Error', 'Expansion Error', 'Location','southwest')

xlabel('Delta K') 
ylabel('Error') 

hold off
grid

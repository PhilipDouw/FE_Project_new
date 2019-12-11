% Graphs

clear all
clc

% function [VIX, VIXerror] = VIXfun(S ,Kmin ,Kmax, interval, r, T,sigma)
% function [TruncError, TruncErrPercentage] = Truncation(S ,Kmin ,Kmax, r, T,sigma)
% function [Discr, DiscrError] = Discretization(S ,Kmin ,Kmax, interval, r, T,sigma)
% function [GVIX, GVIXerror] = GVIXfun(S ,Kmin ,Kmax, interval, r, T,sigma)


% The small steps in some parts of the graphs come from the fact that
% I did not yet find the correct way to calculate K0 using "kMidPoint"
% inside VIXfun (same for GVIXfun)

%% Chaning Kmin and Kmax:

% Parameters

S = 100;
interval = 0.5;
r = 0;
T = 30/360;
sigma = 0.2;

K_min = 95;
KminGoal = 80;
K_max = 105;
KmaxGoal = 120;

% Calculations

NumSteps = (K_min - KminGoal)/interval;



for i = 1:1:NumSteps

    % VIX
    
    [Matrix, VIX, VIXerror] = VIX_computation(S ,K_min ,K_max, interval, r, T,sigma);
    
    % GVIX
    
    %[GVIX, GVIXerror] = GVIXfun(S ,Kmin ,Kmax, interval, r, T,sigma);
    
    % Truncation
    
    [TruncError, TruncErrPercentage] = TruncationBS(S ,K_min ,K_max, r, T,sigma);
    
    % Discretization
    
    DiscrError = DiscretizationBS(S ,K_min ,K_max, interval, r, T,sigma);
    
    
    % Putting everything into a matrix
    
    Kmin_KmaxModification(i, 1) = VIXerror;
    %Kmin_KmaxModification(i, 2) = GVIXerror;
    Kmin_KmaxModification(i, 3) = TruncErrPercentage;
    Kmin_KmaxModification(i, 4) = DiscrError;
    Kmin_KmaxModification(i, 5) = K_max - K_min;
    
    
    
    K_min = K_min - interval;
    K_max = K_max + interval;
end


figure(1)

VIXErrorGraph = scatter(Kmin_KmaxModification(:,5),Kmin_KmaxModification(:,1), '.')

% Since GVIX has a is not a "Real number" I did not include it in the
% calculation. Need to sort out how we could compare them
%hold on
%GVIXErrorGraph = scatter(Kmin_KmaxModification(:,5),Kmin_KmaxModification(:,2))

hold on
TruncErrorGraph = scatter(Kmin_KmaxModification(:,5),Kmin_KmaxModification(:,3), '.')

hold on
DiscrErrorGraph = scatter(Kmin_KmaxModification(:,5),Kmin_KmaxModification(:,4), '.')

hold off
grid

%% Changing sigma:

S = 100;
interval = 0.5;
r = 0;
T = 30/360;
K_min = 80;
K_max = 120;
sigma = 0.05;
MinSigma = 0.05;
MaxSigma = 0.5; % Can't be higher than 0.53

% Calculations:

SigmaSteps = (MaxSigma - MinSigma)*100;


for j = 1:1:SigmaSteps
    
        % VIX
    
    [Matrix, VIX, VIXerror] = VIX_computation(S , K_min, K_max, interval, r, T, sigma);
    
    % GVIX
    
    %[GVIX, GVIXerror] = GVIXfun(S ,Kmin ,Kmax, interval, r, T,sigma);
    
    % Truncation
    
    [TruncError, TruncErrPercentage] = TruncationBS(S ,K_min ,K_max, r, T,sigma);
    
    % Discretization
    
    DiscrError = DiscretizationBS(S ,K_min ,K_max, interval, r, T,sigma);
    
    % Putting everything into a matrix
    
    SigmaModification(j, 1) = VIXerror;
    %SigmaModification(j, 2) = GVIXerror;
    SigmaModification(j, 2) = TruncErrPercentage;
    %SigmaModification(j, 3) = DiscrError;
    SigmaModification(j, 4) = sigma;
    
    sigma = sigma + 0.01
    
    
end


figure(2)

VIXErrorGraph = scatter(SigmaModification(:,4),SigmaModification(:,1), '.')

%hold on
%GVIXErrorGraph = scatter(SigmaModification(:,5),SigmaModification(:,2), '.')

hold on
TruncErrorGraph = scatter(SigmaModification(:,4),SigmaModification(:,2), '.')

hold on
DiscrErrorGraph = scatter(SigmaModification(:,4),SigmaModification(:,3), '.')

hold off
grid

%{

This one just doesn't want to work and I don't know why

% Chaning Interval:

% Parameters

S = 100;
r = 0;
T = 30/360;
Kmin = 80;
Kmax = 120;
sigma = 0.2;
interval = 0.1;
intervalMax = 10;

intervalSteps = (intervalMax - interval)/0.1;

for k = 1:1:intervalSteps
    
    % VIX
    
    [VIX, VIXerror] = VIXfun(S ,Kmin ,Kmax, interval, r, T,sigma);
    
    % Truncation
    
    [TruncError, TruncErrPercentage] = Truncation(S ,Kmin ,Kmax, r, T,sigma);
    
    % Discretization
    
    [Discr, DiscrError] = Discretization(S ,Kmin ,Kmax, interval, r, T,sigma);
    
    % Putting everything into a matrix
    
    intervalModification(k, 1) = VIXerror;
    intervalModification(k, 2) = TruncErrPercentage;
    intervalModification(k, 3) = DiscrError;
    intervalModification(k, 4) = sigma;
    
    interval = interval + 0.1;
    
end

figure(3)

VIXErrorGraph = scatter(intervalModification(:,4),intervalModification(:,1))

hold on
TruncErrorGraph = scatter(intervalModification(:,4),intervalModification(:,2))

hold on
DiscrErrorGraph = scatter(intervalModification(:,4),intervalModification(:,3))

hold off
grid
%}

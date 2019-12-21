%% Interpolation Error Bates:

clear all
clc

%% 30 days VIX:

S = 100;
interval = 0.5;
r = 0;
T = 1;
sigma = 0.2;
K_min = 80;
K_max = 120;


[MatrixVIX, VIX, VIXerror] = VIX_computationBates(S ,K_min ,K_max, interval, r, T,sigma);

%% Near term:

S = 100;
interval = 0.5;
r = 0;
T1 = 27/30;
sigma = 0.2;
K_min = 80;
K_max = 120;

[MatrixVIXNear, VIXNear, VIXerrorNear] = VIX_computationBates(S ,K_min ,K_max, interval, r, T1,sigma);

%% Next Term:

S = 100;
interval = 0.5;
r = 0;
T2 = 34/30;
sigma = 0.2;
K_min = 80;
K_max = 120;

[MatrixVIXNext, VIXNext, VIXerrorNext] = VIX_computationBates(S ,K_min ,K_max, interval, r, T2,sigma);

%% Calculating NearNext Vix:

sigmaVIXsquaredNear = (VIXNear/100)^2;

sigmaVIXsquaredNext = (VIXNext/100)^2;

VIXNearNext = 100 * sqrt((T1 * sigmaVIXsquaredNear * ((T2 - T)/(T2 - T1)) + T2 * sigmaVIXsquaredNext * ((T - T1)/(T2 - T1)))*12);

% Calculating the interpolation error:

sigmaSquarredVIX = (VIX/100)^2;

sigmaSquarredVIXNearNext = (VIXNearNext/100)^2;

InterpolationError = sigmaSquarredVIXNearNext - sigmaSquarredVIX

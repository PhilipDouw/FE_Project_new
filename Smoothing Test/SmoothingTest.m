clear
clc

% Matrix
    % Strike
    % Put list
    % Call list
    % Call minus Put
    % Call until midpoint, then put
    % impvol Call/Put
    % impvolsmoothed Call/Put

r = 0.0453; % random interest rate that we keep constant thoughout the code

T = 30/360;

load BatesPutSmoothedNEW.mat implied_volatility_smoothed strike
load GeneratedputBatesForSmoothing.mat ivs PutList

strike = strike(123:183);
PutList = PutList(:,3);

impvolput = ivs(:,3);

impvolsmoothedput = implied_volatility_smoothed(123:183);

clear implied_volatility_smoothed


load BatesCallSmoothedNEW.mat implied_volatility_smoothed
load GeneratedcallBatesForSmoothing.mat ivs CallList

CallList = CallList(:,3);

impvolcall = ivs(:,3);

impvolsmoothedcall = implied_volatility_smoothed(123:183);

clear ivs implied_volatility_smoothed


Matrix(:,1) = strike;
Matrix(:,2) = PutList;
Matrix(:,3) = CallList;
Matrix(:,4) = Matrix(:,3) - Matrix(:,2); % Call minus Put


% Finding the row s.t. min|C-P|: 
midpointIndex = find(abs(Matrix(:,4)) == min(abs(Matrix(:,4))));

% Calculating F zero (whole forumla):
F_zero = Matrix(midpointIndex,1) +  exp(r * T) * Matrix(midpointIndex,4);

% Finding the corresponding K zero:
index = find(F_zero >= Matrix(:,1),1,'last');
K_zero = Matrix(index, 1);

% Choosing the corresponding OTM P/C price for calculation:

for j = 1 : 1 : length(Matrix)
    if Matrix(j,1) < K_zero         %OTM Put
        Matrix(j,6) = Matrix(j,2);
        Matrix(j,7) = impvolcall(j);
        Matrix(j,8) = impvolsmoothedcall(j);

    elseif Matrix(j,4) == K_zero    %ATM option
        Matrix(j,6) = (Matrix(j,2) + Matrix(j,3))/2;
        Matrix(j,7) = impvolcall(j);
        Matrix(j,8) = impvolsmoothedcall(j);

    else                            %OTM Call
        Matrix(j,6) = Matrix(j,3); 
        Matrix(j,7) = impvolput(j);
        Matrix(j,8) = ((impvolsmoothedput(j))^2)/100;
    end
end


Matrix(:,8) = sqrt(Matrix(:,8))/100;


figure(1)

notSmoothed = scatter(strike,Matrix(:,7),'.')
hold on
smoothed = scatter(strike,impvolsmoothedput/100,'.')

legend('Smoothed', 'Not Smoothed', 'Location','northeast')
xlabel('Strikes')
ylabel('implied volatility')

hold off



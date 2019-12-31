%% needed vars: today_num, ttm, K0, F0, ttm_annual 
% data_list:     
% 1-current date; 2-expire date; 3-strike price; 4-P0/C1; 5-OTM_mid;6-RF
% interest rate
clearvars
load('cleaned_2004to2012.mat'); 
% load('cleaned_2012to2019.mat');
T30 = 30/365;
%% transfer K0,F0,ttm_annual to matrix form
ttm_1 = transpose(ttm);
ttm_1 = ttm_1(:);%the matrix size is the same as ttm. Rows: current day; Cols: maturity day
nonzero = find(ttm_1 ~= 0);
K0_1row = zeros(1,length(ttm_1));
F0_1row = zeros(1,length(ttm_1));
ttm_1row = zeros(1,length(ttm_1));
K0_1row(nonzero) = K0;
F0_1row(nonzero) = F0;
ttm_1row(nonzero) = ttm_annual;
K0_matrix  = transpose(reshape(K0_1row,[size(ttm,2),size(ttm,1)]));
F0_matrix  = transpose(reshape(F0_1row,[size(ttm,2),size(ttm,1)]));
ttm_matrix  = transpose(reshape(ttm_1row,[size(ttm,2),size(ttm,1)]));

%% Delete SPXW, keep the 3rd Fri. SPX. 
data_list = sortrows(data_list,[1,2,3]);%sort by 1-current date; 2-expire date; 3-strike price;
delete_rows = [];
for i = 1:length(today_num)
    today_index = find(data_list(:,1) == today_num(i));
    expire_dates = unique(data_list(today_index,2));
    for j = 1:length(expire_dates)
        expire_ij = find(data_list(today_index,2) == expire_dates(j));%internal index
        first_index = today_index(1) + expire_ij(1) - 1;
        end_index = today_index(1) + expire_ij(end) - 1;
        
        %delete entries with same K 
        for k = first_index:end_index - 1
            if data_list(k, 3) == data_list(k + 1, 3)
                delete_rows = cat(2, delete_rows, k + 1); 
            end
        end
        
    end
end

data_list(delete_rows, :) = [];
%% Compute VIX, 2nd, 3rd, 4th return moment
data_list = sortrows(data_list,[1,2,3]);%sort by 1-current date; 2-expire date; 3-strike price;
vix = zeros(size(ttm,1),size(ttm,2));%contribution matrix of each option
mu = vix; W = vix; X = vix;
for i = 1:length(today_num)
    today_index = find(data_list(:,1) == today_num(i));
    expire_dates = unique(data_list(today_index,2));
     
    for j = 1:length(expire_dates)
               
        expire_ij = find(data_list(today_index,2) == expire_dates(j));%internal index
        vix_1st = 0;%vix
        mu_1st = 0;%1st moment
        W_1st = 0;%3rd moment
        X_1st = 0;%4th moment
        R = data_list(today_index(1),6) * ttm(i,j)/30;
        delta_k = zeros(length(expire_ij) - 1, 1);
        
        %Compute delta K 
        lnK0_S0 = R*ttm_matrix(i,j) + (F0_matrix(i,j) / K0_matrix(i,j) - 1)^2/2 - (F0_matrix(i,j) / K0_matrix(i,j) - 1);
        vix_2nd = (F0_matrix(i,j) / K0_matrix(i,j) - 1)^2 / ttm_matrix(i,j); 
        mu_2nd = lnK0_S0 + (F0_matrix(i,j) / K0_matrix(i,j) - 1);
        W_2nd = lnK0_S0^3 + 3*lnK0_S0^2 * (F0_matrix(i,j) / K0_matrix(i,j) - 1);
        X_2nd = lnK0_S0^4 + 4*lnK0_S0^3 * (F0_matrix(i,j) / K0_matrix(i,j) - 1);
        
        for m = 1 : length(expire_ij) - 1
            start_index = today_index(1) + expire_ij(1) - 1 + m - 1; %the entry used for calculation
            delta_k(m) = data_list(start_index + 1, 3) - data_list(start_index, 3);
            lnKi_S0 = R*ttm_matrix(i,j) + (F0_matrix(i,j) / delta_k(m) - 1)^2/2 - (F0_matrix(i,j) / delta_k(m) - 1);
            
            vix_1st = vix_1st + delta_k(m)/data_list(start_index , 3)^2 * data_list(start_index , 5);
            W_1st = W_1st + (2*lnKi_S0 - lnKi_S0^2)*data_list(start_index , 5)*delta_k(m)/data_list(start_index , 3)^2;
            X_1st = X_1st + (3*lnKi_S0^2 - lnKi_S0^3)*data_list(start_index , 5)*delta_k(m)/data_list(start_index , 3)^2;
            
            
        end
        
       
        vix_1st = vix_1st + delta_k(m)/data_list(start_index + 1 , 3)^2 * data_list(start_index + 1 , 5);%for the last entry
        mu_1st = vix_1st;
        vix_1st = 2 * vix_1st * exp(R * ttm_matrix(i,j)) / ttm_matrix(i,j); 
        mu_1st = - mu_1st * exp(R * ttm_matrix(i,j));
        W_1st = W_1st + (2*lnKi_S0 - lnKi_S0^2)*data_list(start_index+1, 5)*delta_k(m)/data_list(start_index+1, 3)^2;
        W_1st = W_1st*3*exp(R * ttm_matrix(i,j));
        X_1st = X_1st + (3*lnKi_S0^2 - lnKi_S0^3)*data_list(start_index+1, 5)*delta_k(m)/data_list(start_index+1, 3)^2;
        X_1st = X_1st*4*exp(R * ttm_matrix(i,j));
        
        vix(i,j) = vix_1st - vix_2nd;
        mu(i,j) = mu_1st + mu_2nd;
        W(i,j) = W_1st + W_2nd;
        X(i,j) = X_1st + X_2nd;

    end
        
    %interpolation by choosing 2 columns with ttm nearest to 30d

    if length(expire_dates) == 1
        vix_final(i) = 100 * sqrt(365/30 * vix(i,1)* ttm_matrix(i,1)* T30/ttm_matrix(i,1));
        mu_final(i) = 365/30 * mu(i,1)* ttm_matrix(i,1)* T30/ttm_matrix(i,1);
        W_final(i) = 365/30 * W(i,1)* ttm_matrix(i,1)* T30/ttm_matrix(i,1);
        X_final(i) = 365/30 * X(i,1)* ttm_matrix(i,1)* T30/ttm_matrix(i,1);
    else
        nearest_ttm = abs(ttm(i,1:length(expire_dates)) - 30);
        [out,idx] = sort(nearest_ttm);
        maturities = idx(1:2);
                
        if ttm(i,maturities(2)) < ttm(i,maturities(1))
            cache1  = maturities(2);
            maturities(2) = maturities(1);
            maturities(1) = cache1;
        end    

        T_ij  = ttm_matrix(i,maturities(2)) - ttm_matrix(i,maturities(1));
        w1 = (ttm_matrix(i,maturities(2)) - T30) / T_ij;
        w2 = (T30 - ttm_matrix(i,maturities(1))) / T_ij;
        vix_final(i) = 100 * sqrt(365/30 * (ttm_matrix(i,maturities(1)) * vix(i,maturities(1)) * w1 + ttm_matrix(i,maturities(2)) * vix(i,maturities(2)) * w2));
        mu_final(i) = 365/30 * (ttm_matrix(i,maturities(1)) * mu(i,maturities(1)) * w1 + ttm_matrix(i,maturities(2)) * mu(i,maturities(2)) * w2);
        W_final(i) = 365/30 * (ttm_matrix(i,maturities(1)) * W(i,maturities(1)) * w1 + ttm_matrix(i,maturities(2)) * W(i,maturities(2)) * w2);
        X_final(i) = 365/30 * (ttm_matrix(i,maturities(1)) * X(i,maturities(1)) * w1 + ttm_matrix(i,maturities(2)) * X(i,maturities(2)) * w2);
        
    end
 
end

%% Final result
vix_final = transpose(vix_final);
mu_final = transpose(mu_final);
W_final = transpose(W_final);
X_final = transpose(X_final);
GV_spread = mu_final.^2 + W_final/3 + X_final/12;
V_final = cat(2,today_num, vix_final,GV_spread);


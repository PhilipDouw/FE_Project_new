%used vars: today_num, ttm, K0, F0, ttm_annual 
R = 0.088268645;
T30 = 1/12;
%% transfer K0,F0,ttm_annual to matrix form
ttm_1 = transpose(ttm);
ttm_1 = ttm_1(:);
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

%% Compute VIX
data_list = sortrows(data_list,[1,2,3]);%sort by 1-current date; 2-expire date; 3-strike price;
vix = zeros(size(ttm,1),size(ttm,2));

for i = 1:length(today_num)
    today_index = find(data_list(:,1) == today_num(i));
    expire_dates = unique(data_list(today_index,2));
     
    for j = 1:length(expire_dates)
               
        expire_ij = find(data_list(today_index,2) == expire_dates(j));%internal index
      
        vix_1st = 0;
        delta_k = zeros(length(expire_ij) - 1, 1);
        
        for m = 1 : length(expire_ij) - 1
            start_index = today_index(1) + expire_ij(1) - 1 + m - 1; %starting point
%             last_index = start_index + length(expire_ij) - 1; %end point of expire_ij in the whole list
            delta_k(m) = data_list(start_index + 1, 3) - data_list(start_index, 3);
            vix_1st = vix_1st + delta_k(m)/data_list(m , 3)^2 * data_list(m , 5);
        end
        
        vix_1st = vix_1st + delta_k(m)/data_list(m + 1 , 3)^2 * data_list(m + 1 , 5);
        vix_1st = 2 * vix_1st * exp(R * ttm_matrix(i,j)) / ttm_matrix(i,j); 
        
        vix_2nd = (F0_matrix(i,j) / K0_matrix(i,j) - 1)^2 / ttm_matrix(i,j); 
        vix(i,j) = vix_1st - vix_2nd;
        
%         T_ij  = ttm_matrix(i,j) - 
%         %interpolation in ttm
%         options_day_i = find(ttm(i,:) ~= 0);
%         T_max = ttm_matrix(i,options_day_i(end)) - ttm_matrix(i,options_day_i(1));
    
        
    end
    
    
    
end


%used vars: today_num, ttm, K0, F0, ttm_annual 
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

% %% Compute VIX
% data_list = sortrows(data_list,[1,2,3]);%sort by 1-current date; 2-expire date; 3-strike price;
% 
% 
% for i = 1:length(today_num)
%     today_index = find(data_list(:,1) == today_num(i));
%     expire_dates = unique(data_list(today_index,2));
%      
%     for j = 1:length(expire_dates)
%         
%         
%         expire_ij = find(data_list(today_index,:) == expire_dates(j));%internal index
%         start_index = expire_ij + today_index(1) - 1; %starting point
%         last_index = start_index + length(expire_ij) - 1; %end point of expire_ij in the whole list
%         
%         for m = start_index : last_index - 1
%             delta_k(m) = data_list(start_index + 1, 3) - data_list(start_index, 3);
%             vix_1st = delta_k(m)/(
%         end
%         
%     end
%     
%    
%     
% end
% 
% %2nd part of vix
% vix_2nd = (F0/K0 - 1)^2;
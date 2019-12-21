%needed vars: today_num,
%data_list has been sorted

%% calculate implied vol
% Volatility = blsimpv(Price,Strike,Rate,Time,Value)
S = ones(length(today_num),1);%need to download data

%% 

%form list K
for i = 1:length(today_num)
    today_index = find(data_list(:,1) == today_num(i));
%     data_list(today_index,6) = S(i);%S&P price
    
%     data_list(today_index,7) = blsimpv(S, k(i), r1, t1, price1_k(i),'Class', {'Put'});
    
    data_list(today_index,6) = blsimpv(S(i), data_list(today_index,3), r1, t1, data_list(today_index,5),'Class', {'Put'});
    
    strike_i = unique(data_list(today_index,3));
    expire_dates = unique(data_list(today_index,2));
    
    for j = 1:length(expire_dates)
        expire_ij = find(data_list(today_index,:) == expire_dates(j));%internal index
        strike_ij = unique(data_list(expire_ij,3));
        [Lia,Locb] = ismember(strike_i,strike_ij);
        
    end
end
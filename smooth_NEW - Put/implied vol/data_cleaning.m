clearvars
%% Clear Workspace Before Rerun, rename the .dat as "ImportedData"
% load('20190603_20to50days.mat');
load 'havefun.mat';
R = 0.00035;

%About DATASET, indicators used here:
    %SYMBOL EXERCISE_STYLE CP_FLAG LAST_DATE OPEN_INTEREST EXDATE SECID 
    %INDEX_FLAG BEST_BID BEST_OFFER VOLUME STRIKE_PRICE FORWARD_PRICE

% Final result: data_list:     
% 1-current date; 2-expire date; 3-strike price; 4-P0/C1; 5-OTM_mid

%Useful variables
% today_num
% today_ymd
% ttm 
% ttm_annual 
%% %% Remove needed columes not needed

U_names = ImportedData.Properties.VariableNames;
delete_index = [1,3,5,10,11:16];
delete_names = U_names(delete_index);
ImportedData = removevars(ImportedData, delete_names);

%% Calculate t.t.m
today_num = unique(table2array(ImportedData(:,1)));%option prices across several days
today_ymd = datestr(datenum(string(today_num), 'yyyymmdd'),'yyyy/mm/dd');

%C-->1, P-->0
call_index = (table2array(ImportedData(:,3)) == 'C');%call is 1, and put is 0
ImportedData = addvars(ImportedData, call_index);
ImportedData = removevars(ImportedData, 3);


%% Let's work in an array!
alldata = table2array(ImportedData);%Now it's array! :)
alldata = alldata(:,[1,2,6,3,4,5]);

%get the right strike price
alldata(:,4) = alldata(:,4)/1000;
%alldata: columns
%1-current date; 2-maturity date; 3-1CALL/0PUT; 4-K; 5-bid; 6-ask;
%% Get index for each current days
alldata = sortrows(alldata,1);%Sort by current day
for i = 1:length(today_num)
    today_index = find(alldata(:,1) == today_num(i));
    start_i(i) = min(today_index);
    expire_dates = unique(alldata(today_index,2));
    expire_dates_ymd = datestr(datenum(string(expire_dates), 'yyyymmdd'),'yyyy/mm/dd');%num to dates
    
    %For given current date, sort this part by expiration date
    alldata(today_index,:) = sortrows(alldata(today_index,:),2);
    
    % Form the whole P-C list
    for j = 1:length(expire_dates)
        ttm(i,j) = daysact(today_ymd(i,:),expire_dates_ymd(j,:));%export ttm
        expire_index = find(alldata(today_index,2) == expire_dates(j));%inner index in each current day
        real_expire_index = expire_index + start_i(i) - 1; %real index in whole list
        begin_expire(i,j) = min(real_expire_index);%index of each option in alldata
        some_expire_list = alldata(real_expire_index,:);
        jth_day_call = some_expire_list(some_expire_list(:,3) == 1,:);%call option
        jth_day_put = some_expire_list(some_expire_list(:,3) == 0,:);
        %concatenate the p-c list for i_th current date
        if (i == 1) && (j == 1)
            data_pc = cat(2,jth_day_call,jth_day_put);
        else
            data_pc = cat(1, data_pc, cat(2,jth_day_call,jth_day_put));
        end
        
    end
end

%check if the dates and strikes fit between Put and Call;
ifdatefit = find(data_pc(:,1) ~= data_pc(:,1));
ifstrikefit = find(data_pc(:,4) ~= data_pc(:,10));

%delete extra columns
data_pc(:,[3,7,8,9,10]) = [];
%% RUN ONLY ONCE!
%Renew the index of each option in data_pc
for i = 1:size(begin_expire,1)
    num_of_option(i) = length(nonzeros(begin_expire(i,:)));
    begin_expire_trans = transpose(begin_expire);
    all_index = nonzeros(begin_expire_trans(:));       
end

new_index(1) = 1;
for i = 1:length(all_index)-1
    new_index(i+1) = new_index(i) + (all_index(i+1) - all_index(i))/2;
end
new_index(length(new_index)+1) = size(data_pc,1) + 1;
new_index = new_index';
%% Compute annualized ttm
ttm_trans = transpose(ttm);
ttm_annual = (nonzeros(ttm_trans(:))* 24 * 60 + 900 + 854)/525600;

%% compute mid price, left part is call
for i = 1:size(data_pc,1)
    data_pc(i,8) = (data_pc(i,4) + data_pc(i,5))/2;
    data_pc(i,9) = (data_pc(i,6) + data_pc(i,7))/2;
    data_pc(i,10) = abs(data_pc(i,8) - data_pc(i,9));%|call-put|
    data_pc(i,11) = data_pc(i,8) - data_pc(i,9);%call-put
end
% 1-current date; 2-expire date; 3-strike price; 4-call_bid; 5-call_ask;
% 6-put_bid; 7-put_ask; 8-call_mid; 9-put_mid; 10-|call-put|; 11-(call-put)
%% extract K0 and strike for each maturity
data_pc = sortrows(data_pc,[1,2,3]);%sort by 1-current date; 2-expire date; 3-strike price;
for i = 1:(length(new_index)-1)
    range_i = new_index(i):(new_index(i+1)-1);
    %compute K0
    min_cp = min(data_pc(range_i,10));
    mincp_index(i) = find(data_pc(range_i,10) == min_cp,1) + range_i(1) - 1;
    %compute F0
    F0(i) = data_pc(mincp_index(i),3) + exp(R * ttm_annual(i)) * data_pc(mincp_index(i),11);
    % renew K0 by F0
    K0_index(i) = find(data_pc(range_i,3) < F0(i),1,'last') + range_i(1) - 1;
    K0(i) = data_pc(K0_index(i),3);
    %Keep only the OTM option: 
    % 1-current date; 2-expire date; 3-strike price; 4-call_bid; 5-call_ask;
    % 6-put_bid; 7-put_ask; 8-call_mid; 9-put_mid; 10-|call-put|; 11-(call-put)
    % 12-OTM_bid; 13-P0/C1; 14-OTM_mid
    begin_i = min(range_i);
    end_i = max(range_i);
    data_pc(begin_i:K0_index(i),12) = data_pc(begin_i:K0_index(i),6);%12-OTM_Put_bid;
    data_pc(begin_i:K0_index(i),13) = 0;
    data_pc(begin_i:K0_index(i),14) = data_pc(begin_i:K0_index(i),9);
    data_pc(K0_index(i) + 1:end_i,12) = data_pc(K0_index(i) + 1:end_i,4);%12-OTM_Call_bid;
    data_pc(K0_index(i) + 1:end_i,13) = 1;
    data_pc(K0_index(i) + 1:end_i,14) = data_pc(K0_index(i) + 1:end_i,8);
    
    %find out two consecutive zero bid price
    %Firstly we consider begin --> K0
    zerobid_1 = find(data_pc(begin_i:K0_index(i),12) == 0);
    stop_1(i) = 0;% where the first two consecutive zero bid prices appear
    j = length(zerobid_1);
    if j > 1
        while zerobid_1(j) ~= zerobid_1(j-1) + 1
            if j == 2
                break
            end
            j = j - 1;
        end
        
        if j > 2
            stop_1(i) = zerobid_1(j) + begin_i - 1;%delete the entries of [begin_i,stop_1(i)]
        end
    end
       
    % Then we consider K0 --> end 
    zerobid_2 = find(data_pc(K0_index(i):end_i,12) == 0);
    stop_2(i) = 0;% where the first two consecutive zero bid prices appear
    k = length(zerobid_2);
    if k > 1
        j = 1;
        while zerobid_2(j) ~= zerobid_2(j+1) - 1
            j = j + 1;
            if j == k 
                break
            end
        end
        
        if j < k - 1
            stop_2(i) = zerobid_2(j) + K0_index(i) - 1;%delete the entries of [stop_2(i),end_i]
        end
    end
    
end 
%% delete STALE PRICE entries
% delete entries before and after two zero bid 
for i = 1:length(stop_1)
    if stop_1(i) > 0
        left_delete = new_index(i) : stop_1(i);
    end
    
    if stop_2(i) > 0
        right_delete = stop_2(i) : new_index(i + 1) - 1;
    end
    
    if i == 1
        delete_i = cat(2,left_delete,right_delete);
    else
        delete_i = cat(2, delete_i, cat(2,left_delete,right_delete));
    end
    
    left_delete = [];
    right_delete = [];
end

data_pc(delete_i,:) = [];

% delete all zero_bid options
zero_bid = find(data_pc(:,12) == 0);
data_pc(zero_bid,:) = [];

% delete extra columns
data_list = data_pc(:,[1,2,3,13,14]);
% data_list:     
% 1-current date; 2-expire date; 3-strike price; 13-P0/C1; 14-OTM_mid





save('toydata_list','data_list','today_num','today_ymd','ttm','ttm_annual');
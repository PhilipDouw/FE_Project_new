clearvars
%% Clear Workspace; rename the .dat as "ImportedData"
% load('Rawdata_Jan2004_Aug2012.mat');%result for 2004.01-2012.08(ttm: 8-40 days)
load('Rawdata_Sep2012_Jun2019.mat');%result for 2012.09-2019.06(ttm: 23-37 days)

load('yearRFrate.mat');%Annualized 30-day interest rate, daily data; Col1-date; Col2-interest rate
R_whole = table2array(yearRFinterestrate);

%replace NaN in R by linear interpolation
empty_r = find(isnan(R_whole(:,2)) == 1);

for i = 1:length(empty_r)
    R_whole(empty_r(i) , 2) = (R_whole(empty_r(i) + 1 , 2) + R_whole(empty_r(i) - 1 , 2)) / 2;
end

R_whole(:,2) = R_whole(:,2)/10000;


%% Some information

%About imported DATASET, indicators used here:
    %SYMBOL EXERCISE_STYLE CP_FLAG LAST_DATE OPEN_INTEREST EXDATE SECID 
    %INDEX_FLAG BEST_BID BEST_OFFER VOLUME STRIKE_PRICE FORWARD_PRICE

% Final result: data_list:     
% Columns: 1-current date; 2-expire date; 3-strike price; 4-P/C flag:
% P0/C1; 5-OTM_mid; 6-interest rate.

%Useful variables
% today_num (current date, numerical form: yyyymmdd)
% today_ymd (current date, date form: yyyy/mm/dd)
% ttm (time to maturity in daysa, a matrix)
% ttm_annual (time to maturity in years, a column)
%% %% Remove columes not needed

U_names = ImportedData.Properties.VariableNames;
delete_index = [1,3,5,10,11:16];
delete_names = U_names(delete_index);%get the names of deleted columns
ImportedData = removevars(ImportedData, delete_names);

%% Calculate t.t.m
today_num = unique(table2array(ImportedData(:,1)));%dates of current day - numerical 
%dates of current day - date string 
today_ymd = datestr(datenum(string(today_num), 'yyyymmdd'),'yyyy/mm/dd');

%SET P/C Flag: C-->1, P-->0
call_index = (table2array(ImportedData(:,3)) == 'C');%call is 1, and put is 0
ImportedData = addvars(ImportedData, call_index);
ImportedData = removevars(ImportedData, 3);


%% Let's work in an array!
alldata = table2array(ImportedData);%Now it's array! :)
alldata = alldata(:,[1,2,6,3,4,5]);% Change order of columns
%alldata: columns
%1-current date; 2-maturity date; 3-1CALL/0PUT; 4-K; 5-bid; 6-ask;


%get the right strike price
alldata(:,4) = alldata(:,4)/1000;
alldata = sortrows(alldata,[1,2,4]);%Sort by current day, expire day, strike

%% Get index for each current days
data_pc = [];
for i = 1:length(today_num)
    today_index = find(alldata(:,1) == today_num(i));
    start_i(i) = today_index(1);
    end_i(i) = today_index(end);
    expire_dates = unique(alldata(today_index,2));%all options traded today
    expire_dates_ymd = datestr(datenum(string(expire_dates), 'yyyymmdd'),'yyyy/mm/dd');%num to dates
    
   
    % Form the P-C list: match each K with its P & C prices
    for j = 1:length(expire_dates)%Option (i,j): ith current day, jth ttm day
        ttm(i,j) = daysact(today_ymd(i,:),expire_dates_ymd(j,:));%export ttm
        expire_index = find(alldata(today_index,2) == expire_dates(j));%inner index in each current day
        real_expire_index = expire_index + start_i(i) - 1; %real index in whole list
        begin_expire(i,j) = real_expire_index(1);%starting index of each option in alldata
        some_expire_list = alldata(real_expire_index,:);%list of one t.t.m options on day i
        jth_day_call = some_expire_list(some_expire_list(:,3) == 1,:);%(i,j)-call option
        jth_day_put = some_expire_list(some_expire_list(:,3) == 0,:);%(i,j)-put option
        
        %take P/C options with common K
        [C,ia,ib] = intersect(jth_day_call(:,4),jth_day_put(:,4));
        jth_day_call = jth_day_call(ia,:);
        jth_day_put = jth_day_put(ib,:);
        
        %concatenate the p-c list for i_th current date
        data_pc = cat(1, data_pc, cat(2,jth_day_call,jth_day_put));
        
        
    end
end

%data_pc: columns (1-6: CALL1, 7-12:PUT0)
%1-current date; 2-maturity date; 3-1CALL; 4-K; 5-bid; 6-ask;
%7-current date; 8-maturity date; 9-0PUT; 10-K; 11-bid; 12-ask;

%check if the dates and strikes fit between Put and Call;
ifdatefit = find(data_pc(:,1) ~= data_pc(:,7));
ifstrikefit = find(data_pc(:,4) ~= data_pc(:,10));

%delete extra columns
data_pc(:,[3,7,8,9,10]) = [];

%data_pc: columns(4,5: CALL; 6,7: PUT)
%1-current date; 2-maturity date; 3-K; 4-bid; 5-ask; 6-bid; 7-ask;
%% RUN ONLY ONCE!
%Renew the index of each option in data_pc
new_index = [];
for i = 1:length(today_num)
    today_index = find(data_pc(:,1) == today_num(i));
    options = unique(data_pc(today_index,2));
    
    for j = 1:length(options)
        index_1 = find(data_pc(today_index,2) == options(j), 1) + today_index(1) - 1;
        new_index = cat(2,new_index,index_1);
    end
end

new_index = cat(2,new_index, size(data_pc,1) + 1);
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

%data_pc: columns
% 1-current date; 2-expire date; 3-strike price; 4-call_bid; 5-call_ask;
% 6-put_bid; 7-put_ask; 8-call_mid; 9-put_mid; 10-|call-put|;
% 11-(call-put);
%% Add RF interest rate to column 15
data_pc = sortrows(data_pc,[1,2,3]);%sort by 1-current date; 2-expire date; 3-strike price;
[Lia,Locb] = ismember(today_num,R_whole(:,1));
for i = 1:length(today_num)
    data_pc(start_i(i):end_i(i), 15) = R_whole(Locb(i),2);
end
%data_pc: columns
% 1-current date; 2-expire date; 3-strike price; 4-call_bid; 5-call_ask;
% 6-put_bid; 7-put_ask; 8-call_mid; 9-put_mid; 10-|call-put|;
% 11-(call-put);15-RF rate 
%% extract F0 and K0 for each maturity

for i = 1:(length(new_index)-1)
    range_i = new_index(i):(new_index(i+1)-1);
    %compute K0
    min_cp = min(data_pc(range_i,10));%min|call-put| for each option
    mincp_index(i) = find(data_pc(range_i,10) == min_cp,1) + range_i(1) - 1;
    %compute F0
    F0(i) = data_pc(mincp_index(i),3) + exp(data_pc(mincp_index(i),15) * ttm_annual(i)) * data_pc(mincp_index(i),11);
    % renew K0 by F0
    if data_pc(range_i(1),3) > F0(i)
        K0_index(i) = range_i(1);
        K0(i) = data_pc(range_i(1),3);
    else
        K0_index(i) = find(data_pc(range_i,3) < F0(i),1,'last') + range_i(1) - 1;
        K0(i) = data_pc(K0_index(i),3);
    end  
    
    %Keep only the OTM option: 
    % data_pc columns:
    % 1-current date; 2-expire date; 3-strike price; 4-call_bid; 5-call_ask;
    % 6-put_bid; 7-put_ask; 8-call_mid; 9-put_mid; 10-|call-put|; 11-(call-put)
    % 12-OTM_bid; 13-P0/C1; 14-OTM_mid; 15-RF rate
    begin_i = min(range_i);
    end_i = max(range_i);
    data_pc(begin_i:K0_index(i),12) = data_pc(begin_i:K0_index(i),6);%12-OTM_Put_bid;
    data_pc(begin_i:K0_index(i),13) = 0;%OTM_Put
    data_pc(begin_i:K0_index(i),14) = data_pc(begin_i:K0_index(i),9);
    data_pc(K0_index(i) + 1:end_i,12) = data_pc(K0_index(i) + 1:end_i,4);%12-OTM_Call_bid;
    data_pc(K0_index(i) + 1:end_i,13) = 1;%OTM_Call
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
        while zerobid_2(j) ~= zerobid_2(j+1) - 1 %max j=k-1
            j = j + 1;
            if j == k 
                break %j=k
            end
        end
        
        if j < k
            stop_2(i) = zerobid_2(j) + K0_index(i) - 1;%delete the entries of [stop_2(i),end_i]
        end
    end
    
end 
%% delete STALE PRICE entries
% delete entries before and after two consecutive zero bids
delete_i = [];
for i = 1:length(stop_1)
    
    left_delete = [];
    if stop_1(i) > 0
        left_delete = new_index(i) : stop_1(i);
    end
    
    right_delete = [];
    if stop_2(i) > 0
        right_delete = stop_2(i) : new_index(i + 1) - 1;
    end
    
    delete_i = cat(2, delete_i, cat(2,left_delete,right_delete));
    
end

data_pc(delete_i,:) = [];

% delete all zero_bid options
zero_bid = find(data_pc(:,12) == 0);
data_pc(zero_bid,:) = [];

% delete extra columns
data_list = data_pc(:,[1,2,3,13,14,15]);
% data_list:     
% 1-current date; 2-expire date; 3-strike price; 4-P0/C1; 5-OTM_mid;6-RF interest rate

%Save variables
save('saved_vars','data_list','today_num','today_ymd','ttm','ttm_annual');
% today_num (current date, numerical form: yyyymmdd)
% today_ymd (current date, date form: yyyy/mm/dd)
% ttm (time to maturity in daysa, a matrix)
% ttm_annual (time to maturity in years, a column)
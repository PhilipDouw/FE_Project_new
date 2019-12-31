clearvars
%% clearvars -except C D
clearvars -except ImportedData R
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


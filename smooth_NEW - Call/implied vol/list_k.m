load('nearnext.mat', 'nearnext');

S = 2745.000;
r1 = (0.000305+1)^12-1;
r2 = (0.000286+1)^12-1;
t1 = 0.069090563;
t2 = 0.088268645;

%% build the whole list of strike
k1 = transpose(table2array(nearnext(:,4)));
k1 = k1(~isnan(k1));
k2 = transpose(table2array(nearnext(:,8)));
k2 = k2(~isnan(k2));
k = transpose(union(k1,k2));
length_k = length(k);
%% % List the Option prices of near and next term by whole k list; leave it empty when strikes don't exist
price1 = table2array(nearnext(:,3));%length k1
price2 = table2array(nearnext(:,7));%length k2
[Lia1,Locb1] = ismember(k,k1);
[Lia2,Locb2] = ismember(k,k2);

price1_k = zeros(length_k,1);%length k
price2_k = zeros(length_k,1);%length k

for i = 1:length_k
    if Locb1(i) == 0
        price1_k(i) = NaN;
    else
        price1_k(i) = price1(Locb1(i));
    end
    
    if Locb2(i) == 0
        price2_k(i) = NaN;
    else
        price2_k(i) = price2(Locb2(i));
    end
end

%% calculate implied vol
% Volatility = blsimpv(Price,Strike,Rate,Time,Value)
imp1 = zeros(length_k, 1);
imp2 = zeros(length_k, 1);
index_k0 = find(k(:) == 2745);%Find the place of K0, it's the same for Near & Next on 03.06.2019

%Split the Call and Put Option, K0,1 = K0,2 = 2745
for i = 1:length_k
    if i < index_k0
        imp1(i) = blsimpv(S, k(i), r1, t1, price1_k(i));
        imp2(i) = blsimpv(S, k(i), r2, t2, price2_k(i));
    else
        imp1(i) = blsimpv(S, k(i), r1, t1, price1_k(i),'Class', {'Put'});
        imp2(i) = blsimpv(S, k(i), r2, t2, price2_k(i),'Class', {'Put'});
    end
end 
%% output 
%
% S = repelem(S,length_k)';
% r1 = repelem(r1,length_k)';
% r2 = repelem(r2,length_k)';
% t1 = repelem(t1,length_k)';
% t2 = repelem(t2,length_k)';

ivs = [imp1*100,imp2*100];
dax = S;
maturity_days = [25, 32];
q = 0;
r = [r1*1000; r2*1000];%????????
strike = k;

%% 

save('data_20190603_25_32','ivs','dax','maturity_days','q','r','strike');
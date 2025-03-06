


loadtable = readtable('NVDA.csv');
loadprice = loadtable(:,5);
loadprice = table2array(loadprice);
%loadprice = loadprice(6000:end);

[indicator,SUMMA13,SUMMA8,SUMMA5,debug13,debug8,debug5] = Aligator_Form(loadprice);
report = zeros(8,length(indicator));
money = zeros(1,length(indicator));
shares = zeros(1,length(indicator));
buffer = zeros(1,length(indicator));

money(1:13) = 1000;
shares(1) = 0;

for i = 14:length(indicator)
    %buffer(i) = sum(indicator(i-9:i-1));
    buffer(i) = 0;
    if (indicator(i) == 1 && (money(i-1) > loadprice(i)) && (buffer(i) < 1)) %if buy
        shares(i) = shares(i-1)+floor(money(i-1)/loadprice(i));
        money(i) = money(i-1) - (floor(money(i-1)/loadprice(i)) * loadprice(i));
    elseif (indicator(i) == 2 && (shares(i-1) > 0) && (buffer(i) < 1)) %if sell
        money(i) = shares(i-1) * loadprice(i) + money(i-1);
        shares(i) = 0;
    else
        shares(i) = shares(i-1);
        money(i) = money(i-1);
    end
end

report(1,:) = loadprice;
report(2,:) = indicator;
report(3,:) = shares;
report(4,:) = money;
report(5,:) = SUMMA13;
report(6,:) = SUMMA8;
report(7,:) = SUMMA5;
report(8,:) = buffer;

report = report';
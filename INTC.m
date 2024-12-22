%establish the Mamdami FIS
fis = mamfis("Name","Conf Index");

%Add inputs for the Mamdami FIS
fis = addInput(fis, [-100 100], 'Name', 'PriceDifferential'); 
fis = addMF(fis, 'PriceDifferential', 'trimf', [-12 -10 -6], 'Name', 'Significant_Loss');
fis = addMF(fis, 'PriceDifferential', 'trimf', [-10 -6 -4], 'Name', 'Major_Loss');
fis = addMF(fis, 'PriceDifferential', 'trimf', [-6 -4 -2], 'Name', 'Big_Loss');
fis = addMF(fis, 'PriceDifferential', 'trimf', [-4 -2 0], 'Name', 'Small_Loss');
fis = addMF(fis, 'PriceDifferential', 'trimf', [-2 0 2], 'Name', 'Zero');
fis = addMF(fis, 'PriceDifferential', 'trimf', [0 2 4], 'Name', 'Small_Gain');
fis = addMF(fis, 'PriceDifferential', 'trimf', [2 4 6], 'Name', 'Big_Gain');
fis = addMF(fis, 'PriceDifferential', 'trimf', [4 6 10], 'Name', 'Major_Gain');
fis = addMF(fis, 'PriceDifferential', 'trimf', [6 10 12], 'Name', 'Significant_Gain');

fis = addInput(fis, [0 10], 'Name', 'Volume');
fis = addMF(fis, 'Volume', 'gbellmf', [3 4 0], 'Name', 'Low');
fis = addMF(fis, 'Volume', 'gbellmf', [3 4 5], 'Name', 'Medium');
fis = addMF(fis, 'Volume', 'gbellmf', [3 4 10], 'Name', 'High');


%Add the output
fis = addOutput(fis, [0 100], 'Name', 'Confidence');
fis = addMF(fis, 'Confidence', 'gbellmf', [20 4 0], 'Name', 'Low');
fis = addMF(fis, 'Confidence', 'gbellmf', [20 4 50], 'Name', 'Medium');
fis = addMF(fis, 'Confidence', 'gbellmf', [20 4 100], 'Name', 'High');

%Rule Base
rule1 = "If PriceDifferential is Significant_Loss then Confidence is Low";
rule2 = "If PriceDifferential is Major_Loss then Confidence is Low";
rule3 = "If PriceDifferential is Big_Loss and Volume is Low then Confidence is Medium";
rule4 = "If PriceDifferential is Big_Loss and Volume is Medium then Confidence is Low";
rule5 = "If PriceDifferential is Big_Loss and Volume is High then Confidence is Low";
rule6 = "If PriceDifferential is Small_Loss and Volume is Low then Confidence is Low";
rule7 = "If PriceDifferential is Small_Loss and Volume is Medium then Confidence is Medium";
rule8 = "If PriceDifferential is Small_Loss and Volume is High then Confidence is Medium";
rule9 = "If PriceDifferential is Small_Gain and Volume is Low then Confidence is Medium";
rule10 = "If PriceDifferential is Small_Gain and Volume is Medium then Confidence is Medium";
rule11 = "If PriceDifferential is Small_Gain and Volume is High then Confidence is Medium";
rule12 = "If PriceDifferential is Big_Gain and Volume is Low then Confidence is Medium";
rule13 = "If PriceDifferential is Big_Gain and Volume is Medium then Confidence is High";
rule14 = "If PriceDifferential is Big_Gain and Volume is High then Confidence is High";
rule15 = "If PriceDifferential is Significant_Gain and Volume is Low then Confidence is Medium";
rule16 = "If PriceDifferential is Significant_Gain and Volume is Medium then Confidence is High";
rule17 = "If PriceDifferential is Significant_Gain and Volume is High then Confidence is High";
rule18 = "If PriceDifferential is Zero then Confidence is Low";


fis = addRule(fis, [rule1 rule2 rule3 rule4 rule5 rule6 rule7 rule8 rule9 rule10...
    rule11 rule12 rule13 rule14 rule15 rule16 rule17]);

loadtable = readtable('NVDA.csv');

loaddate = loadtable(:,1);
loaddate = table2array(loaddate);
loadprice = loadtable(:,5);
loadprice = table2array(loadprice);
loadvol = loadtable(:,6);
loadvol = table2array(loadvol);


hindsight = zeros(length(loadprice),6);
hindsight(1,1) = loadprice(1);
hindsight(1,2) = loadvol(1);

funds = 1000;
bal = 0;
lastaction = 0;
shares = 0;

for currentdate = 2:length(loaddate)
    curprice = loadprice(currentdate);
    curvol = loadvol(currentdate);

    pricediff = ((curprice/hindsight(currentdate-1)-1)) * 100;
    volrange = (curvol/(max(hindsight(2:end,2)))*10);
    
    hindsight(currentdate,1) = curprice;
    hindsight(currentdate,2) = curvol;
    hindsight(currentdate,3) = pricediff;
    hindsight(currentdate,4) = volrange;


    evaluate = evalfis([pricediff volrange], fis);
    
    hindsight(currentdate,5) = evaluate;

    if currentdate>10
        meanval = mean(hindsight(currentdate-10:currentdate,5));
        if (evaluate < meanval - 20) && (lastaction ~= 1)
            shares = funds/curprice;
            bal = shares * curprice;
            funds = funds-bal;
            lastaction = 1;
            hindsight(currentdate,6) = lastaction;
            temphold = bal;
        elseif (evaluate > meanval + 25) && (lastaction ~= 0)
            funds = shares*curprice;
            bal = 0;
            lastaction = 0;
            shares = 0;
            hindsight(currentdate,6) = lastaction;
            temphold = funds - temphold;
            hindsight(currentdate,7) = temphold;
        else 
            hindsight(currentdate,6) = 2;
        end
    end

end

buynhold = 26525 * curprice;

%First col is the price for the day at close
%Second col is the vol for that day
%Third col is the price diff %
%Fourth col is the vol score (vol/max all time so far)
%Fifth column is the fuzzy eval score
%Sixth col is the buy/sell/hold (1/0/2)
%Seventh col is the G/L from the prev transaction
clear
format long;
%establish the Mamdami FIS
fis = mamfis("Name","Conf Index");

%Add inputs for the Mamdami FIS
fis = addInput(fis, [-10 10], 'Name', 'PriceDifferential'); 
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

fis = addInput(fis, [0 100], 'Name', 'PastConfidence');
fis = addMF(fis, 'PastConfidence', 'gbellmf',[3 4 0], 'Name', 'LowConfidence');
fis = addMF(fis, 'PastConfidence', 'gbellmf',[3 4 50], 'Name', 'MedConfidence');
fis = addMF(fis, 'PastConfidence', 'gbellmf',[3 4 100], 'Name', 'HighConfidence');

%Add the output
fis = addOutput(fis, [0 100], 'Name', 'Confidence');
fis = addMF(fis, 'Confidence', 'gbellmf', [20 4 0], 'Name', 'Low');
fis = addMF(fis, 'Confidence', 'gbellmf', [20 4 50], 'Name', 'Medium');
fis = addMF(fis, 'Confidence', 'gbellmf', [20 4 100], 'Name', 'High');

%Rule Base
rule1 = "If PriceDifferential is Significant_Loss then Confidence is Low";
rule2 = "If PriceDifferential is Major_Loss then Confidence is Medium";
rule3 = "If PriceDifferential is Big_Loss and Volume is Low then Confidence is Medium";
rule4 = "If PriceDifferential is Big_Loss and Volume is Medium then Confidence is Medium";
rule5 = "If PriceDifferential is Big_Loss and Volume is High then Confidence is Medium";
rule6 = "If PriceDifferential is Small_Loss and Volume is Low then Confidence is Medium";
rule7 = "If PriceDifferential is Small_Loss and Volume is Medium then Confidence is Low";
rule8 = "If PriceDifferential is Small_Loss and Volume is High then Confidence is Low";
rule9 = "If PriceDifferential is Small_Gain and Volume is Low then Confidence is Medium";
rule10 = "If PriceDifferential is Small_Gain and Volume is Medium then Confidence is High";
rule11 = "If PriceDifferential is Small_Gain and Volume is High then Confidence is High";
rule12 = "If PriceDifferential is Big_Gain and Volume is Low then Confidence is High";
rule13 = "If PriceDifferential is Big_Gain and Volume is Medium then Confidence is Medium";
rule14 = "If PriceDifferential is Big_Gain and Volume is High then Confidence is Medium";
rule15 = "If PriceDifferential is Significant_Gain and Volume is Low then Confidence is Low";
rule16 = "If PriceDifferential is Significant_Gain and Volume is Medium then Confidence is Medium";
rule17 = "If PriceDifferential is Significant_Gain and Volume is High then Confidence is Medium";
%rule18 = "If PriceDifferential is Zero then Confidence is High";
rule19 = "If PastConfidence is LowConfidence then Confidence is Low";
rule20 = "If PastConfidence is MedConfidence then Confidence is Medium";
rule21 = "If PastConfidence is HighConfidence then Confidence is High";

fis = addRule(fis, [rule1 rule2 rule3 rule4 rule5 rule6 rule7 rule8 rule9 rule10...
    rule11 rule12 rule13 rule14 rule15 rule16 rule17 rule19 rule20 rule21]);

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
maxvol = 150;
mehvol = 30;
Eval = 50;

for currentdate = 2:length(loaddate)
    curprice = loadprice(currentdate);
    curvol = loadvol(currentdate);
    if currentdate <= 3
        pricediff = 0;
    else
        pricediffarr(1) = ((curprice/hindsight(currentdate-1)-1)) * 100;
        pricediffarr(2) = ((hindsight(currentdate-1)/hindsight(currentdate-2)-1)) * 100;
        pricediffarr(3) = ((hindsight(currentdate-2)/hindsight(currentdate-3)-1)) * 100;

        if ((pricediffarr(1) < pricediffarr(2)) && (pricediffarr(2) < pricediffarr(3)) && abs(pricediffarr(1)) <= 1)
            pricediff = pricediffarr(1);
        elseif ((pricediffarr(1) > pricediffarr(2)) && (pricediffarr(2) > pricediffarr(3)) && abs(pricediffarr(1)) <= 1)
            pricediff = pricediffarr(1);
        else
            pricediff = 5;
        end
    end
    volrange = (curvol/(max(hindsight(2:end,2)))*10);
    
    hindsight(currentdate,1) = curprice;
    hindsight(currentdate,2) = curvol;
    hindsight(currentdate,3) = pricediff;
    hindsight(currentdate,4) = volrange;

    if currentdate == 1
        PastConfidence = 50;
    else
        PastConfidence = Eval;
    end

    Eval = evalfis([pricediff volrange PastConfidence], fis);
    
    

    hindsight(currentdate,5) = Eval;
    stdev = std(hindsight(1:currentdate,5));
    hindsight(currentdate,8) = stdev;
    hindsight(currentdate,7) = funds;

    
    if currentdate>10
        
        rollmean = mean(hindsight(currentdate-10:currentdate,5));
        hindsight(currentdate,9) = rollmean;
        if Eval-(2*stdev) >= rollmean
            %Sell bigly
            if shares > maxvol
                funds = funds + (curprice*maxvol);
                hindsight(currentdate,7) = funds;
                shares = shares - maxvol;
                lastaction = 1;
                hindsight(currentdate,6) = lastaction;
            else
                funds = funds + (curprice*shares);
                hindsight(currentdate,7) = funds;
                shares = 0;
                lastaction = 1;
                hindsight(currentdate,6) = lastaction;
            end
            
        elseif Eval-(1.2*stdev) >= rollmean
            %Sell meh
            if shares > mehvol
                funds = funds + (curprice*mehvol);
                hindsight(currentdate,7) = funds;
                shares = shares - mehvol;
                lastaction = 2;
                hindsight(currentdate,6) = lastaction;
            else
                funds = funds + (curprice*shares);
                hindsight(currentdate,7) = funds;
                shares = 0;
                lastaction = 2;
                hindsight(currentdate,6) = lastaction;
            end
            
        elseif Eval + (2*stdev) <= rollmean
            %buy bigly
            if funds > (curprice*maxvol)
                funds = funds - (curprice*maxvol);
                hindsight(currentdate,7) = funds;
                shares = shares + maxvol;
                lastaction = 4;
                hindsight(currentdate,6) = lastaction;
            else
                funds = funds - floor(funds/curprice)*curprice;
                hindsight(currentdate,7) = funds;
                shares = shares + floor(funds/curprice);
                lastaction = 4;
                hindsight(currentdate,6) = lastaction;
            end
               
        elseif Eval + (1.2 * stdev) <= rollmean
            %buymeh
            if funds > (curprice*mehvol)
                funds = funds - (curprice*mehvol);
                hindsight(currentdate,7) = funds;
                shares = shares + mehvol;
                lastaction = 3;
                hindsight(currentdate,6) = lastaction;
            else
                funds = funds - floor(funds/curprice)*curprice;
                hindsight(currentdate,7) = funds;
                shares = shares + floor(funds/curprice);
                lastaction = 3;
                hindsight(currentdate,6) = lastaction;
            end
            
        else
            hindsight(currentdate,6) = 0;
        end
        hindsight(currentdate,10) = shares;
        hindsight(currentdate,11) = funds + shares*curprice;
    end

end

buynhold = 26525 * curprice;

hindsight = array2table(hindsight);
hindsight.Properties.VariableNames = ["Current Price","Current Volume",...
        "Price Differential","Volume Range","Fuzzy Confidence","Last Action","Available Funds"...
        "Standard Deviation of Sample", "10 Day Rolling Mean","Shares","Net Present Worth"];

%First col is the price for the day at close
%Second col is the vol for that day
%Third col is the price diff %
%Fourth col is the vol score (vol/max all time so far)
%Fifth column is the fuzzy eval score
%Sixth col is the buy/sell/hold (1/0/2)
%Seventh col is the G/L from the prev transaction
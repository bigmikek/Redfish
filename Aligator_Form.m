function [indication,SUMMA13,SUMMA8,SUMMA5,debug13, debug8, debug5] = Aligator_Form(input_vector)
input_price = input_vector; %placeholder
indicator = zeros(1,length(input_price));

SUMMA1_13 = zeros(1,length(input_price));
SUMMA1_8 = zeros(1,length(input_price));
SUMMA1_5 = zeros(1,length(input_price));


SUM13 = zeros(1,length(input_price));
SUM8 = zeros(1,length(input_price));
SUM5 = zeros(1,length(input_price));

PREV_SUM_13 = zeros(1,length(input_price));
PREV_SUM_8 = zeros(1,length(input_price));
PREV_SUM_5 = zeros(1,length(input_price));

SUMMA13 = zeros(1,length(input_price));
SUMMA8 = zeros(1,length(input_price));
SUMMA5 = zeros(1,length(input_price));

%13 Day Moving Average
for i = 13:length(input_price)
    SUM13(i) = sum(input_price(i-12:i));
    SUMMA1_13(i) = SUM13(i)/13;
end

for i = 14:length(input_price)
    PREV_SUM_13(i) = SUMMA1_13(i-1)*13;
    SUMMA13(i) = (PREV_SUM_13(i) - SUMMA1_13(i-1) + input_price(i))/13;
end

%8 Day Moving Average
for i = 8:length(input_price)
    SUM8(i) = sum(input_price(i-7:i));
    SUMMA1_8(i) = SUM8(i)/8;
end

for i = 9:length(input_price)
    PREV_SUM_8(i) = SUMMA1_8(i-1)*8;
    SUMMA8(i) = (PREV_SUM_8(i) - SUMMA1_8(i-1) + input_price(i))/8;
end

%5 Day Moving Average
for i = 5:length(input_price)
    SUM5(i) = sum(input_price(i-4:i));
    SUMMA1_5(i) = SUM5(i)/5;
end

for i = 6:length(input_price)
    PREV_SUM_5(i) = SUMMA1_5(i-1)*5;
    SUMMA5(i) = (PREV_SUM_5(i) - SUMMA1_5(i-1) + input_price(i))/5;
end

%Logic Calculation
for i = 14:length(input_price)
    if ((SUMMA5(i) >= SUMMA8(i)) && (SUMMA5(i-1) <= SUMMA8(i-1)))
        indicator(i) = 1; %BUY
    elseif ((SUMMA5(i) <= SUMMA8(i)) && (SUMMA5(i-1)>= SUMMA8(i-1)))
        indicator(i) = 2; %SELL
    else
        indicator(i) = 0; %HOLD
    end
end

debug13 = zeros(4,length(input_price));
debug13(1,:) = SUM13;
debug13(2,:) = SUMMA1_13;
debug13(3,:) = PREV_SUM_13;
debug13(4,:) = SUMMA13;

debug8 = zeros(4,length(input_price));
debug8(1,:) = SUM8;
debug8(2,:) = SUMMA1_8;
debug8(3,:) = PREV_SUM_8;
debug8(4,:) = SUMMA8;

debug5 = zeros(4,length(input_price));
debug5(1,:) = SUM5;
debug5(2,:) = SUMMA1_5;
debug5(3,:) = PREV_SUM_5;
debug5(4,:) = SUMMA5;

debug13 = debug13';
debug8 = debug8';
debug5 = debug5';
indication = indicator';
end
% Create a fuzzy inference system (FIS) for a simple tipping scenario
fis = mamfis('Name','Tipper');  

% Add input variables with membership functions
fis = addInput(fis, [0 10], 'Name', 'Service'); 
fis = addMF(fis, 'Service', 'gbellmf', [1 0 5], 'Name', 'Poor');
fis = addMF(fis, 'Service', 'trimf', [0 5 10], 'Name', 'Good');
fis = addMF(fis, 'Service', 'trimf', [5 10 10], 'Name', 'Excellent'); 

fis = addInput(fis, [0 10], 'Name', 'Food');
fis = addMF(fis, 'Food', 'trimf', [0 0 5], 'Name', 'Rancid');
fis = addMF(fis, 'Food', 'trimf', [0 5 10], 'Name', 'Average');
fis = addMF(fis, 'Food', 'trimf', [5 10 10], 'Name', 'Delicious'); 

% Add output variable with membership functions
fis = addOutput(fis, [0 30], 'Name', 'Tip');
fis = addMF(fis, 'Tip', 'trimf', [0 5 10], 'Name', 'Low');
fis = addMF(fis, 'Tip', 'trimf', [5 15 20], 'Name', 'Medium');
fis = addMF(fis, 'Tip', 'trimf', [15 25 30], 'Name', 'High'); 

% Define fuzzy rules

rules = [
    1 1 1 1 1;  % If service is poor and food is rancid, then tip is low
    2 2 2 1 1;  % If service is good and food is average, then tip is medium
    3 3 3 1 1;  % If service is excellent and food is delicious, then tip is high
];
fis = addRule(fis, rules);

% Evaluate the fuzzy system
service_input = 1;  % Example service rating
food_input = 1;    % Example food rating
output = evalfis([service_input food_input], fis); 

disp(['Recommended tip: ', num2str(output)]); 
%% Ruairidh Barlow
% ECG and Accelerometer signal processing
% Revised: 1/21/2020

%%
function [finalframe, BPM, distance] = BMP_freq(peak_x_values, L,Fs)

% Creating a dataframe to store calculations

distance = diff(peak_x_values);

for i = 1:numel(distance)
    D = distance(i) / Fs;
    F = 60 / D;    
    C{i} = F * ones(distance(i),1);
    % interporlate
    % this stores the same instantanous BMP distance number of times 
end
    
dataframe_out = cell2mat(C');

% File is not the same length 
first = dataframe_out(1);
last  = dataframe_out(end);

% get the BPM at the beginning and the end of the file

first_loop = peak_x_values(1);
last_loop = L - (length(dataframe_out)+ first_loop);
%calculate the missing difference

finalframe = zeros(1);


for i = 1:first_loop
    finalframe = [finalframe ; first];
end
%Add the first value x amount of times

for i = 1:length(dataframe_out)
    finalframe = [finalframe ; dataframe_out(i)];
end
% add values from dataframe

for i = 1:last_loop
    finalframe = [finalframe ; last];
end
%Add last value until files are the same length 
finalframe = finalframe(2:end);
BPM = mean(finalframe);

end
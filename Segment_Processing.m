%% Ruairidh Barlow
% ECG and Accelerometer signal processing
% Revised: 1/21/2020

%%
function [valid_x, valid_y, stan_dis] = Segment_Processing(Seg, start, Fs_accel, high, low, distance, height)
% RETURNS FILTERED SIGNAL

% This function is based off the method used in Cysarz et al., 2008

start_pos = start - 1;                            % Used for correcting coordiantes
%% Filtering

% filtering the signal drift out of the segment
[b,a]=butter(1, high/(Fs_accel/2), 'high');
filt_dis=filtfilt(b,a,Seg); % filtering the singal
[c,d] = butter(1,low,'low');
filt_dis=filtfilt(c,d,filt_dis); % filtering the singal
%% Finding peaks
filt_dis = filt_dis';
[dis_y_values, dis_x_values] = findpeaks(filt_dis(:,1), 'MinPeakDistance', 250, 'MinPeakHeight', 0);

% finding peaks at a 250 interval about 5 seconds
%% Percentile
ordered_peaks = sort(dis_y_values);
percentile = prctile(ordered_peaks, 70);               % calculating 75th percentile of detected peaks
stan_dis = filt_dis(1:end);                            % copying filt_dis signal 
stan_dis = stan_dis / percentile;

%% Valid Cycle
% detecting peaks again
[stan_y_values, stan_x_values] = findpeaks(stan_dis(:,1), 'MinPeakDistance', distance, 'MinPeakHeight', height);

percentile_y = prctile(stan_y_values, 30);     % Calculating 30th percentile

valid_peaks = stan_y_values > percentile_y;    % peaks that fall under the 30th percentile are valid cycles
   
valid_x = stan_x_values(valid_peaks);
valid_x = valid_x + start_pos;
valid_y = stan_y_values(valid_peaks);

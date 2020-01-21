%% Ruairidh Barlow
% ECG and Accelerometer signal processing
% Revised: 1/21/2020

%% Import data
% Ensure file and function importfile are in working directory

ECG = importfile("BARLOW_ECG.csv",[3, 286571] ); % File name and import range
                                                 % Accounts for header and sensor 
                                                 % falling off during last portion of data collection

% 286569 samples / 125 hz = 2,292.552 / 60 = 38.2092 min

ACM_X = importfile("BARLOW_ACM_X.csv",[3,Inf]); % 118352 / 50/ 60 = 39.45, note the cut off is different 
ACM_Y = importfile("BARLOW_ACM_Y.csv",[3,Inf]);
ACM_Z = importfile("BARLOW_ACM_Z.csv",[3,Inf]);

%resp_data = importfile("BARLOW_RESP.csv", [3,Inf]);
figure
plot(ACM_X)
title("X Axis")
%% Creating variables to be used later
Fs  = 125;               % Sampling frequency for ECG
Fs_accel = 50;           % Sampling rate for breathing
L = length(ECG);         % Saving length of ECG signal 
L_accel = length(ACM_X); % Saving length of accel signal
%% Ploting the Spectrum from Dr. Chen
% Ensure SpectraPlot file is in working directory
SpectraPlot(ECG, Fs, 'r')

%% butterworth filter design and implementation 

% Convert from frequency in Hz to normalized frequency divide the desired 
% cutoff frequency in Hz by 1/2 the sampling freq. (unit conversion maybe?)
% in spectraplot we are multiplying by (Fs/2) to get the nyquist frequncy
% For digital filters, the cutoff frequencies must lie between 0 and 1
% where 1 corresponds to the Nyquist rate—half the sample rate or ? rad/sample.

[b,a]=butter(1,0.2,'high');     % filter order, cutoff frequency, filter type
                                % returns the transfer function coeffecicents as a vector length of first order 
                                % plus 1. This means that vectors A and B and 2 long
                                % high pass filter: only allows freq that are higher than the cutoff through


filt=filtfilt(b,a,ECG);         % Fitler signal using zero phase digital fitlering to reduce signal noise
                                % This function preserves features that are in the oringinal time waveform
                                % Hz, cutoff, and signal



[c,d] = butter(1,0.5,'low');    % Use low pass filter to get rid of jitters
                                % 0.9 is used here because that is where the jitters start
                                % Note that the jitters are everything that is past 0.9 hz
filt = filtfilt(c,d,filt);

% figure
% plot(filt)
% title('Filtered ECG Dataset');
% xlabel('Samples');
% ylabel('ADC');
%% Peak Detection function

[peak_y_values, peak_x_values] = findpeaks(filt(:,1), 'MinPeakDistance', 25, 'MinPeakHeight', 7000);
% find peaks function parameters are an input signal, minimum peak distance
% in samples, and minimum peak height in sampels

% Plotting Peaks
figure
plot(peak_x_values, peak_y_values, 'ro')
hold on;
plot(filt)
title('Filtered ECG Dataset');
xlabel('Samples');
ylabel('ADC');
%% BPM Calculations
% Ensure that functions are in the same working directory

beat_count = length(peak_x_values);
% number of beats from find signal function

BMP_overall = overall_BMP(beat_count,L, Fs);
%                         beats, length of ECG Signal, Hz
[dataframe_nooverlap,avg_BPM_nooverlap,dataframe_overlap,avg_BPM_overlap] = Buffer(filt,1000, 100, Fs, peak_y_values);
% Function returns overlapping and non overlapping BMP averages for a given 
% signal. Also it returns the data structures for investigation 

% THERE IS A PROBLEM WITH THE BUFFER FUNCTION. OVERLAP IS CREATING A LONGER
% SIGNAL WHICH MAKES SENSE
[BMP_frequency, freq_avg_BPM, distance] = BMP_freq(peak_x_values, L, Fs);
                         %pass in the X values of the found peaks and
                         %length of ECG signal


%% Print statements and BPM Checkers
BMP_overall
avg_BPM_nooverlap
avg_BPM_overlap
freq_avg_BPM

%% Plotting BPMs
figure
plot(dataframe_nooverlap(1:L), 'b')
ylim([20,100])
hold on
plot(dataframe_overlap(1:L), 'g')
ylim([20,100])
hold on 
plot(BMP_frequency, 'r')
ylim([20,100])
title('Change in BPM Over Time');
xlabel('Samples');
ylabel('BPM');

%% Respiratory Sinus Arrhythmia (RSA)

% tt = interp1(x,v,xq)   
% Vector x contains the sample points
% v contains the corresponding values, v(x). 
% Vector xq contains the coordinates of the query points.

peak_loc = (peak_x_values(:,1)); %% peak locations
RR = diff(peak_loc);
tt = interp1(peak_loc,[0;RR], peak_loc(1):peak_loc(end), 'spline');


%%% resample %%%
tt_re = resample(tt, Fs_accel, 125);        % changing the sampling rate to match the sampling rate of the accelerometer dataset
ACM_X = ACM_X(1:length(tt_re));             % changing the lenght of the accelerometer singal to match the ECG signal lenght

%% Segmenting Signal %% 

% Creating different segments of the resampled ECG signal in order to
% better process each different type of motion
Seg_1 = tt_re(1: 45437);

Seg_2 = tt_re(45438 : 61921);

Seg_3 = tt_re(61922 : 73841);

Seg_4 = tt_re(73842 : 89776);

Seg_5 = tt_re(89777 : 104020 );

Seg_6 = tt_re(104021 : length(tt_re));

% sending segments to Segment_processing function, note each segment is
% different so the frequency cutoffs have to be set by hand
[valid_x1, valid_y1, nSeg_1] = Segment_Processing(Seg_1, 1, Fs_accel, 0.3, 0.9, 180, 0);
[valid_x2, valid_y2, nSeg_2] = Segment_Processing(Seg_2, 45438, Fs_accel, 0.5, 0.9, 40, 0.25);
[valid_x3, valid_y3, nSeg_3] = Segment_Processing(Seg_3, 61922, Fs_accel, 0.4, 0.9, 50, 0);
[valid_x4, valid_y4, nSeg_4] = Segment_Processing(Seg_4, 73842, Fs_accel, 0.4, 0.9, 10, 0);
[valid_x5, valid_y5, nSeg_5] = Segment_Processing(Seg_5, 89777, Fs_accel, 0.2, 0.9, 50, 0);
[valid_x6, valid_y6, nSeg_6] = Segment_Processing(Seg_6, 104021, Fs_accel, 0.6, 0.9, 10, 0);

% Combining the valid respiration cycles for the x and y plain
valid_x = vertcat(valid_x1, valid_x2, valid_x3, valid_x4, valid_x5, valid_x6);
valid_y = vertcat(valid_y1, valid_y2, valid_y3, valid_y4, valid_y5, valid_y6);
valid_signal = vertcat(nSeg_1,nSeg_2,nSeg_3,nSeg_4,nSeg_5,nSeg_6);

%% Resp rate

% calculating the respiration rate for each window

window_size = 1500; % setting window size
overlap = 1000; % setting overlap
[overlap_correct] = resp_rate(window_size,overlap, valid_signal, valid_y); % calling resp_rate function to calculate the number of breaths for each window

figure;
plot(overlap_correct, 'g')
hold on;
plot(ACM_X / 10e2, 'r');  
title('Rate of Respiration Overlaid on Accelerometer Signal');
xlabel('Samples');
ylabel('Number of Breathes');

%% freq

% calculating the number of breaths using the frequncy based method
[resp_rate, resp_avg_BPM, resp_distance] = BMP_freq(valid_x, length(valid_signal), 50);

figure;
plot(resp_rate, 'g')
hold on;
plot(ACM_X / 10e2, 'r');  
title('Rate of Respiration Overlaid on Accelerometer Signal');
xlabel('Samples');
ylabel('Number of Breathes');
%% Plots

filt_re = resample(filt, Fs_accel, 125);

figure;
plot(valid_signal);
hold on ;
plot(valid_x, valid_y, 'ro');
hold on;
plot(ACM_X / 10e3, 'r');
title('Respiration Signal Overlaid on Accelerometer Signal');
xlabel('Samples');
ylabel('Amplitude');  

figure;
plot(resp_rate, 'g');
hold on;
plot(valid_signal * 10);
hold on ;
plot(valid_x, valid_y*10, 'ro');

freq_re = resample(BMP_frequency, Fs_accel, 125);
figure;
plot(freq_re, 'r');
hold on;
plot(overlap_correct * 10, 'g');


figure;
plot(freq_re, 'r');
hold on;
title('Change in BPM Over Time');
xlabel('Samples');
ylabel('BPM');  

figure;
plot(overlap_correct, 'g');
title('Change in Respiration Over Time');
xlabel('Samples');
ylabel('Number of Breathes');



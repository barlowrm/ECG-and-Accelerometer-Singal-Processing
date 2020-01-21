%% Ruairidh Barlow
% ECG and Accelerometer signal processing
% Revised: 1/21/2020

%%
function [BPM] = overall_BMP(beat_count,signal_length, frequency)
%Convert to BMP by dividing the beats counted by the signal duration
%This was sampled at 125 Hz
duration_sec = signal_length / frequency;
% Convert duration into seconds 
duration_min = duration_sec / 60;
% Convert into minutes
BPM = beat_count / duration_min;
%Calculates beats per minute
end


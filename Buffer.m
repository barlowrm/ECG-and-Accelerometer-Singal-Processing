%% Ruairidh Barlow
% ECG and Accelerometer signal processing
% Revised: 1/21/2020

%%
function [dataframe_nooverlap,avg_BPM_nooverlap,dataframe_overlap,avg_BPM_overlap] = Buffer(signal,window_size, overlap, Fs, Peaks)
% Non-overlapping
A = buffer(signal,window_size);
% breaking up the signal into windows of desired size
% saving number of rows
colA = size(A,2);
% saving number of columns


% Overlapping
B = buffer(signal,window_size, overlap, 'nodelay');
% same thing as before, this time incorporating overlap
colB = size(B,2);

% function call

[dataframe_nooverlap,avg_BPM_nooverlap] = BMP_windowed(A,colA,Peaks,Fs,window_size, 0, overlap);
                                          % Buffered structure, row count,
                                          % col cout, Peaks, Hz

[dataframe_overlap,avg_BPM_overlap] = BMP_windowed(B,colB,Peaks,Fs, window_size, 1, overlap);

% Calling the same function twice, once for non overlapping and once for
% over lapping
% Functions return the datastructure created and the average BMPs


end


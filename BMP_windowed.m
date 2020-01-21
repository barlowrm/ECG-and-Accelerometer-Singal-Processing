%% Ruairidh Barlow
% ECG and Accelerometer signal processing
% Revised: 1/21/2020

%%
function [dataframe_out,avg_BPM] = BMP_windowed(buffer_data,col,Peaks,Fs, window_size, overlap_choice,overlap_length)
% Returns datafame and avg BMP

count = 0;
a = zeros(1);
dataframe_out = zeros(1);
test_frame = zeros(1);
%preallocating space

for i = 1:1:col 
    index_col = buffer_data(:,i);
    a = ismember(index_col, Peaks);
    count = sum(a);
    temp = overall_BMP(count,window_size, Fs);
    % send count of heart beats, window size, Hz to overall bmp
    % function
    if overlap_choice == 0;
        C{i} = temp * ones(window_size,1);
        % save calculated bmp for a given window
        count = 0;
        a = zeros(1);
    else
        C{i} = temp * ones(window_size - overlap_length,1);
        % save calculated bmp for a given window
        count = 0;
        a = zeros(1);
    end
end

test_frame = cell2mat(C');
test_frame(test_frame==0) = nan;

overlap_correct = test_frame(1:end);      % corrections are necessary for overlapping windowed calculation
                                          % The overlap has to be the
                                          % average of the two values of
                                          % the two windows of that create
                                          % the overlap
if overlap_choice == 1
    for i = window_size:window_size:length(test_frame)
        if i < length(test_frame)
            avg = (test_frame(i-1) + test_frame(i+1)) / 2;
            for j = i:-1:i - overlap_length 
                overlap_correct(j) = avg;
            end
        end  
    end
    dataframe_out = overlap_correct;
    avg_BPM = mean(dataframe_out);
else
    dataframe_out = overlap_correct;
    avg_BPM = mean(dataframe_out);
end

% Get the mean BMP of the dataframe and return that
dataframe_out(285813:end) = dataframe_out(285812);
end
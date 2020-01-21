%% Ruairidh Barlow
% ECG and Accelerometer signal processing
% Revised: 1/21/2020

%%
function[finalsig] = resp_rate(window_size,overlap, signal, valid_y)

A = buffer(signal,window_size, overlap, 'nodelay');
colA = size(A,2);

count = 0;
a = zeros(1);
test_frame = zeros(1);
%preallocating space

for i = 1:1:colA
    index_col = A(:,i);
    a = ismember(index_col, valid_y);
    count = sum(a);
    C{i} = count * ones(window_size - overlap,1);
    count = 0;
    a = zeros(1);
end

test_frame = cell2mat(C');
test_frame(test_frame==0) = nan;


overlap_correct = test_frame(1:end);
for i = window_size:window_size:length(test_frame)
    if i < length(test_frame)
       avg = (test_frame(i-1) + test_frame(i+1)) / 2;
       for j = i:-1:i - overlap 
           overlap_correct(j) = avg;
       end
    end  
end
finalsig = overlap_correct(1:end);
finalsig(111196: end) = overlap_correct(111195);
end


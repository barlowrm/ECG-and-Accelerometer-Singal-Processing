function  SpectraPlot(y,Fs,color)
    %% Ploting the Spectrum From Dr. Shanshan Chen VCU
    
    % This function takes in a signal, the frequency it was captured at
    % and color for plot output
    
    % Fs  = 125; % sampling frequency
    L = length(y);
    NFFT = 2^nextpow2(L);
    % 2^16 = 65536
    % 2^17 = 131072
    % It is better to have more than less of the oringinal signal content
    % Next power of 2 from length of y
    % returns the smallest power of two that is GREATER than or equal to the
    % absolute value of L
    % useful for optimizing FFT operations 
    % This pads the signal y with trailing zeros in order to improve the
    % performance of fft. It adds more points to the specturum to increase
    % visual resolution not the actual resolution of the signal
    
    Y = fft(y,NFFT)/L;
    % Big Y for freq domain
    % fft = fast fourier transform 
    % Computes the discrete Fourier transform using the fast FT algorithm
    % (function of time -> function of frequency)
    % Parameteres: signal in time domain, transform legnth
    % This returns the n-point DFT
    % An n-point DFT means there are n number of data points
    % So NFFT = 131072 which means there are 131072 data points
    % Division by L is part of calculating the 2 sided spectrum 
    % P2 = abs(Y/L), Dr. Chen broke this part up see plot code line
    % Each point is a complex number and it contains the a and b components
    % for the frequencies CHECK THIS
    
    f = Fs/2*linspace(0,1,NFFT/2+1);
    % https://stackoverflow.com/questions/29439888/what-is-nfft-used-in-fft-function-in-matlab
    % Define the frequency domain f : https://en.wikipedia.org/wiki/Frequency_domain
    % Fs/2 hermitian symmertry: values that are above fs/2 can be obtained
    % by the complex conjjugate of the values below fs/2. Essentially this
    % is removing redundant data
    % linspace parameters: lower bound, upper bound, number of points 
    % sampling freq divided by
    % creating a vector of 65,537 evenly spaced points that have values
    % between 0 and 1 (why between 0 and 1
    % length of the Nyquist frequency component (NFFT/2+1) which helps
    % sample the signal better
    % helps when plotting the frequency spectrum
    % If you do not define the freq domain you will get the wrong cutoff
    % point for the Butterworth filter

    % Plot single-sided amplitude spectrum (P1)
    % P1 = P2(1:L/2+1)
    % P2 = abs(Y)
    figure;
    plot(f,2*abs(Y(1:NFFT/2+1)),color) ;
    % f (freq domain, P1 specturm and color)
    % Note that the freq domain the the length of the
    % Single sided ampitude spectrum are the same length
    title('Single-Sided Amplitude Spectrum of y(t)');
    xlabel('Frequency (Hz)');
    ylabel('|Y(f)|');
end
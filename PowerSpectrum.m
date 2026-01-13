function [spectra, freqs] = PowerSpectrum(data,Fs)

L = length(data);
NFFT = Fs/0.5;                              

% Remove DC offset
data = data - mean(data);
% Apply a window function (e.g., Hamming window)
data = data .* hamming(length(data))';
X = fft(data,NFFT)/L;                   % Calulate the Spectrum using FFT command
freqs = Fs/2*linspace(0,1,NFFT/2+1);    % Generate equally spaced frequency values [0 Fs/2]
spectra = abs(X(1:NFFT/2+1));           % Calculate Absolute value of Spectrum

end
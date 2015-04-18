function [featureMatrix, nWindows] = extractFeatures(dataset, fs, windowLength, windowDisplacement)
% Extracts features
% Inputs: NxM EEG dataset, where N is the number of observations and M is 
% the number of EEG channels
loadAnonFunctions
%windowLength = 0.1; %in seconds
%windowDisplacement = 0.05;
nChannels = min(size(dataset));
nWindows = NumWins(length(dataset), fs, windowLength, windowDisplacement);
nfft = 1024;
s_array = cell(nChannels, 1);
for i = 1:nChannels
    s_array{i} = spectrogram(dataset(:,i),windowLength*fs,windowDisplacement*fs,nfft,fs);
end
fBins = (0:fs/nfft:fs/2)'; %frequencies by index

avgTDVoltage = zeros(nWindows, nChannels);
avgAmp5_15 = zeros(nWindows, nChannels);
avgAmp20_25 = zeros(nWindows, nChannels);
avgAmp75_115 = zeros(nWindows, nChannels);
avgAmp125_159 = zeros(nWindows, nChannels);
avgAmp159_175 = zeros(nWindows, nChannels);

for i = 1:nChannels
    s = s_array{i};
    avgTDVoltage(:,i) = MovingWinFeats(dataset(:,i), fs, windowLength, windowDisplacement, AvgFn);
    avgAmp5_15(:,i) =  mean(abs(s(fBins > 5 & fBins < 15,:)));
    avgAmp20_25(:,i) = mean(abs(s(fBins > 20 & fBins < 25,:)));
    avgAmp75_115(:,i) = mean(abs(s(fBins > 75 & fBins < 115,:)));
    avgAmp125_159(:,i) = mean(abs(s(fBins > 125 & fBins < 159,:)));
    avgAmp159_175(:,i) = mean(abs(s(fBins > 159 & fBins < 175,:)));
end

% Assemble all features
featureMatrix = [avgTDVoltage avgAmp5_15 avgAmp20_25 avgAmp75_115...
    avgAmp125_159 avgAmp159_175];

end

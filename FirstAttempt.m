%% ANONYMOUS FUNCTIONS AND GLOBAL VARIABLES
fs = 1000; %sampling frequency

% Window Numeration Function
NumWins = @ (xLen, fs, winLen, winDisp) 1 +...
    floor(((xLen - (fs*winLen))/(fs*winDisp)));

% Feature Extraction Functions
LLFn = @ (x) sum(abs(diff(x))); %Line Length

AreaFn = @ (x) sum(abs(x)); %Area

EnergyFn = @ (x) sum(x.^2); %Energy

ZeroCrossMeanFn = @ (x) sum( (((x(1:end-1) - mean(x)) > 0) &...
    ((x(2:end) - mean(x)) < 0)) | (((x(1:end-1) - mean(x)) < 0) &...
    ((x(2:end) - mean(x)) < 0)) ); %Zero-Crossings Around Mean

AvgFn = @ (x) mean(x);
%featureValues = MovingWinFeats(x, fs, winLen, winDisp, featFn)
%% PREPROCESSING

% filtering, etc

%% SUBJECT 1

nChannels = min(size(suj1_train));
wL = 0.1; %in seconds
wD = 0.05;
nWindows = NumWins(length(suj1_train), fs, wL, wD);

nfft = 1024;
s = spectrogram(suj1_train(:,1),wL*fs,wD*fs,nfft,fs);
fBins = (0:fs/nfft:fs/2)'; %frequencies by index

avgTDVoltage = zeros(nWindows, nChannels);
avgAmp8_12 = zeros(nWindows, nChannels);
avgAmp18_24 = zeros(nWindows, nChannels);
avgAmp75_115 = zeros(nWindows, nChannels);
avgAmp125_159 = zeros(nWindows, nChannels);
avgAmp159_175 = zeros(nWindows, nChannels);

% Extract features
for i = 1:nChannels
    avgTDVoltage(:,i) = MovingWinFeats(suj1_train(:,i), fs, wL, wD, AvgFn);
    avgAmp8_12(:,i) = mean(abs(s(fBins > 8 & fBins < 12,:)));
    avgAmp18_24(:,i) = mean(abs(s(fBins > 18 & fBins < 24,:)));
    avgAmp75_115(:,i) = mean(abs(s(fBins > 75 & fBins < 115,:)));
    avgAmp125_159(:,i) = mean(abs(s(fBins > 125 & fBins < 159,:)));
    avgAmp159_175(:,i) = mean(abs(s(fBins > 159 & fBins < 175,:)));
end

% Assemble complete feature matrix
featureMatrix = [avgTDVoltage avgAmp8_12 avgAmp18_24 avgAmp75_115...
    avgAmp125_159 avgAmp159_175];
% Add bias feature, standardize
% featureMatrix = [ones(length(featureMatrix), 1) featureMatrix];
% stdMean = mean(featureMatrix(:));
% stdStd = std(featureMatrix(:));

% Downsample dataglove matrix
sep = 50; % 50 ms / 20Hz
nFingers = min(size(suj1_glove));
ds_glove = zeros(length(suj1_glove)/sep, nFingers);
for i = 1:nFingers
    ds_glove(:,i) = decimate(suj1_glove(:,i), sep);
end

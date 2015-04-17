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
% FIRING RATES?
%featureValues = MovingWinFeats(x, fs, winLen, winDisp, featFn)
%% PREPROCESSING

% filtering, etc

%% FEATURE EXTRACTION

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

% Assemble all features
featureMatrix = [avgTDVoltage avgAmp8_12 avgAmp18_24 avgAmp75_115...
    avgAmp125_159 avgAmp159_175];

% Downsample dataglove matrix
% Remove ring finger?
sep = 50; % 50 ms / 20Hz
nFingers = min(size(suj1_glove));
ds_glove = zeros(length(suj1_glove)/sep, nFingers);
for i = 1:nFingers
    ds_glove(:,i) = decimate(suj1_glove(:,i), sep);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LINEAR REGRESSION

nBins = 3; %previous time bins to consider
M_pos = length(ds_glove); %number of position time bins
M_eeg = length(featureMatrix); %number of EEG time bins
nPads = (M_pos + nBins - 1) -  M_eeg; %number of EEG bins to pad

%Randomly select EEG time bins to pad feature matrix
if nPads > 0   
    pad_indices = randi(M_eeg,[1, nPads]);
    padded_features = [featureMatrix; featureMatrix(pad_indices,:)]; 
end

% Assemble linear regression feature matrix
v = min(size(padded_features));
features_LinReg = zeros(M_pos,v*nBins);
for i = 1:M_pos
    features_LinReg(i,:) = reshape(padded_features(i:i+nBins-1,:),[1 nBins*v]);
end
% Add bias (ones) feature, scale features
[features_LinReg, sc_std, sc_mean] = ScaleFeatures(features_LinReg);


% Generate linear regression weights
weights_1 = mldivide((R'*R), (R'*ds_glove(:,1)));
weights_2 = mldivide((R'*R), (R'*ds_glove(:,2)));
weights_3 = mldivide((R'*R), (R'*ds_glove(:,3)));
weights_4 = mldivide((R'*R), (R'*ds_glove(:,4)));
weights_5 = mldivide((R'*R), (R'*ds_glove(:,5)));

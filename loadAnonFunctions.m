%% loadAnonFunctions.m
% This script loads some basic anonymous functions for features

% Window Numeration Function
NumWins = @ (xLen, fs, winLen, winDisp) 1 +...
    floor(((xLen - (fs*winLen))/(fs*winDisp)));

% Basic Feature Extraction Functions
LLFn = @ (x) sum(abs(diff(x))); %Line Length

AreaFn = @ (x) sum(abs(x)); %Area

EnergyFn = @ (x) sum(x.^2); %Energy

ZeroCrossMeanFn = @ (x) sum( (((x(1:end-1) - mean(x)) > 0) &...
    ((x(2:end) - mean(x)) < 0)) | (((x(1:end-1) - mean(x)) < 0) &...
    ((x(2:end) - mean(x)) < 0)) ); %Zero-Crossings Around Mean

AvgFn = @ (x) mean(x);

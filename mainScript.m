%% NOTES AND THINGS TO EDIT
% - Consistently getting 6199 windows instead of 6200; need to figure out
% why. Accounted for this in ds_glove and the UpSample function, but these
% are temporary solutions

loadAnonFunctions

% FIRING RATES?
%% PREPROCESSING
% filtering, etc

%% MAIN CODE
n = length(suj3_test);
fs = 1000; %sampling frequency

% Create R matrix from dataset
rawR = CreateRMatrix(suj3_test, 3);

% Add bias (ones) feature, scale features
%[R, sc_std, sc_mean] = ScaleFeatures(rawR); %Use this line for training
R = ScaleFeatures(rawR, sc_std, sc_mean); %Use this line for testing

% Downsample dataglove matrix
% Remove ring finger?
ds_glove = Downsample(suj3_glove, 50); % 50 ms / 20Hz
ds_glove = ds_glove(1:end-1,:);

% Generate weights
weights = LinearRegression(R, ds_glove);

% Make predictions
predictions_linreg_ds = R * weights;

% Interpolate predictions
predictions_linreg = zeros(n, min(size(ds_glove)));
for i = 1:5
    predictions_linreg(:,i) = Upsample(predictions_linreg_ds(:,i), 20, 1000, 310);
end

% Get prediction accuracy
accuracy = mean(diag(corr(suj3_glove, predictions_linreg)))

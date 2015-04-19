%% NOTES AND THINGS TO EDIT
% - Consistently getting 6199 windows instead of 6200; need to figure out
% why. Accounted for this in ds_glove and the UpSample function, but these
% are temporary solutions

loadAnonFunctions

% FIRING RATES?
%% PREPROCESSING
% filtering, etc
split = 210000;

trainset = suj1_train(1:split,:);
trainglove = suj1_glove(1:split,:);
testset = suj1_train(split+1:end,:);
testglove = suj1_glove(split+1:end,:);

%% MAIN CODE
fs = 1000; %sampling frequency

% Create R matrix from dataset
rawR = CreateRMatrix(trainset, 3);

% Add bias (ones) feature, scale features
[R, sc_std, sc_mean] = ScaleFeatures(rawR); %Use this line for training

% Downsample dataglove matrix
% Still need to remove 4th finger
ds_glove = Downsample(trainglove, 50); % 50 ms / 20Hz
ds_glove = ds_glove(1:end-1,:);

ds_glovetest = Downsample(testglove, 50);
ds_glovetest = ds_glovetest(1:end-1,:);

% Generate weights
weights = LinearRegression(R, ds_glove);
%Lasso Weights have to be done 1 finger at a time
%[lasso_weights, fitInfo] = lasso(R, ds_glove(:,1)); 

% Generate R matrix for test set
rawRtest = CreateRMatrix(testset, 3);
Rtest = ScaleFeatures(rawRtest, sc_std, sc_mean); %Use this line for testing

% Make predictions
ds_predictions = Rtest * weights;

%lasso_ds_predictions = zeros(length(R_test), 100);
%lasso_accuracies = zeros(100,1);
%for i = 1:length(lasso_accuracies)
%    lasso_ds_predictions(:,i) = R_test*lasso_weights(:,i) + fitInfo.Intercept(i);
%    lasso_accuracies(i) = corr(lasso_ds_predictions(:,i),ds_testglove(:,1));
%end


% Interpolate predictions
predictions = zeros(length(testset), min(size(testglove)));
for i = 1:5
    predictions(:,i) = Upsample(ds_predictions(:,i), 20, 1000, length(testglove)/fs);
end

% Get prediction accuracy
accuracy = mean(diag(corr(testglove, predictions)))
ds_accuracy = mean(diag(corr(ds_glovetest, ds_predictions)))

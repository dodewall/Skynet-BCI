function [scaled_features, sc_std, sc_mean] = ScaleFeatures(features, varargin)
%% ScaleFeatures.m
% This function adds a column of ones (bias term) and scales the features
% accordingly.

% Add bias feature
sz = size(features);
nRows = sz(1);
features = [ones(nRows, 1) features];

switch nargin  
    case 3
        sc_std = varargin{1};
        sc_mean = varargin{2};
    otherwise
        sc_std = std(features,[],1);
        sc_mean = mean(features,1);
        
end

scaled_features = (features - repmat(sc_mean, nRows, 1)) ./ ...
    repmat(sc_std, nRows, 1);
    
end

function [scaled_features, sc_std, sc_mean] = ScaleFeatures(features, varargin)
%% ScaleFeatures.m
% This function adds a column of ones (bias term) and scales the features
% accordingly.

% Add bias feature
sz = size(features);
features = [ones(sz(1), 1) features];

switch nargin  
    case 3
        sc_std = varargin{1};
        sc_mean = varargin{2};
    otherwise
        sc_std = std(features(:));
        sc_mean = mean(features(:));
        
end

scaled_features = (features - sc_mean) ./ sc_std;
    
end

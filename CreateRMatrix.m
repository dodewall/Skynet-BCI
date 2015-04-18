function R = CreateRMatrix(dataset, nBins)

[featureMatrix, nWindows] = extractFeatures(dataset, 1000, 0.1, 0.05);
% extractFeatures(dataset, windowLength, windowDisplacement)
%nBins = 3; %previous time bins to consider
M_pos = nWindows; %length(ds_glove); %number of position time bins
M_eeg = length(featureMatrix); %number of EEG time bins
nPads = (M_pos + nBins - 1) -  M_eeg; %number of EEG bins to pad

%Randomly select EEG time bins to pad feature matrix
if nPads > 0   
    pad_indices = randi(M_eeg,[1, nPads]);
    padded_features = [featureMatrix; featureMatrix(pad_indices,:)]; 
end


% Assemble linear regression feature matrix
v = min(size(padded_features));
R = zeros(M_pos,v*nBins);
for i = 1:M_pos
    R(i,:) = reshape(padded_features(i:i+nBins-1,:),[1 nBins*v]);
end

end

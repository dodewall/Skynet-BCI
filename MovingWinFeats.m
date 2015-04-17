function featureValues = MovingWinFeats(x, fs, winLen, winDisp, featFn)
%Get signal length
xLen = length(x);

%Get window and displacement in number of samples
L_D = fs*winDisp;
L_W = fs*winLen;

%Calculate number of windows in signal
nWindows = 1 + floor((xLen - L_W)/L_D); %remove 1 for stuff;
featureValues = zeros(nWindows, 1);

for i = 1:nWindows
    sVal = L_D*(i - 1) + 1;
    eVal = sVal + L_D - 1;%L_D*i + (L_W - L_D);
    
    signalSegment = x(sVal:eVal);
    featureValues(i) = featFn(signalSegment);
end


end

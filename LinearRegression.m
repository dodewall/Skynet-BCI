function weights = LinearRegression(R, s)
% Generate linear regression weights
% 
weights = zeros(min(size(R)), min(size(s)));
for i = 1:min(size(s))
    weights(:,i) = mldivide((R'*R), (R'*s(:,i)));
end

end

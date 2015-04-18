function ds_values = Downsample(raw_values, sep)

nFingers = min(size(raw_values));

ds_values = zeros(length(raw_values)/sep, nFingers);

for i = 1:nFingers
    ds_values(:,i) = decimate(raw_values(:,i), sep);
end

end

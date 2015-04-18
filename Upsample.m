function splined = Upsample(raw, fs_down, fs_up, time)

down_time = (0 : 1/fs_down : time-(2/fs_down))';
up_time = (0 : 1/fs_up : time-(1/fs_up))';

splined = spline(down_time, raw, up_time);


end

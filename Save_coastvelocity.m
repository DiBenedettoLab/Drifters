%
%% Adding coastal velocity to the structures of data

dataset='buoy'; %spot or buoy
location='all'; %ocean to consider
[ds,dt]=load_drift_data(dataset,location);


timezero=min(dt.time);

for i=1:length(ds)
    [coastvel]=calc_coastal_velocity(ds(i).coast,ds(i).time);
    ds(i).coast_velocity=coastvel;
    ds(i).days_norm=(ds(i).time-timezero)/86400;
end

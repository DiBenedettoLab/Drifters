%Investigating the direction of the drifters to and from the coast
%% Direction of Drifters, Schreder, 9.9.22 (D-Day+1)
dataset='spot'; %spot or buoy
location='all'; %ocean to consider
[ds,dt,oceanname]=load_drift_data(dataset,location);
load('Data/coast_latlon.mat');


%% Histogram
[coastvel,hours]=calc_coastal_velocity(dt.coast,dt.time);

pos=coastvel>=0;
neg=~pos;

figure(1);clf;hold on
binwid=15;
histogram(dt.coast(pos),'FaceColor','r','BinWidth',binwid)
histogram(dt.coast(neg),'FaceColor','b','BinWidth',binwid)

xlabel('Distance from coast (km)')
ylabel('pings')
legend('+','-')
title([oceanname ' ' dataset])


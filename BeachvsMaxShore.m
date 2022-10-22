%Using the maximum distance from the shore as a way to measure how likely a
%drifter is to beach. 
%% Probability to beach vs. max shore distance, Schreder, 9.9.22

%Loads data
% load('Data/coast_latlon.mat');
dataset='buoy'; %spot or buoy
location='all'; %ocean to consider
[ds,dt,oceanname]=load_drift_data(dataset,location);
bcrit=10; %km

%where it is within bcrit
bdt_log=dt.coast<=bcrit; %logical of beachers in beach zone
bdt_indx=find(bdt_log==1); %indices of beachers in beach zone

%ID's where it is within bcrit
bcrit_ID=unique(dt.id(bdt_log));

%% 
%finding max distance and whether the drifter beaches
maxcoast_dist=zeros(length(ds),1);maxcoast_beach=maxcoast_dist;
for i=1:length(ds)
    maxcoast_dist(i)=max(ds(i).coast);
    maxcoast_beach(i)=sum(bcrit_ID==ds(i).id);
end
maxcoast_beach=logical(maxcoast_beach);

bins=0:100:4400;

percbeach=zeros(numel(bins)-1,1);center=percbeach;numinbin=center;beachinbin=center;
for i=1:length(bins)-1
    inbin_all=(maxcoast_dist>=bins(i) & maxcoast_dist<=bins(i+1));
    inbin_beach=(maxcoast_beach+inbin_all==2);
    percbeach(i)=sum(inbin_beach)/sum(inbin_all);
    center(i)=(bins(i)+bins(i+1))/2;
    numinbin(i)=sum(inbin_all);
    beachinbin(i)=sum(inbin_beach);
end

figure(6);clf;hold on
plot(center,beachinbin,'.-')
xlim([bins(1),bins(end)])
% ylim([0,100])
ax=gca;
ax.XTick=bins;
ax.XTickLabel=bins;
ax.XGrid='on';
ax.YGrid='on';
xlabel('Max distance from coast (km)');
ylabel('percent of beached drifters')
title([dataset ' ' oceanname])

yyaxis right
plot(center,numinbin,'.-')
ylabel('number of drifters')
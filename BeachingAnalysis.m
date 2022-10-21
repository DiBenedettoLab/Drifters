% Script to analze drifter data. taking a pause on python
%% DrifterAnalysis, Schreder, 8/3/22
%% Load data (buoy)
%new data
buoy_table=readtable('buoydata_cleaned.csv');
buoy_data=table2array(buoy_table(:,1:4));
step=100;lonlims=[-180,180];


%old data
% buoy_table=readtable('buoydata_10001_15000_UNDROGUED.csv');
% buoy_data=table2array(buoy_table(:,1:4));
% bleh_data=(buoy_data(:,3)==999.999);
% buoy_table(bleh_data,:)=[];
% buoy_data=table2array(buoy_table(:,1:4));
% step=10;lonlims=[0,360];


% names=datatable.Properties.VariableNames;


%only things needed 
time=buoy_data(:,2);
lat=buoy_data(:,3);
lon=buoy_data(:,4);
id=buoy_data(:,1);

BUOY.time=time;
BUOY.lat=lat;
BUOY.lon=lon;
BUOY.id=id;
save('buoydata.mat',"BUOY")


%% load data (spotter)
spottabcl=readtable('Raw Data/spotter_cleaned.csv');
spotter_data=table2array(spottabcl(:,[2,3,4,6]));
time=spotter_data(:,4);
lat=spotter_data(:,2);
lon=spotter_data(:,3);
SPOT.time=time;
SPOT.lat=lat;
SPOT.lon=lon;
SPOT.id=id;
%save('spotdata.mat',"SPOT")

step=100;
%id=buoy_data(:,1);
for i=1:length(spottabcl.ID)-1
    spoot(i,:)=str2num(spottabcl.ID{i}(6:end));
end

%% something is off about the cleaned data
spotab=readtable("Raw Data/all_time_spotter_tracks.csv");
spotab21=readtable("Raw Data/spotter_2021.csv");
spotab22=readtable("Raw Data/spotter_2022.csv");
spottabcl=readtable('Raw Data/spotter_cleaned.csv');

%% plotting some things
%individual times sorted
timesteps=unique(time);
timesteps=sort(timesteps);

first=true;

figure(101);clf
for i=1:step:numel(timesteps)

    if first
        thistime=(timesteps(i)==time);
        lasttime=thistime;
        first=false;

    else
        lasttime=thistime;
        thistime=(timesteps(i)==time);
        delete(h)
    end

    % figure(101);clf
    geoplot(lat(lasttime),lon(lasttime),'.','Color','#CEECDA','MarkerSize',0.5);hold on
    h=geoplot(lat(thistime),lon(thistime),'.m');

    %formatting
    geolimits([1.1*min(lat),1.1*max(lat)],lonlims)
    indextimes=find(timesteps(i)==time);
    title({datestr(buoy_table.timestamp(indextimes(1)),'HH:MM dd-mm-yyyy'),...
        ['Frame: ' num2str(i) '/' num2str(numel(timesteps))]})
    pause(0.0001)
end

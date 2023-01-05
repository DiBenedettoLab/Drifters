%Goal of this plot: 
%map of the world where I do a colormap that shows how long it will take
%the drifter to beach. The grid map will only show beached drifters
%% Time to beach again

%%% --- LOAD DATA --- %%%
%dataset
dataset='both'; %spot or buoy
location='all'; %ocean to consider

%load data
load('coast_latlon.mat');
[ds,dt,oceanname]=load_drift_data(dataset,location);

%% make grid
[fig]=make_grid_fig('degree',dt,4,[coast_lat',coast_lon']);

%%

beach_log=[ds.beached_loc];
beach_indx=find(beach_log==1);

clear lats lons days
lats=[];lons=[];days=[];

for n=1:numel(beach_indx)
    i=beach_indx(n);
    day=ds(i).days_norm(end)-ds(i).days_norm;
    lons=[lons;ds(i).lon];
    lats=[lats;ds(i).lat];
    days=[days;day];


end

colormap=parula;
colorvec=linspace(0,max(days),257);
for i=1:256
    inbin=(days>=colorvec(i) & days<colorvec(i+1));
    plot(lons(inbin),lats(inbin),'o','markersize',1,'color',colormap(i,:))
    
end

colorbar
caxis([0,max(days)]);

%%
[fig]=make_grid_fig('degree',dt,4,[coast_lat',coast_lon']);
bcrit=100;

clear lats lons days
lats=[];lons=[];days=[];

for i=1:length(ds)
    if ds(i).coast(end)<=bcrit
    day=ds(i).days_norm(end)-ds(i).days_norm;
    lons=[lons;ds(i).lon];
    lats=[lats;ds(i).lat];
    days=[days;day];
    end
end

colormap=parula;
colorvec=linspace(0,max(days),257);
for i=1:256
    inbin=(days>=colorvec(i) & days<colorvec(i+1));
    plot(lons(inbin),lats(inbin),'o','markersize',1,'color',colormap(i,:))
    
end


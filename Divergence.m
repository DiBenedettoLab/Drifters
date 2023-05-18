%we want to find the divergence of the drfiter data so that we can separate the
%beached drifters into separate beaching bins
%% Divergence

[ds,dt,oceanname]=load_drift_data('spot','all');
load('coast_latlon.mat');

%% proof of concept
%calculate divergence
%uses super simple diff method, make this better later

n=1;

for i=1:length(ds)
    if ds(i).beached_loc

        %save ID (for good measure)
        beachdiv(n).id=ds(i).id;

        %divergence
        u=ds(i).speed.*sind(ds(i).direction);
        v=ds(i).speed.*cosd(ds(i).direction);
        lat=ds(i).lat;
        lon=ds(i).lon;

        %calc and save divergence
        beachdiv(n).div=(diff(u)./diff(lat)+diff(v)./diff(lon))';

        %save location data
        beachdiv(n).lat=(lat(1:end-1)+lat(2:end))'/2;
        beachdiv(n).lon=(lon(1:end-1)+lon(2:end))'/2;

        n=n+1;
    end
end

divs=[beachdiv.div];
lats=[beachdiv.lat];
lons=[beachdiv.lon];
%% Plot results

[fig]=make_grid_fig('degree',dt,4,[coast_lat',coast_lon']);

colormap=parula;
colorvec=linspace(0,max(days),257);
for i=1:256
    inbin=(divs>=colorvec(i) & divs<colorvec(i+1));
    plot(lons(inbin),lats(inbin),'.','markersize',10,'color',colormap(i,:))
end

colorbar
caxis([0,max(divs)]);



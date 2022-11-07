% discretizes the ocean into dx^2 cells and plots with a color map:
% 1. the probabiity of drifters beaching,
% 2. the number of beached drifters,
% 3. the number of pings
% 4. the number of drifters
%% Transition Matrix v2, Schreder 9/1/22
%dataset
dataset='both'; %spot or buoy
location='all'; %ocean to consider

%load data
load('Data/coast_latlon.mat');
[ds,dt,oceanname]=load_drift_data(dataset,location);

%% Grid
%steps
dx=2; %cell size in degrees %should be 0.5-1
bcrit=10; %beaching distance. should be in km for spot and m for buoy
coastdirmat=false;

%grid of globe; each cell is square and encloses all data
latbounds=[floor(min(dt.lat)/dx)*dx,ceil(max(dt.lat)/dx)*dx];
lonbounds=[floor(min(dt.lon)/dx)*dx,ceil(max(dt.lon)/dx)*dx];

%grid for center of the section
[xpt,ypt]=meshgrid(lonbounds(1)+dx/2:dx:lonbounds(2)-dx/2,latbounds(1)+dx/2:dx:latbounds(2)-dx/2);

%grid for square enclosing each section
latg=latbounds(1):dx:latbounds(2);
long=lonbounds(1):dx:lonbounds(2);

%create figure
fig=figure(1);clf;hold on
fig.Color='w';
daspect([1 1 1])

%plots initial points
%plot(xpt,ypt,'.m','LineWidth',3)
[xg,yg]=meshgrid(long,latg);
% mesh(xg,yg,zeros(size(xg)),'EdgeColor','#CDD6DE','facecolor','none','LineWidth',0.1)
view([0,0,1])
xlim(lonbounds);ylim(latbounds)
xlabel('longitude');ylabel('latitude')

%plotting land points for refrence
coastloncheck=coast_lon>=lonbounds(1) & coast_lon<=lonbounds(2);
coastlatcheck=coast_lat>=latbounds(1) & coast_lat<=latbounds(2);
coast2use=(coastloncheck+coastlatcheck==2);
coast_y=coast_lat(coast2use);
coast_x=coast_lon(coast2use);
hmap=plot3(coast_x,coast_y,1.1*ones(size(coast_x)),'.','MarkerSize',0.5,'Color','m'); %plot3 so these points end up above the surf plot

%plots all spotter points
% plot(dt.lon,dt.lat,'.','MarkerSize',0.2,'Color','m')

%% Assigning points to cells in the grid
%NOTE: if a point is exactly on the grid, somethings gonna break
n=1;
gridloc_mat=zeros(size(xg));
beached_mat=zeros(size(xg));
direction_mat=zeros(size(xg));
dataexists=logical(zeros(size(xg)));
gridids_mat=zeros(size(xg));

for i=1:length(ds)
    beaches=(ds(i).coast(end)<=bcrit); %ends up in beached zone
    
    %finding whether is it moving towards or from coast
    if coastdirmat
        coastvel=calc_coastal_velocity(ds(i).coast,ds(i).time);
        coastdir=coastvel./abs(coastvel);
    end

    %to track the unique ID's in each cell
    gridloc_mat_temp=zeros(size(xg));

    for j=1:length(ds(i).lat)

        %latitude and longitude points
        latpt=ds(i).lat(j); %first latitude point for one spotter
        lonpt=ds(i).lon(j); %first longitude point for one spotter
    
        %finding where point lies
        row=find(latpt>yg(:,1),1,'last'); %row where the lat lies
        col=find(lonpt>xg(row,:),1,'last'); %correct row 
    
        %storing information
        gridloc_mat(row,col)=gridloc_mat(row,col)+1;
        beached_mat(row,col)=beached_mat(row,col)+(ds(i).coast(end)<=bcrit);
        gridloc_mat_temp(row,col)=gridloc_mat(row,col)+1;
        n=n+1;

        %coastal direction 
        if coastdirmat
            dataexists(row,col)=true;
            direction_mat(row,col)=direction_mat(row,col)+coastdir(j);
        end
    end
    %counts how many unique ID's are in a cell
    gridids_mat=gridids_mat+(gridloc_mat_temp>0);

end %i=1:length(ds)

%removing points without data
if coastdirmat
    direction_mat(~dataexists)=NaN;
end

%transition matrix
minimumdrifters=5; %the minum amount of drifters for data in trans mat to be considered
trans_mat=beached_mat./gridloc_mat;

%removing points where there aren't enough drifters
if minimumdrifters>0
    notenoughdata_log=gridids_mat<minimumdrifters;
    trans_mat(notenoughdata_log)=NaN;
    mindriftext=['(where there are at least ' num2str(minimumdrifters) ' unique drifters)'];
else
    mindriftext='(no minimum drifter in cell requirement)';
end

%% plotting transition matrix on map

data2plot='pings'; %'trans' or 'beach'
if exist('pax')
    delete(pax)
end

switch data2plot
    case 'trans' 
        plotting_mat=trans_mat;
        plotting_name=['N_{beached spotters}/N_{in cell} ' mindriftext];
        ax=gca; %makes NaN values grey
        set(ax,'Color',[0.8,0.8,0.8])
        load('Online Funcs/tealcolormap.mat')
        colormap(flip(tealcolormap));
    case 'beach'
        plotting_mat=beached_mat;
        plotting_name='N_{beached spotters}';
        load('Online Funcs/tealcolormap.mat')
        colormap(tealcolormap);
    case 'pings'
        plotting_mat=gridloc_mat;
        plotting_name='N_{pings in cell}';
        load('Online Funcs/tealcolormap.mat')
        colormap(tealcolormap);
    case 'drift'
        plotting_mat=gridids_mat;
        plotting_name='N_{drifters in cell}';
        load('Online Funcs/tealcolormap.mat')
        colormap(tealcolormap);
    case 'direc'
        if coastdirmat
            plotting_mat=direction_mat;
            plotting_name='Moving to or away from coast';
            ax=gca; %makes NaN values grey
            set(ax,'Color',[0.8,0.8,0.8])
            colormap('cool')
        else
            error('Coastal direction not collected, must rerun.')
        end
    otherwise
        if coastdirmat
            error("Enter 'trans', 'beach', 'pings', 'drift', or 'direc'")
        else
            error("Enter 'trans', 'beach', 'pings', or 'drift'")
        end
end

pax=pcolor(xg(1,:)+dx/2,yg(:,1)+dx/2,plotting_mat);%,'EdgeColor','none')%,'FaceAlpha',1)
% pax.FaceColor='interp';
pax.EdgeColor='none';
colorbar;caxis([min(plotting_mat(:)),max(plotting_mat(:))])
title({[dataset ' data in ' oceanname];['Beaching Distance of ' num2str(bcrit) ' km'];plotting_name})


%% Plotting locations of beached drifters

n=1;
figure(1);hold on
box on

for i=1:length(ds)
    if ds(i).coast(end)<=bcrit
        lats(n)=ds(i).lat(end);
        lons(n)=ds(i).lon(end);
        n=n+1;
    end
end


IDspot=[305	348	611	621	637	642	645	650	651	670	1279	1299	1301	1504	1505	1966	1970	10025	10050	10122	10216];
IDbuoy=[17365	18772	18874	23186	36978	41607	62587	98881	101950	107659	109513	122582	122732	132697	145707	145961	147140	9820090	9917894	9918812];
idc=[IDspot,IDbuoy];

n=1;
for i=1:length(ds)
    if sum(ds(i).id==idc)
        lats1(n)=ds(i).lat(end);
        lons1(n)=ds(i).lon(end);
        n=n+1;
    end
end

hmap.Color='b';
hbeach=plot3(lons,lats,3*ones(size(lats)),'m*','LineWidth',1,'MarkerSize',4);
hbeach1=plot3(lons1,lats1,3*ones(size(lats1)),'yo','LineWidth',1,'MarkerSize',4,'LineWidth',2);

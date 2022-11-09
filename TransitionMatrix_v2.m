% discretizes the ocean into dx^2 cells and plots with a color map:
% 1. the probabiity of drifters beaching,
% 2. the number of beached drifters,
% 3. the number of pings
% 4. the number of drifters
%create a grid that is nxnº or has the same surface area by changing
%grid_type to 'degree' or 'area'
%% Transition Matrix v2, Schreder 9/1/22

%%% --- LOAD DATA --- %%%
%dataset
dataset='spot'; %spot or buoy
location='all'; %ocean to consider

%load data
load('coast_latlon.mat');
[ds,dt,oceanname]=load_drift_data(dataset,location);

%% ------------------------- SPECIFICATIONS ------------------------ %%
bcrit=10; %beaching distance. should be in km for spot and m for buoy
makecoastdirmat=false;
makevelmat=true;
grid_type='area'; %'degree' or 'area'

%% ------------------------- CREATE GRID ------------------------ %%
% OPTIONS: 
% 1. degree: square cells with side length in degrees
% 2. area: cells with equal area

switch grid_type
    case 'degree'

        %STEPS
        dx=2;
        
        %BOUNDARIES
        latbounds=[floor(min(dt.lat)/dx)*dx,ceil(max(dt.lat)/dx)*dx];
        lonbounds=[floor(min(dt.lon)/dx)*dx,ceil(max(dt.lon)/dx)*dx];
        
        %CENTER POINTS
        [xpt,ypt]=meshgrid(lonbounds(1)+dx/2:dx:lonbounds(2)-dx/2,latbounds(1)+dx/2:dx:latbounds(2)-dx/2);
        
        %GRID EDGES
        latg=latbounds(1):dx:latbounds(2);
        long=lonbounds(1):dx:lonbounds(2);

    case 'area'

        %# OF CELLS
        c=50; %amount of lateral grids, must be even, will be *2 for longitudinal
        
        % LATITUDE: spacing changes
        r=zeros(c+1,1);
        r(1)=90;
        R=90*sqrt(2/(c/2+1));
        r(2:c/2)=90-R.*sqrt((2:(c/2))/2);
        r(c/2+2:c+1)=-flipud(r(1:c/2));
        latg=flipud(r);
        
        %LONGITUDE
        long=linspace(-180,180,(c)*2+1);
        
        %BOUNDARIES for plotting
        lonbounds=[-180,180];
        latbounds=[-90,90];

        %CENTER POINTS
        xcenter=diff(long)/2+long(1:end-1);
        ycenter=diff(latg)/2+latg(1:end-1);
        [xpt,ypt]=meshgrid(xcenter,ycenter);
end

%GRID
[xg,yg]=meshgrid(long,latg);


%%% --- CREATE FIGURE --- %%%
% PLOT SPECS
fig=figure(1);clf;hold on
fig.Color='w';
daspect([1 1 1])
view([0,0,1]);box on
xlim(lonbounds);ylim(latbounds)
xlabel('longitude');ylabel('latitude')

% PLOTS GRID
% plot(xpt,ypt,'.b','LineWidth',3)
% mesh(xg,yg,zeros(size(xg)),'EdgeColor','#CDD6DE','facecolor','none','LineWidth',0.1)

%plotting land points for refrence
coastloncheck=coast_lon>=lonbounds(1) & coast_lon<=lonbounds(2);
coastlatcheck=coast_lat>=latbounds(1) & coast_lat<=latbounds(2);
coast2use=(coastloncheck+coastlatcheck==2);
coast_y=coast_lat(coast2use);
coast_x=coast_lon(coast2use);
hmap=plot3(coast_x,coast_y,1.1*ones(size(coast_x)),'.','MarkerSize',0.5,'Color','m'); %plot3 so these points end up above the surf plot

%% ------------------------- GET GRIDDED DATA ------------------------ %%

%%% --- INITIALIZE MATS --- %%%
mPing=zeros(size(xg));
mBeach=zeros(size(xg));
mInBeach=zeros(size(xg));
mCoastDir=zeros(size(xg));
mUniqueID=zeros(size(xg));
mLonVelAll=zeros(size(xg));
mLatVelAll=zeros(size(xg));

%%% --- COLLECT DATA --- %%%
for i=1:length(ds)

    %COASTAL DIRECTION
    if makecoastdirmat
        coastvel=calc_coastal_velocity(ds(i).coast,ds(i).time);
        coastdir=coastvel./abs(coastvel);
    end

    %to track unique IDs
    ping_mat_temp=zeros(size(xg));

    for j=1:length(ds(i).lat)

        %POINTS
        latpt=ds(i).lat(j); 
        lonpt=ds(i).lon(j); 
    
        %PLACING IN GRID
        row=find(latpt>yg(:,1),1,'last'); 
        col=find(lonpt>xg(row,:),1,'last'); 
    
        %STORE DATA
        mPing(row,col)=mPing(row,col)+1;
        mBeach(row,col)=mBeach(row,col)+(ds(i).coast(end)<=bcrit);
        mInBeach(row,col)=mInBeach(row,col)+(sum([ds(i).coast]<=bcrit)>0);
        ping_mat_temp(row,col)=mPing(row,col)+1;

        %COASTAL DIRECTION
        if makecoastdirmat
            mCoastDir(row,col)=mCoastDir(row,col)+coastdir(j);
        end

        %VELOCITY
        if makevelmat
            mLonVelAll(row,col)=mLonVelAll(row,col)+ds(i).speed(j)*cosd(90-ds(i).direction(j));
            mLatVelAll(row,col)=mLatVelAll(row,col)+ds(i).speed(j)*sind(90-ds(i).direction(j));
        end

    end

    %UNIQUE IDS
    mUniqueID=mUniqueID+(ping_mat_temp>0);

end %i=1:length(ds)

%removing points without data
if makecoastdirmat
    mCoastDir(mUniqueID==0)=NaN;
end

%% ------------------ CALCULATE PROBABILITY MATRICES ----------------- %%

%amount of drifters needed in each cell
minimumdrifters=0; 

%PROBABILITY MATRIX
mProb=mBeach./mPing;
mProbIn=mInBeach./mPing;

%MEAN VELOCITY
if makevelmat
    mLonVel=mLonVelAll./mPing;
    mLatVel=mLatVelAll./mPing;
    mLatVel(mUniqueID==0)=NaN;
    mLonVel(mUniqueID==0)=NaN;
    mMagVel=sqrt(mLonVel.^2+mLatVel.^2);
end

%REMOVE DATA
if minimumdrifters>0
    DataMin=mUniqueID<minimumdrifters;
    mindriftext=['(where there are at least ' num2str(minimumdrifters) ' unique drifters)'];
    mProb(DataMin)=NaN;

    if makevelmat
        mProbIn(DataMin)=NaN;
        mMagVel(DataMin)=NaN;
        mLonVel(DataMin)=NaN;
        mLatVel(DataMin)=NaN;
    end
else
    mindriftext='(no minimum drifter in cell requirement)';
end

%% ----------------------------- PLOTTING ----------------------------- %%
%Can plot:
% 1. probbeach: probability will end beached
% 2. probinbeach: probability it will ever enter coastal zone
% 3. beach: all beached points
% 4. pings: all pings
% 5. drift: # drifters in each cell
% 6. coastdirec: moving to or away from coast (note: makecoastdirmat=true)
% 7. quiver: velocity plots (note: must set makevelmat=true)

data2plot='quiver'; 

%deletes elements if rerun
if exist('pax')
    delete(pax)
end
if exist('quiv')
    delete(quiv)
end

switch data2plot
    case 'probbeach' 
        plotting_mat=mProb;
        plotting_name=['N_{beached spotters}/N_{in cell} ' mindriftext];
        ax=gca; %makes NaN values grey
        set(ax,'Color',[0.8,0.8,0.8])
        load('tealcolormap.mat')
        colormap((tealcolormap));
    case 'probinbeach' 
        plotting_mat=mProbIn;
        plotting_name=['N_{spotters enter coastal zone}/N_{in cell} ' mindriftext];
        ax=gca; %makes NaN values grey
        set(ax,'Color',[0.8,0.8,0.8])
        load('tealcolormap.mat')
        colormap((tealcolormap));
    case 'beach'
        plotting_mat=mBeach;
        plotting_name='N_{beached spotters}';
        load('tealcolormap.mat')
        colormap(tealcolormap);
    case 'pings'
        plotting_mat=mPing;
        plotting_name='N_{pings in cell}';
        load('tealcolormap.mat')
        colormap(tealcolormap);
    case 'drift'
        plotting_mat=mUniqueID;
        plotting_name='N_{drifters in cell}';
        load('tealcolormap.mat')
        colormap(tealcolormap);
    case 'coastdirec'
        if makecoastdirmat
            plotting_mat=mCoastDir;
            plotting_name='Moving to or away from coast';
            ax=gca; %makes NaN values grey
            set(ax,'Color',[0.8,0.8,0.8])
            colormap('cool')
        else
            error('Coastal direction not collected, must rerun.')
        end
    case 'quiver'
        if makevelmat
            plotting_mat=mMagVel;
            ax=gca; %makes NaN values grey
            set(ax,'Color',[0.8,0.8,0.8])
            plotting_name='Velocity';
            quiv=quiver(xpt,ypt,mLonVel(1:end-1,1:end-1),mLatVel(1:end-1,1:end-1),'color','k','AutoScaleFactor',3);
            load('tealcolormap.mat')
            colormap((tealcolormap));
        else
            error('Velocity matrix not collected, please rerun with makevelmat=0')
        end
    otherwise
        if makecoastdirmat
            error("Enter 'trans', 'beach', 'pings', 'drift', or 'direc'")
        else
            error("Enter 'trans', 'beach', 'pings', or 'drift'")
        end
end

pax=pcolor(xg(1,:),yg(:,1),plotting_mat);%,'EdgeColor','none')%,'FaceAlpha',1)
% pax=pcolor(xg(1,:)+dx/2,yg(:,1)+dx/2,plotting_mat);%,'EdgeColor','none')%,'FaceAlpha',1)
% pax.FaceColor='interp';
pax.EdgeColor='none';
colorbar;caxis([min(plotting_mat(:)),max(plotting_mat(:))])
title({[dataset ' data in ' oceanname];['Beaching Distance of ' num2str(bcrit) ' km'];plotting_name})


%% Comparing spotter and buoy velocities
% mLatVelB=mLatVel;
% mLonVelB=mLonVel;
% mMagVelB=mMagVel;
% mPingB=mPing;

% mLatVelS=mLatVel;
% mLonVelS=mLonVel;
% mMagVelS=mMagVel;
% mPingS=mPing;

hvals=zeros(size(mPingS));

for i=1%:numel(mPingS)
    

    ttest2(ones(1,mPingB)*mMagVelB,ones(1,mPingS)*mMagVelS)
end





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

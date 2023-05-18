%divergence
%really should vectorize this code. Like put everything into one big table
%and then bin it
%% Transition Matrix v2, Schreder 9/1/22

%load data
load('coast_latlon.mat');
[ds,dt,oceanname]=load_drift_data('GDP');

%% SPECIFICATIONS ------------------------------------------------------ %%
makevelmat=true;

%% REATE GRID ---------------------------------------------------------- %%
% OPTIONS: 
% 1. degree: square cells with side length in degrees
% 2. area: cells with equal area

[fig,xg,yg,xpt,ypt,hmap]=make_grid_fig('area',1,[coast_lat',coast_lon']);

%% GET GRIDDED DATA ---------------------------------------------------- %%

%%% --- INITIALIZE MATS --- %%%
mPing=zeros(size(xg));
mBeach=zeros(size(xg));
mInBeach=zeros(size(xg));
mCoastDir=zeros(size(xg));
mUniqueID=zeros(size(xg));
mLonVelAll=zeros(size(xg));
mLatVelAll=zeros(size(xg));
cLonVel=cell(size(xg));
cLatVel=cell(size(xg));
cCoastDirLon=cell(size(xg));
cCoastDirLat=cell(size(xg));
mTime=zeros(size(xg));
mTimePing=zeros(size(xg));
mTimeUniqueID=zeros(size(xg));


%%% --- COLLECT DATA --- %%%
for i=1:length(ds)

    %to track unique IDs
    ping_mat_temp=zeros(size(xg));
    time_ping_mat_temp=zeros(size(xg));


    for j=1:length(ds(i).lat)

        %POINTS
        latpt=ds(i).lat(j); 
        lonpt=ds(i).lon(j); 
    
        %PLACING IN GRID
        row=find(latpt>=yg(:,1),1,'last'); 
        col=find(lonpt>=xg(row,:),1,'last'); 
    
        %STORE DATA
        mPing(row,col)=mPing(row,col)+1;
        ping_mat_temp(row,col)=ping_mat_temp(row,col)+1;

        %VELOCITY
        %first data set
%         if makevelmat
%             mLonVelAll(row,col)=mLonVelAll(row,col)+ds(i).speed(j)*cosd(90-ds(i).direction(j));
%             mLatVelAll(row,col)=mLatVelAll(row,col)+ds(i).speed(j)*sind(90-ds(i).direction(j));
%             cLonVel{row,col}=[cLonVel{row,col},{ds(i).speed(j)*sind(90-ds(i).direction(j))}];
%             cLatVel{row,col}=[cLatVel{row,col},{ds(i).speed(j)*sind(90-ds(i).direction(j))}];
%         end

        %GDP Data
        if makevelmat
            mLonVelAll(row,col)=mLonVelAll(row,col)+ds(i).ve(j);
            mLatVelAll(row,col)=mLatVelAll(row,col)+ds(i).vn(j);
            cLonVel{row,col}=[cLonVel{row,col},{ds(i).ve(j)}];
            cLatVel{row,col}=[cLatVel{row,col},{ds(i).vn(j)}];
        end

    end

    %UNIQUE IDS
    mUniqueID=mUniqueID+(ping_mat_temp>0);
    mTimeUniqueID=mTimeUniqueID+(time_ping_mat_temp>0);

end %i=1:length(ds)

%removing points without data
if makecoastdirmat
    mCoastDir(mUniqueID==0)=NaN;
end

%% CALCULATE PROBABILITY MATRICES -------------------------------------- %%

%amount of drifters needed in each cell
minimumdrifters=0; 

%PROBABILITY MATRIX
mProb=mBeach./mPing;
mProbIn=mInBeach./mPing;

%REMOVE DATA
if minimumdrifters>0
    DataMin=mUniqueID<minimumdrifters;
    mindriftext=['(where there are at least ' num2str(minimumdrifters) ' unique drifters)'];
    mProb(DataMin)=NaN;

    %velocity
    mProbIn(DataMin)=NaN;
    mMagVel(DataMin)=NaN;
    mLonVel(DataMin)=NaN;
    mLatVel(DataMin)=NaN;

else
    mindriftext='(no minimum drifter in cell requirement)';
end

%MEAN VELOCITY
mLonVel=mLonVelAll./mPing;
mLatVel=mLatVelAll./mPing;
mLatVel(mUniqueID==0)=NaN;
mLonVel(mUniqueID==0)=NaN;
mMagVel=sqrt(mLonVel.^2+mLatVel.^2);


%% PLOTTING ------------------------------------------------------------ %%
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
    case 'quiver2'
        if makedirfinalmat
            plotting_mat=mProb;
            ax=gca; %makes NaN values grey
            set(ax,'Color',[0.8,0.8,0.8])
            plotting_name='Velocity';
            
            quiv=quiver(xpt,ypt,mCoastDirLonNorm(1:end-1,1:end-1),mCoastDirLatNorm(1:end-1,1:end-1),'color','k','AutoScale',2);
            load('tealcolormap.mat')
            colormap((tealcolormap));
        else
            error('coast final direction matrix not collected, please rerun with makedirfinalmat=0')
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
c=colorbar;caxis([min(plotting_mat(:)),max(plotting_mat(:))])
title({[dataset ' data in ' oceanname];['Beaching Distance of ' num2str(bcrit) ' km'];plotting_name})


%% Comparing spotter and buoy velocities

% load('Velocity_cells.mat')

% mLatVelB=mLatVel;
% mLonVelB=mLonVel;
% mMagVelB=mMagVel;
% mPingB=mPing;
% cLonVelB=cLonVel;
% cLatVelB=cLatVel;

% mLatVelS=mLatVel;
% mLonVelS=mLonVel;
% mMagVelS=mMagVel;
% mPingS=mPing;
% cLonVelS=cLonVel;
% cLatVelS=cLatVel;

hvalsLat=zeros(size(cLatVelB));
pvalsLat=zeros(size(cLatVelB));
hvalsLon=zeros(size(cLatVelB));
pvalsLon=zeros(size(cLatVelB));
hvalsMag=zeros(size(cLatVelB));
pvalsMag=zeros(size(cLatVelB));


aval=.05;

for i=1:size(cLatVelB,1)
    for j=1:size(cLatVelB,2)
%     [hvals(i),pvals(i)]=ttest2(ones(1,mPingB(i))*mMagVelB(i),ones(1,mPingS(i))*mMagVelS(i),'alpha',0.8);
        if isempty(cLatVelB{i,j}) || isempty(cLatVelS{i,j})
            hvalsLat(i,j)=NaN;
            hvalsLon(i,j)=NaN;
            pvalsLat(i,j)=NaN;
            pvalsLon(i,j)=NaN;
        else
            [hvalsLat(i,j),pvalsLat(i,j)]=ttest2(cell2mat(cLatVelB{i,j}),cell2mat(cLatVelS{i,j}),'alpha',aval);
            [hvalsLon(i,j),pvalsLon(i,j)]=ttest2(cell2mat(cLonVelB{i,j}),cell2mat(cLonVelS{i,j}),'alpha',aval);
            [hvalsMag(i,j),pvalsMag(i,j)]=ttest2(...
                sqrt(cell2mat(cLonVelB{i,j}).^2+cell2mat(cLatVelB{i,j}).^2),...
                sqrt(cell2mat(cLonVelS{i,j}).^2+cell2mat(cLatVelS{i,j}).^2),...
                'alpha',aval);
        end
    end
end

rejectnull_lat=sum(hvalsLat(:)==1)
acceptnull_lat=sum(hvalsLat(:)==0)

rejectnull_lon=sum(hvalsLon(:)==1)
acceptnull_lon=sum(hvalsLon(:)==0)

rejectnull_mag=sum(hvalsMag(:)==1)
acceptnull_mag=sum(hvalsMag(:)==0)


%% HISTOGRAM COMPARING VELOCITY
vLatVelB=[];
vLonVelB=[];
vLatVelS=[];
vLonVelS=[];
for i=1:size(cLatVelB,1)
    for j=1:size(cLatVelB,2)
       vLatVelB=[vLatVelB,cell2mat(cLatVelB{i,j})];
       vLonVelB=[vLonVelB,cell2mat(cLonVelB{i,j})];
       vLatVelS=[vLatVelS,cell2mat(cLatVelS{i,j})];
       vLonVelS=[vLonVelS,cell2mat(cLonVelS{i,j})];
    end
end

%Magnitude of velociity
vMagVelB=sqrt(vLatVelB.^2+vLonVelB.^2);
vMagVelS=sqrt(vLatVelS.^2+vLonVelS.^2);

%%
figure(1);clf;hold on
binwid=.1;
histogram(vMagVelB,'FaceColor','r','BinWidth',binwid,'Normalization','pdf')
histogram(vMagVelS,'FaceColor','b','BinWidth',binwid,'Normalization','pdf')

xlabel('velocity (km/hr)')
ylabel('PDF')
legend('buoy','spotter')

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

hmap.Color='k';
hbeach=plot3(lons,lats,3*ones(size(lats)),'m*','LineWidth',1,'MarkerSize',4);
hbeach1=plot3(lons1,lats1,3*ones(size(lats1)),'yo','LineWidth',1,'MarkerSize',4,'LineWidth',2);

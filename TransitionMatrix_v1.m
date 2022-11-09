%trans mat, v1. This is the version where I did something weird with the
%cells. Could be helpful for making the cells be of equal area since they
%are not in v2.
%% Transtion Matrix, Schreder, 8/16/2022
% load data
load('Data/coast_latlon.mat');


%% Initial plot
%steps
dx=10; %cell size in degrees %should be 0.5-1

%discretizing with x=lon*cos(lat) y=lat
%grid of globe (via Ser-Giacomi 2015)
latbounds=[-90,90];
lonbounds=[-180,180];

%grid for center of the section
latin=latbounds(1)+dx/2:dx:latbounds(2)-dx/2;
lonin=lonbounds(1)+dx/2:dx:lonbounds(2)-dx/2;
ypt=latin'.*ones(numel(latin),numel(lonin));
xpt=lonin.*cosd(latin');

%grid for square enclosing each section
latout=latbounds(1):dx:latbounds(2);
lonout=lonbounds(1):dx:lonbounds(2);
yg=latout'.*ones(numel(latout),numel(lonout));
xg=lonout.*cosd(latout');

%create figure
figure(1);clf;hold on
daspect([1 1 1])

%plots initial points
%plot(xpt,ypt,'.m','LineWidth',3)
mesh(xg,yg,zeros(size(xg)),'EdgeColor','#CDD6DE','facecolor','none','LineWidth',0.1)
view([0,0,1])
xlim(lonbounds);ylim(latbounds)
xlabel('longitude');ylabel('latitude')

%plotting land points for refrence
coastloncheck=coast_lon>=lonbounds(1) & coast_lon<=lonbounds(2);
coastlatcheck=coast_lat>=latbounds(1) & coast_lat<=latbounds(2);
coast2use=(coastloncheck+coastlatcheck==2);
coast_y=coast_lat(coast2use);
coast_x=coast_lon(coast2use).*cosd(coast_lat(coast2use));
plot3(coast_x,coast_y,1.1*ones(size(coast_x)),'.','MarkerSize',0.5,'Color','k') %plot3 so these points end up above the surf plot

%plots all spotter points
% plot(dt.lon,dt.lat,'.','MarkerSize',0.2)

%% Assigning points to cells in the grid
%NOTE: if a point is exactly on the grid, somethings gonna break
n=1;
gridloc_vec=zeros(length(ds),2);
beached_vec=zeros(length(ds),1);
gridloc_mat=zeros(size(xg));
beached_mat=zeros(size(xg));

for i=1:length(ds)
    for j=1:length(ds(i).lat)
        latpt=ds(i).lat(j); %first latitude point for one spotter
        lonpt=ds(i).lon(j)*cosd(latpt); %first longitude point for one spotter
    %     plot(firstlon,firstlat,'b.');
    
        %finding where point lies
        row=find(latpt>yg(:,1),1,'last'); %row where the lat lies
        colg=find(lonpt>xg(row,:),1,'last'); %correct row 
        colg1=find(lonpt>xg(row+1,:),1,'last'); %1 above correct row 
    %     plot(xpt(row,col),ypt(row,col),'k.');

    
        %  need to check the columns because the grid is trapezoidal
        if colg==colg1
            col=colg;
        else
            %all the columns surrounding the point
            sizexg=size(xg,2);%min([colg,colg1]):max([colg,colg1]+1);
            mincols=min([colg,colg1]);
            maxcols=max([colg,colg1]);
            colgnum=-1*(1~=mincols)+mincols:1*(sizexg~=maxcols)+maxcols; %from mincol-1 to maxcol+1 or boundarires of grid
    
            %finds the slope of each column line; the x value closest to the
            %longitude will be the correct column
            xes=(latpt-yg(row))*(xg(row+1,colgnum)-xg(row,colgnum))./(yg(row+1)-yg(row))+xg(row,colgnum);
            colxes=find(lonpt>xes,1,'last');
            col=colgnum(colxes);
        end
%         plot(xpt(row,col),ypt(row,col),'m.');
%         pause(0.1)
    
        %storing information
        beachdist=20e3;
        gridloc_vec(n,:)=[row,col];
        beached_vec(n)=(ds(i).coast_dist(end)<=beachdist);
        gridloc_mat(row,col)=gridloc_mat(row,col)+1;
        beached_mat(row,col)=beached_mat(row,col)+(ds(i).coast_dist(end)<=beachdist);
        n=n+1;
    end
end

%% plotting transition matrix on map
trans_mat=beached_mat./gridloc_mat;
surf(xg,yg,beached_mat,'EdgeColor','none','FaceAlpha',1)
colorbar
title('N_{beached spotters}/N_{released in cell}')


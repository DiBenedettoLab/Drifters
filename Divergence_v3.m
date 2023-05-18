clc;close all;clear all

%% Load data and bin data (commented)
% load('GDPtab.mat')
% load('/Users/helenaschreder/Desktop/UW/Research/Drifters/GDPdata/GDPnratab.mat')

% load('coast_latlon.mat');
% dt=GDPnratab;
% [fig,xg,yg,xpt,ypt,hmap]=make_grid_fig('degree',1,[coast_lat',coast_lon']);
% 
% 
% % Bin velocities into 
% % griddata(GDPtab.lat,GDPtab.lon,GDPtab.ve,xg,yg)
% 
% xgv=xg(1,:);
% ygv=yg(:,1);
% 
% tic
% for i=1:numel(xgv)-1
%     for j=1:numel(ygv)-1
%         
%             indxlat = (dt.lat>ygv(j) & dt.lat<ygv(j+1));
%             indxlon = (dt.lon>xgv(i) & dt.lon<xgv(i+1));
%             indx = (indxlat+indxlon == 2);
%             cLonVel{i,j}=[dt.ve(indx)];
%             cLatVel{i,j}=[dt.vn(indx)];
% 
%     end
% end
% toc
load('VelGDP031523.mat');
load('VelGDPnra.mat');
load('coast_latlon.mat');


%maybe start by breaking down into smaller chuncks of area then run. 

%% make figure
[fig,xg,yg,xpt,ypt,hmap]=make_grid_fig2('grid',{'degree',2},'wrapmap',1,'fignum',1,'coastdata',[coast_lat',coast_lon']);
%% lat = 110574.61087757687 m

for i=1:size(cLonVel,1)
    for j=1:size(cLatVel,2)
        
        mLonV(i,j) = median([cLonVel{i,j};cLonVelnra{i,j}]);
        stdLonV(i,j) = std([cLonVel{i,j};cLonVelnra{i,j}]);
        mLatV(i,j) = median([cLatVel{i,j};cLatVelnra{i,j}]);
        stdLatV(i,j) = std([cLatVel{i,j};cLatVelnra{i,j}]);

    end
end

%changing to cartesian
uog=mLonV'/100; %turns out the velocities were in cm/s???!!
vog=mLatV'/100;
[X,Y] = meshgrid(1:2:359,-89:2:89);

%% median filtering and then divergence!!
%note: mats are 90x180 (y-x) and indexes will be row=y=j, col=x=i
neighborhood= [5,5];
u=medfilt2(uog,neighborhood);
v=medfilt2(vog,neighborhood);

% u=(uog);
% v=(vog);

% %lat and lon are so confusing we are doing this in cartesian
% dy_func = @(l1,l2) 111195*(l2-l1); 
% dx_func = @(l1,l2) 40075e3/360 * (cosd(l2)-cosd(l1));

%degree step
deg=2;
%note: i worry about how accurate my dx's are 

%five point stencil
stencil=5;
if stencil==3
    deriv = @(dx,us) (us(2)-us(1))/(dx);
    checkendsnan= @(us) [isnan(us(1)),isnan(us(2))];
    offs=1;
elseif stencil==5
    deriv = @(dx,us) (-us(4)+8*us(3)-8*us(2)+us(1))/(12*dx);
    checkendsnan= @(us) [isnan(us(1))|isnan(us(3)),isnan(us(2))|isnan(us(4))];
    offs=2;
end

%du/dx
dudx=zeros(size(u));
numx=size(u,2);
for i = 1:numx %over all x
    for j = 1:size(u,1) %for every y value

        %it is round so we can use them all
        if i==1
            pts=[numx,2,numx-1,3];
        elseif i==2
            pts=[1,3,numx,4];
        elseif i==numx-1
            pts=[i-1,i+1,i-2,1];
        elseif i==numx
            pts=[i-1,1,i-2,2];
        else
            pts=[i-1,i+1,i-2,i+2];
        end

        us(3)=u(j,pts(3));
        us(1)=u(j,pts(1));
        us(2)=u(j,pts(2));
        us(4)=u(j,pts(4));
        dx= 40075e3/360*deg*cosd(Y(j));

        % forward/backward difference if there are NaNs next to points
        nans=checkendsnan(us);
        if nans(1) %NaN on left
            dudx(j,i)=(u(j,i)-us(2))/(dx);
        elseif nans(2) %NaN on the right
            dudx(j,i)=(us(1)-u(j,i))/(dx);
        elseif nans(1) && nans(2) %NaNs on both sides
            dudx(j,i)=NaN;
        else
            dudx(j,i)=deriv(dx,us);
        end
    end
end

%dv/dy
dvdy=zeros(size(v));
for j = 1+2:size(v,1)-2 %overd all but endpoints in y
    for i = 1:size(v,2) %for every x value
    us(3)=v(j-2,i);
    us(1)=v(j-1,i);
    us(2)=v(j+1,i);
    us(4)=v(j+2,i);
    dx= 111195*deg;
    dvdy(j,i)=deriv(dx,us);


        % forward/backward difference if there are NaNs next to points
        nans=checkendsnan(us);
        if nans(1) %NaN on left
            dvdy(j,i)=(v(j,i)-us(2))/(dx);
        elseif nans(2) %NaN on the right
            dvdy(j,i)=(us(1)-v(j,i))/(dx);
        elseif nans(1) && nans(2) %NaNs on both sides
            dvdy(j,i)=NaN;
        else
            dvdy(j,i)=deriv(dx,us);
        end
    end
end

div=dudx+dvdy;
%note: add in endpoints


%% plot divergence 
[fig,xg,yg,xpt,ypt,hmap]=make_grid_fig2('grid',{'degree',2},'wrapmap',1,'fignum',1,'coastdata',[coast_lat',coast_lon']);

wrapmat = 1;
if wrapmat 
    pc = find(xpt(1,:)>=0,1,'first');
    xptw = [xpt(:,pc:end)-360,xpt,xpt(:,1:pc-1)+360];
    yptw = [ypt(:,pc:end),ypt,ypt(:,1:pc-1)];
    uw = [u(:,pc:end),u,u(:,1:pc-1)];
    vw = [v(:,pc:end),v,v(:,1:pc-1)];
    divw = [div(:,pc:end),div,div(:,1:pc-1)];
    dudxw = [dudx(:,pc:end),dudx,dudx(:,1:pc-1)];
    dvdyw = [dvdy(:,pc:end),dvdy,dvdy(:,1:pc-1)];
else
    xptw = xpt;
    yptw = ypt;
    uw = u;
    vw = v;
    divw = div;
    dudxw = dudx;
    dvdyw = dvdy;
end

pmat = divw;

%base figure
title(['divergence: stencil = ' num2str(stencil) ', filt = ' num2str(neighborhood(1)) 'x' num2str(neighborhood(2))])
ax=gca;set(ax,'Color',[0.8,0.8,0.8]) %makes NaN values grey

%plot colormap
pax=pcolor(xptw,yptw,pmat);%,'EdgeColor','none')%,'FaceAlpha',1)
% pax=pcolor(xg(1:end-1,1:end-1),yg(1:end-1,1:end-1),pmat);%,'EdgeColor','none')%,'FaceAlpha',1)
pax.EdgeColor='none';

%colorbar
load('tealcolormap.mat');colormap(dawncolormap);
c=colorbar;
stddiv=std(pmat(~isnan(pmat)));
caxis([nanmean(pmat(:))-stddiv*2,nanmean(pmat(:))+stddiv*2])

%quivers
quiv=quiver(xptw,yptw,uw,vw,'color','k','AutoScaleFactor',3);
hmap.Color='k';

%% where it beaches
plot(racoords(:,2),racoords(:,3),'w*',LineWidth=3)



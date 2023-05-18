%% Binning Velocities
% lots of data, so im going to bin the data a few at a time
% bins data into cells of 1 degree

load('coast_latlon.mat');
load('/Users/helenaschreder/Desktop/UW/Research/Drifters/GDPdata/GDPnratab.mat')

%% big cells

dt=GDPnratab;
[fig,xg,yg,xpt,ypt,hmap]=make_grid_fig('degree',1,[coast_lat',coast_lon']);

% Bin velocities into 
% griddata(GDPtab.lat,GDPtab.lon,GDPtab.ve,xg,yg)

xgv=xg(1,:);
ygv=yg(:,1);

xgvbig=linspace(min(xgv),max(xgv),10);
ygvbig=linspace(min(ygv),max(ygv),6);

tic
for i=1:numel(xgvbig)-1
    for j=1:numel(ygvbig)-1
        
            indxlat = (dt.lat>ygvbig(j) & dt.lat<ygvbig(j+1));
            indxlon = (dt.lon>xgvbig(i) & dt.lon<xgvbig(i+1));
            indx = (indxlat+indxlon == 2);
            cLonVelBig{i,j}=[dt.ve(indx)];
            cLatVelBig{i,j}=[dt.vn(indx)];
            cLonPosBig{i,j}=[dt.lon(indx)];
            cLatPosBig{i,j}=[dt.lat(indx)];
    end
end
toc
 
%% Binning Velocities

%indices where big grid intersects little grid
xxx = (xgvbig == xgv');
xxx = sum(xxx,2);
xx = find(xxx==1);

yyy = (ygvbig == ygv);
yyy = sum(yyy,2);
yy = find(yyy==1);



for ii = 1:numel(xgvbig)-1
    for jj = 1: numel(ygvbig)-1

        disp(['ii =' num2str(ii) ', jj = ' num2str(jj)])

        dtlon= cLonPosBig{ii,jj};
        dtlat= cLatPosBig{ii,jj};
        dtve = cLonVelBig{ii,jj};
        dtvn = cLatVelBig{ii,jj};

        tic
for i=xx(ii):xx(ii+1)-1
    for j=yy(jj):yy(jj+1)-1

            indxlat = (dtlat>ygv(j) & dtlat<ygv(j+1));
            indxlon = (dtlon>xgv(i) & dtlon<xgv(i+1));
            indx = (indxlat+indxlon == 2);
            cLonVelnra{i,j}=[dtve(indx)];
            cLatVelnra{i,j}=[dtvn(indx)];
            cLonPosnra{i,j}=[dtlon(indx)];
            cLatPosnra{i,j}=[dtlat(indx)];

    end
end
toc

    end 
end

% load('VelGDP031523.mat');
% load('coast_latlon.mat');


%maybe start by breaking down into smaller chuncks of area then run. 
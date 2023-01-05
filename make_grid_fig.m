%improvements: add option to automatically load lat/lon data, option to
%hide/show grid, chose figure,chose color of map

function [fig,xg,yg,xpt,ypt,hmap]=make_grid_fig(varargin)
% OPTIONS: 
% 1. degree: square cells with side length in degrees
% 2. area: cells with equal area
% grid_type,dt,fignum,coast_lat,coast_lon

intype=false;
incoast=false;
infignum=false;
for i=1:numel(varargin)

    %type of grid
    if ischar(varargin{i})
        if strncmp(varargin{i},'area',4) || strncmp(varargin{i},'degree',3)
            grid_type=varargin{i};
        else
            error("Grid type must be 'area' or 'degree'")
        end
        intype=true;
    

    %coastal data
    elseif ismatrix(varargin{i}) && sum(size(varargin{i})==2)==1
        coast_lat=varargin{i}(:,1);
        coast_lon=varargin{i}(:,2);
        incoast=true;

    %figure number
    elseif ismatrix(varargin{i}) && numel(varargin{i})==1
        fignum=varargin{i};
        infignum=true;

    %table input
    elseif istable(varargin{i}) 
        dt=varargin{i};
        intab=true;

    else
        error('your uhh input %1.0f is wrong, figure it out lol',i)

    end
end %for i=1:numel(varargin)

%loads coastal data
if ~incoast
    load('coast_latlon.mat');
    warning('Load in coastal data for faster processing')
end

%checks that a grid type was input
if ~intype
    error('Specify grid type')
end
    
%makes a figure
if infignum
    fig=figure(fignum);
else
    fig=figure;
end


%% 
switch grid_type
    case 'degree'

        %STEPS
        dx=2;
        
        %BOUNDARIES
        if ~intab
            latbounds=[floor(min(dt.lat)/dx)*dx,ceil(max(dt.lat)/dx)*dx];
            lonbounds=[floor(min(dt.lon)/dx)*dx,ceil(max(dt.lon)/dx)*dx];
        else
            lonbounds=[-180,180];
            latbounds=[-90,90];
        end
        
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
fig;clf;hold on
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

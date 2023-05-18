
function [fig,xg,yg,xpt,ypt,hmap]=make_grid_fig2(varargin)
% ---INPUTS--
% 'grid_type': 'degree' or 'area' and number of cells/steps in cell (e.g. {'degree',2})
%       degree: square cells with side length in degrees
%       area: cells with equal area
% 'fignum': figure number
% 'coastdata': [coast_lat,coast_lon] (coastal points)
% 'datatab': table of data points, used to set the x and y lims
% ---OUTPUTS--
% fig: figure handle 
% xg,yg: gridded mat
% xpt,ypt: points in the center of each grid cell
% hmap: map of coastal points, good to change color
% ---CHANGES--
% Updates (3/27/23): changed varargins to be less weird. Also added an
% option to wrap the map points
% Update (5/17/23): made the comments better

incoast = false;
ingrid = false;
wrapmap = false;
infignum = false; 
intab = false;

for i=1:numel(varargin)-1

    %%% TYPE OF GRID %%%
    if strncmp(varargin{i},'grid',4)
        gridinputs = varargin{i+1};
        grid_type = gridinputs{1}; %area or degree
        grid_step = gridinputs{2}; % # lat cells (area), degree step
        ingrid=true; %grid value inputted
        if ~strncmp(grid_type,'area',4) && ~strncmp(grid_type,'degree',3)
            error("Enter value for 'grid'; {'area',(# lat cells)} or {'degree',(deg step)}")
        end
    end

    %%% COASTAL DATA %%%
    if strncmp(varargin{i},'coastdata',9)
        coast_lat=varargin{i+1}(:,1);
        coast_lon=varargin{i+1}(:,2);
        incoast=true;
    end

    %%% WRAP MAP %%%
    %adds half of map to front and end
    if strncmp(varargin{i},'wrapmap',7)
        if varargin{i+1} ==1
            wrapmap = true;
        else
            wrapmap = false;
        end
    end

    %%% FIGURE NUMBER %%%
    if strncmp(varargin{i},'fignum',6)
        fignum=varargin{i+1};
        infignum = true; 
    end
    
    %%% TABLE INPUT %%%
    if strncmp(varargin{i},'datatab',7)
        dt=varargin{i+1};
        intab=true;
    end

end %i=1:numel('varargin')-1

%loads coastal data
if ~incoast
    load('coast_latlon.mat');
    warning('Load in coastal data for faster processing')
end
coast_lon=coast_lon(:);
coast_lat=coast_lat(:);

%sets generic grid type 
if ~ingrid
    grid_type = 'degree';
    grid_step = 2;
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
        dx=grid_step;
        
        %BOUNDARIES
        if intab
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
        c=grid_step; %amount of lateral grids, must be even, will be *2 for longitudinal
        
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
if wrapmap
    pc = coast_lon>= 0;
    coast_x = [coast_lon;coast_lon(pc)-360;coast_lon(~pc)+360];
    coast_y = [coast_lat;coast_lat(pc);coast_lat(~pc)];
else
    coastloncheck=coast_lon>=lonbounds(1) & coast_lon<=lonbounds(2);
    coastlatcheck=coast_lat>=latbounds(1) & coast_lat<=latbounds(2);
    coast2use=(coastloncheck+coastlatcheck==2);
    coast_y=coast_lat(coast2use);
    coast_x=coast_lon(coast2use);
end

hmap=plot3(coast_x,coast_y,1.1*ones(size(coast_x)),'.','MarkerSize',0.5,'Color','m'); %plot3 so these points end up above the surf plot

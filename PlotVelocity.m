%script to plot the velocities of drifters using the function plot_velocity
%update: need to get mean velocities from get_velocity, have not done that.
%not wise to do this for the whole ocean, the way the interpolated surface
%ngl, this really only is helpful for the spotter data in the north
%atlantic, east coast things amirite
%% Plot velocity Script

%paths for functions
% addpath('/Users/helenaschreder/Desktop/UW/Drifter Analysis/Online Funcs/')
% addpath('/Users/helenaschreder/Desktop/UW/Drifter Analysis/Online Funcs/m_map/')
% addpath('/Users/helenaschreder/Desktop/Old/Rochester/Mixing Lab/codelib-master/dhk')

%load data
load('Data/coast_latlon.mat')
set='spot';
location='na';
[ds,dt]=load_drift_data(set,location);

%% velocity and components
u=dt.speed.*sind(dt.direction);
v=dt.speed.*cosd(dt.direction);
vel=dt.speed;
x=dt.lon;
y=dt.lat;

%% Creating figures
% %creating grid
% grid_resolution=10;
% global_grid = GlobalGrid(grid_resolution);
% plot_velocity(u,v,vel,global_grid)

figure(1);clf;hold on
plot(coast_lon,coast_lat,'.','MarkerSize',0.1,'Color','k')
h=quiver(x,y,u,v,'Color','b');
xlim([min(x),max(x)]);ylim([min(y),max(y)])

%creating colormap below points
dtt = delaunayTriangulation(x,y) ;
tri = dtt.ConnectivityList ;
xi = dtt.Points(:,1) ; 
yi = dtt.Points(:,2) ; 
F = scatteredInterpolant(x,y,vel);
zi = F(xi,yi) ;
trisurf(tri,xi,yi,-zi) 
view(2)
shading interp

daspect([1,1,1])
colorbar
colormap spring
xlabel('longitude')
ylabel('latitude')
title(['speed of ' set])

%it's annoying me so i get rid of the negative in the colobar labels
cbar=colorbar;
ticktemp=cbar.TickLabels;
for i=1:numel(ticktemp)-1
    ticktempfixed{i}=ticktemp{i}(2:end);
end
ticktempfixed{i+1}='0';
cbar.TickLabels=ticktempfixed;
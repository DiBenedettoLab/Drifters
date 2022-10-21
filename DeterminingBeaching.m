% determing if drifters have beached
% will use the criteria that they end within 10 km of the shore and
% investigate using the coastal distance/hr (i.e. velocity) 
%% TBD, Schreder, 9/7/22
%dataset
dataset='both'; %spot or buoy
location='all'; %ocean to consider

%load data
% load('Data/coast_latlon.mat');
[ds,dt,oceanname]=load_drift_data(dataset,location);

%Beaching zone
bcrit=10; %km


%% Figure out where it is within bcrit

% dt=ds(93); %temporary

%where it is within bcrit
bdt_log=dt.coast<=bcrit; %logical of beachers in beach zone
bdt_indx=find(bdt_log==1); %indices of beachers in beach zone

%ID's where it is within bcrit
bcrit_ID=unique(dt.id(bdt_log));

%finding where it enters and exits bcrit
bdt_diff=diff(bdt_indx); %where this =1, beached points are next to each other

if sum(bdt_diff)~=numel(bdt_diff) %this means they are not all 1's
   f=find(bdt_diff~=1); %finds where there is a jump
   numf=numel(f);
else
    numf=0;
end

%indices of bdt_indx to run through. Each column represents the beginning
%and end of drifter being in beached area
s=zeros(2,numf+1); %indices for loop
s(1)=find(bdt_diff==1,1,'first'); %first
s(end)=find(bdt_diff==1,1,'last')+1; %last
h=(2:2*numf+1)'; %middle of mat
s(h)=f(floor(h/2))+rem(h,2); %lots to explain but it works


%% COAST velocity data for each set
for j=1:size(s,2) %through each column
    indx=bdt_indx(s(2*j-1):s(2*j));
    coastvel=calc_coastal_velocity(dt.coast(indx),dt.time(indx));
    intvl(j,1)=sum(coastvel);
    meanvl(j,1)=mean(abs(coastvel));
    numvl(j,1)=numel(coastvel);
    numvlunder(j,1)=sum(abs(coastvel)<=1);
end


%% All the COAST velocities 
%all coast vel
[coastvel,hours]=calc_coastal_velocity(dt.coast,dt.time);
figure(1);hold on
yyaxis right
days=hours/24;
plot(days,dt.speed,'.-b')

%% histograms of TRUE velocity of beached and non-beached
figure(2);clf;hold on
binspec=1/30;
normal='pdf';
histogram(dt.speed(~bdt_log),'FaceColor','b','FaceAlpha',0.5,'BinWidth',binspec,'Normalization',normal)
histogram(dt.speed(bdt_log),'FaceColor','m','FaceAlpha',0.5,'BinWidth',binspec,'Normalization',normal)
legend('not beached','beached')
xlabel('km/hr');ylabel(normal);title({'true velocity';[oceanname ' ' dataset]})
legend('Not Beached',['Beached (' num2str(bcrit) ' km)'])

%% TRUE Velocity of beaching vs. non beaching % plot
vcrit=0.05;
fprintf('%1s %1s\nvcrit = %1.4f\n   in: %6.0f out of %1.0f or %1.2f%%\n  out: %6.0f out of %1.0f or %1.2f%%\n',...
    oceanname,dataset,vcrit, ...
    sum(dt.speed(bdt_log)<=vcrit),sum(bdt_log),sum(dt.speed(bdt_log)<=vcrit)/sum(bdt_log)*100,...
    sum(dt.speed(~bdt_log)<=vcrit),sum(~bdt_log),sum(dt.speed(~bdt_log)<=vcrit)/sum(~bdt_log)*100)

vcrits=0:0.001:4;
for i=1:numel(vcrits)
    insum(i)=sum(dt.speed(bdt_log)<=vcrits(i));
    outsum(i)=sum(dt.speed(~bdt_log)<=vcrits(i));
end
innum=sum(bdt_log);
outnum=sum(~bdt_log);

figure(3);clf;hold on
plot(vcrits,outsum/outnum*100,'.-','Color','b')
plot(vcrits,insum/innum*100,'.-','Color','m')
xlabel('vcrit (km/hr)');ylabel('% of pings');legend('not beached','beached','Location','Best')
title('number of counts within some critical velocity')

%% Plotting trajectories and differentiating which are below vcrit
timezero=min(dt.time(bcrit_ID));
vcrits=linspace(0,0.1,20);
vcrit=0.01;

figure(4);clf;hold on
for i=1:numel(bcrit_ID)
    
    indx=([ds.id]==bcrit_ID(i));
    invcrit=(ds(indx).speed<=vcrit);
    summms(i)=sum(invcrit);
    plot((ds(indx).time-timezero)/86400,ds(indx).coast,'k.-')
    plot((ds(indx).time(invcrit)-timezero)/86400,ds(indx).coast(invcrit),'g.')
    ax=gca;
    plot(ax.XLim,bcrit*[1,1],'--r')
end
ylabel('Coast Distance (km)');xlabel('days')

%% Comparing max distances of beached and non-beached

maxcoast_dist=zeros(length(ds),1);maxcoast_beach=maxcoast_dist;
figure(5);clf;hold on


for i=1:length(ds)
    maxcoast_dist(i)=max(ds(i).coast);
    maxcoast_beach(i)=sum(bcrit_ID==ds(i).id);
end
maxcoast_beach=logical(maxcoast_beach);

plot(sort(maxcoast_dist(~maxcoast_beach)),sort(maxcoast_dist(~maxcoast_beach)),'b.')
plot(sort(maxcoast_dist(maxcoast_beach)),sort(maxcoast_dist(maxcoast_beach)),'m.')



%% A little function for velocity i suppose. 

function [coastvel,hours]=calc_coastal_velocity(coastdist,time)
    hours=(time-min(time))/86400*24; %converts time to hours.
    coastvel=nan(numel(coastdist),1);
    
    %finds velocity and acceleration vectors using central difference methods
    for i=2:numel(coastdist)-1
        h=(hours(i+1)-hours(i-1));
        coastvel(i)=(coastdist(i+1)-coastdist(i-1))/(h);
    end

    %values at 1 using forward difference method 0
    i=1;
    coastvel(i)=(-3*coastdist(i)+4*coastdist(i+1)-coastdist(i+2))/(2*h);
    
    %values at end using backward difference method
    i=numel(coastdist);
    coastvel(i)=(coastdist(i-2)-4*coastdist(i-1)+3*coastdist(i))/(2*h);
end

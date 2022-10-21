%Finds beached drifters, plots trajectories of the beached drifters, finds
%the time to beach for all drifters
%% Beaching Drifter Analysis, Schreder, 8/12/22
clc;close all;clear all;format compact
%% Finding which drifters beach
%load data

%dataset
dataset='spot'; %spot or buoy
location='na'; %ocean to consider

%load data
load('Data/coast_latlon.mat');
[ds,dt,oceanname]=load_drift_data(dataset,location);

%Beaching zone
bcrit=10; %km

%% finding Ids of beached
for i=1:length(ds)
    if sum(ds(i).coast<=bcrit)>=1

        %making sure the drifter stays on the beach
        if ds(i).coast(end)<=bcrit %last point is beached
            beach_log(i)=true;
        else
            beach_log(i)=false;
        end

    else
        beach_log(i)=false;
    end
end
beach_indx=find(beach_log==1);

%% Plotting trajectories of beached 
figure(1);clf;hold on
xlabel('normalized time (days)');ylabel('dist from shore (km)')
title(sprintf('Beach distance of %1.0f km\n%1.0f drifters',bcrit/1000,sum(beach_log)))
ax=gca;
clear legend_text
n=1;

%finding min time to normalize days
for i=1:numel(beach_indx)
    mintime(i)=min(ds(beach_indx(i)).time);
end
timezero=min(mintime);

for i=1:numel(beach_indx)
    plot((ds(beach_indx(i)).time-timezero)/86400,ds(beach_indx(i)).coast/1000,'.-')
    legend_text{n}=['spot ' num2str(ds(beach_indx(i)).id)];n=n+1;
end
plot(ax.XLim,bcrit/1000*[1,1],'--m')
legend_text{n}=['beach dist: ' num2str(bcrit/1000) ' km'];
legend(legend_text{:})

%% Finding time to beach
%12: moves to and from beach (10km)
beach_id=zeros(numel(beach_indx),1);
beach_max=beach_id;beach_max_indx=beach_id;
beach_fir_indx=beach_id;beach_fir=beach_id;beach_max_time=beach_id;beach_fir_time=beach_id;

for i=1:numel(beach_indx)
    beach_id(i)=ds(beach_indx(i)).id; %id of beached point
    [beach_max(i),beach_max_indx(i)]=max(ds(beach_indx(i)).coast); %max dist from coast
    if beach_max(i)<=bcrit %if never left beached zone
        beach_max(i)=NaN;
    end

    %finding the first point where it beaches and remains beached
    beach_all=find(ds(beach_indx(i)).coast<=bcrit);
    beach_all1=diff(beach_all);
    if beach_all1==1
        beach_fir_indx(i)=beach_all(1);
    else
        beach_fir_indx(i)=beach_all(find(beach_all1>1,1,'last')+1);
    end
    beach_fir(i)=ds(beach_indx(i)).coast(beach_fir_indx(i));

    %finding the times
    if ~isnan(beach_max(i))
        beach_max_time(i)=ds(beach_indx(i)).time(beach_max_indx(i));
        beach_fir_time(i)=ds(beach_indx(i)).time(beach_fir_indx(i));
    else
        beach_max_time(i)=NaN;
        beach_fir_time(i)=NaN;
    end
end


beach_timediff=(beach_fir_time-beach_max_time)/86400; %in days

figure(2);clf
plot(beach_timediff,beach_max/1000,'.')
xlabel('time to beach (days)');ylabel('max coast dist (km)')
title('time to beach from max coast dist')

figure(3);clf
histogram(beach_timediff,'Normalization','pdf');xlabel('time to beach (days)')

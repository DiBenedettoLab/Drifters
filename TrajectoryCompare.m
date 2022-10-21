%scrip to compare the trajectories of spotters in the atlantic ocean; both
%those that bean and those that do not beach
%% Trajectory Compare, Schreder, 8/26/22
%load data
dataset='spot';
location='na';
[ds,dt,oceanname]=load_drift_data(dataset,location);

%% Determing beached
%beaching critera
bcrit=10; %km from coast

%Ids of beached; defined as ending within some distance bcrit from coast
for i=1:length(ds)
    if ds(i).coast(end)<=bcrit %last point is beached
        beach_log(i)=true;
    else
        beach_log(i)=false;
    end
end
beach_indx=find(beach_log==1);

%normalizing time
timezero=min(dt.time);

%% plotting trajectories
figure(1);clf;hold on
colors={'b','m'}; %first is non beached, second is beached
linewid=[0.5,0.5];
for i=93%1:length(ds)
    clf;hold on
    % plot((ds(i).time-timezero)/86400,ds(i).coast,'.-','Color',colors{beach_log(i)+1},'LineWidth',linewid(beach_log(i)+1))
    plot((ds(i).time-min(ds(i).time))/86400,ds(i).coast,'.-','Color',colors{beach_log(i)+1},'LineWidth',linewid(beach_log(i)+1))
    title(['indx ' num2str(i)])
    ax=gca;
    plot(ax.XLim,bcrit*[1,1],'--r')
    pause(1)
end

ax=gca;
plot(ax.XLim,bcrit*[1,1],'--r')
xlabel('normalized time (days)');ylabel('dist from shore (km)')
title(sprintf('%s\nBeach distance of %1.0f km\n%1.0f drifters beached',oceanname,bcrit,sum(beach_log)))

%% Histograms of the maximum distance from the coast
for i=1:length(ds)
    max_coast(i)=max(ds(i).coast);
end

figure(2);clf;hold on
binwid=200;
normal='pdf';
%normal='count';
histogram(max_coast(~beach_log),'FaceColor','b','FaceAlpha',0.5,'BinWidth',binwid,'Normalization',normal)
histogram(max_coast(beach_log),'FaceColor','m','FaceAlpha',0.5,'BinWidth',binwid,'Normalization',normal)
xlabel('km');ylabel(normal);title({'Maximum Distance from Coast';oceanname})
legend('Not Beached',['Beached (' num2str(bcrit) ' km)'])

%% Time to beach vs. Max distance 
beach_id=zeros(numel(beach_indx),1);
beach_max=beach_id;beach_max_indx=beach_id;
beach_fir_indx=beach_id;beach_fir=beach_id;beach_max_time=beach_id;beach_fir_time=beach_id;
clear innout

for i=1:numel(beach_indx)
    beach_id(i)=ds(beach_indx(i)).id; %id of beached point
    [beach_max(i),beach_max_indx(i)]=max(ds(beach_indx(i)).coast); %max dist from coast
    if beach_max(i)<=bcrit %if never left beached zone
        beach_max(i)=NaN;
    end

    %finding the first point where it beaches and remains beached
    beach_all=find(ds(beach_indx(i)).coast<=bcrit);
    if numel(beach_all)==1
        beach_fir_indx(i)=beach_all;
    else
        beach_all1=diff(beach_all);
        if beach_all1==1
            beach_fir_indx(i)=beach_all(1);
            innout(i)=0;
        else
            beach_fir_indx(i)=beach_all(find(beach_all1>1,1,'last')+1);
            innout(i)=beach_id(i);
        end
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
innout(innout==0)=[];
innout=innout';


beach_timediff=(beach_fir_time-beach_max_time)/86400; %in days

figure(3);clf;hold on 
plot(beach_timediff,beach_max/1000,'+','LineWidth',5,'Color','m')
xlabel('time to beach (days)');ylabel('max coast dist (km)')
title(sprintf('%s %s time to beach (%1.0f km) from max coast dist',dataset,oceanname,bcrit))

% figure(3);clf
% histogram(beach_timediff,'Normalization','pdf');xlabel('time to beach (days)')

%% Plot an individual trajectory
%ID's of spotters to plot
id2plot=innout;

%finding indexes and minimum time
for i=1:numel(id2plot)
    indx2plot(i)=find([ds(:).id]==id2plot(i));
    mintime(i)=min(ds(indx2plot(i)).time);
end
timezero=min(mintime);

%plotting each trajectory 
figure(4);clf;hold on
clear legendtxt
n=1;
colors={'b','m'}; %first is non beached, second is beached
for i=1:numel(id2plot)
plot((ds(indx2plot(i)).time-timezero)/86400,ds(indx2plot(i)).coast,'-')%,'Color',colors{beach_log(indx2plot(i))+1})
legendtxt{n}=num2str(indx2plot(i));
n=n+1;
end

%formatting
ax=gca;
plot(ax.XLim,bcrit*[1,1],'--r')
xlabel('normalized time (days)');ylabel('dist from shore (km)')
title(sprintf('%s\nBeach distance of %1.0f km',oceanname,bcrit))
legend(legendtxt{:},'location','best')


%% Converting to datetime
unix_time=ds(indx2plot(i)).time(end);
date = datestr(unix_time/86400 + datenum(1970,1,1))

%% Comparing speed and coast distance
indx=890;
figure(5);clf;hold on
xlabel('days')
time2plot=(ds(indx).time-min(ds(indx).time))/86400;

 yyaxis right
 plot(time2plot,ds(indx).speed,'.-')
 ylabel('speed (km/hr)')

 yyaxis left
 plot(time2plot,ds(indx).coast,'.-')
 ylabel('distance from coast (km)')

 title(sprintf('%s #%1.0f',dataset,ds(indx).id))

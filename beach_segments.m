%---USAGE---
% [indx,beachtime]=beach_segments(dt,bcrit,vcrit);
%---DESCRIPTION---
% Finds segmentations where drifters enters:
%   1. beached zone
%   2. critical velocity zone
%   3. both beached and critical velocity zones
%---INPUTS---
% (dt,bcrit,vcrit,plots), enter [] to not consider bcrit of vcrit
% NOTE: be wary of entering all of dt, has not been updated to make sure
% segments are for separate ID's
% plots: 1 (on) or 0 (off)
%---OUTPUTS---
% indx: indices of the table where drifter enters (row 1) and exits (row 2
% beached zone. Each column is a different segment.
% beachtime: row vector corresponding to indx, the time that the drifter
% is in the beached zone
% NOTE: segments must have more than one data point to be output (e.g. if
% velocity is below vcrit for only one point, that is not counted)
%% Beach Segments
%{
finds the segments of time where a drifter enters a beached zone, defined
by some distance from the shore (bcrit) and/or some maximum speed (vcrit).
Inputted drifter information should be in the form of a table/struct with
categories named: coast, speed, coast_velocity, time, days_norm, and id
(can be 1x1) which are distance from coast, true speed, distance from coast
per hour, unix time, normalized days, and the id of the drifter. 
%}
function [indx,beachtime,dtout]=beach_segments(dt,bcrit,vcrit,plots)

%checks that bcrit and vcrit are entered
if isempty(bcrit) && isempty(vcrit)
    error('Enter a valid number for bcrit and/or vcrit')
end
if numel(unique(dt.id))>1
    warning('Usage not checked for cases of multiple IDs. Plots are turned off.')
    plots=0;
end

crit_exist=true; %this will become false in later checks if applicable
legnendtext=sprintf('bcrit = %1.0fkm and vcrit = %1.1ekm/hr',bcrit,vcrit);

%%% ------------------------- CRITIAL VALUES ------------------------- %%%
%where it is within bcrit
if ~isempty(bcrit)
    bcrit_log=dt.coast<=bcrit; %logical of drifters in beach zone
    bcrit_indx=find(bcrit_log==1); %indices of drifters in beach zone
else
    bcrit_log=ones(size(dt.coast));
    legnendtext=sprintf('vcrit = %1.1ekm/hr',vcrit);
end

%where it is within vcrit
if ~isempty(vcrit)
%     vcrit_log=abs(dt.speed)<=vcrit; %logical of drifters in beach zone
    vcrit_log=abs(dt.coast_velocity)<=vcrit; %logical of drifters in beach zone
    vcrit_indx=find(vcrit_log==1); %indices of drifters in beach zone
else
    vcrit_log=ones(size(dt.coast));
    legnendtext=sprintf('bcrit = %1.0fkm',bcrit);
end

%combing v and b data
crit_log=(vcrit_log+bcrit_log==2);
crit_indx=find(crit_log==1); %indices in bcrit and vcrit

if isempty(crit_indx) %there are no beached drifters
    crit_exist=false;
else

%%% ---------------------- FINDING SEGMENTATIONS ---------------------- %%%
    dt_diff=diff(crit_indx); %where this =1, beached points are next to each other
    
    if ~isempty(find(dt_diff==1)) && sum(dt_diff)~=numel(dt_diff) %there are segments
       f=find(dt_diff~=1); %finds where there is a jump
       numf=numel(f);
    
        %indices of bdt_indx to run through. Each column represents the beginning
        %and end of drifter being in beached area
        s=zeros(2,numf+1); %indices for loop
        s(1)=find(dt_diff==1,1,'first'); %first
        s(end)=find(dt_diff==1,1,'last')+1; %last
        h=(2:2*numf+1)'; %middle of mat
        s(h)=f(floor(h/2))+rem(h,2); %lots to explain but it works
    
        %where s is the same in the row and column  
        sl=s(1,:)>=s(2,:);
        s1=s(1,:);
        s1(sl)=[];
        s2=s(2,:);
        s2(sl)=[];
        s=[s1;s2];
    
        %indexes in table
        indx=crit_indx(s);

    elseif isempty(dt_diff) %there are no segmentations, just single points
        crit_exist=false;
    elseif isempty(find(dt_diff==1))
        crit_exist=false;
    else %only one segmentation
        indx=[crit_indx(1);crit_indx(end)];
    end
end %if isempty(crit_indx)

%%% -------------------------- BEACHED TIME -------------------------- %%%
%finds how long (days) drifter is in beached zone
if crit_exist %no critial values 
    saver=[];
    for j=1:size(indx,2)
        r=indx(2*j-1):indx(2*j);
        beachtime(j)=dt.days_norm(r(end))-dt.days_norm(r(1));
        saver=[saver,r];
    end

%%% ---------------------------- SAVE DATA ---------------------------- %%% 
else %runs with empty outputs
    saver=[];
    indx=[];
    beachtime=[];
    warning('No beached segments')
    legnendtext={};
end %if crit_exist

%saves the relavant data as a table
dtout.time=dt.time(crit_indx);
dtout.coast=dt.coast(crit_indx);
zz=zeros(size(dt.coast));
zz(saver)=1;
dtout.crit_log=logical(zz);

%%% ------------------------------ PLOTS ------------------------------ %%%
if plots
    figure(69);clf;hold on
    title(num2str(dt.id(1)))
    plot(dt.days_norm-min(dt.days_norm),dt.coast,'b.-');
    plot(dt.days_norm(saver)-min(dt.days_norm),dt.coast(saver),'m.');
    xlabel('days')
    ylabel('distance from coast (km)')
    legend('Not Beached',legnendtext,'Location','NE')
end
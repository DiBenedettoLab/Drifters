%finding if a drifter "beaches", meaning they 1. end within 10 km of the
%shore and 2. stop moving as calculated by the velocity
%% Find beaching

dataset='both'; %spot or buoy
location='all'; %ocean to consider
[ds,dt]=load_drift_data(dataset,location);

%% 
bcrit=10;
vcrit=1e-2;

blog=zeros(length(ds),1);
%beachedlog=zeros(length(ds),1);
for i=1:length(ds)
    if ds(i).coast(end)<=bcrit   
        [indx,beachtime]=beach_segments(ds(i),bcrit,vcrit,0);

        if max(beachtime)>=0.25
            blog(i)=true;
            
        end
    end
end
blogc=blog;
idc=[ds(logical(blogc)).id]'
% 
% log_vel=abs(ds(i).coast_velocity)<=1e-2; %we overshoot vcrit so there aren't many holes in beached data
% log_coast=ds(i).coast<=bcrit;
% 
% indx=bcrit_segments(bcrit,ds(i));
% 
% figure(3);hold on;
% plot(ds(i).days_norm((indx(1):indx(2))),ones(size(indx(1):indx(2))),'.')
% plot(ds(i).days_norm((indx(3):indx(4))),ones(size(indx(3):indx(4))),'.')
% plot(ds(i).days_norm(log_vel),1.4*ones(sum(log_vel),1),'.')
% plot(ds(i).days_norm,log_vel+log_coast,'.')
% 
% figure(4);clf
% plot(ds(i).days_norm,(log_vel+log_coast==2),'.')


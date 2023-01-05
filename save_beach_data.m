%% saving beaching information into the structs

dataset='buoy'; %spot or buoy
location='all'; %ocean to consider
[ds,dt,oceanname]=load_drift_data(dataset,location);

bcrit=10;

for i=1:numel(ds)
    beach_zone_vec=zeros(numel(ds(i).coast),1);
    for j=1:numel(ds(i).coast)
        beach_zone_vec(j)=(ds(i).coast(j)<=bcrit);
    end
    ds(i).beach_zone=logical(beach_zone_vec);
    ds(i).beached_loc=(1==beach_zone_vec(end));
end

load([dataset 'data.mat'])
buoydata.(location)=ds;
save([dataset 'data.mat'],[dataset 'data'])
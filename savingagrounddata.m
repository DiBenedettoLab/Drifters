%interpreting data from https://www.aoml.noaa.gov/phod/dac/drifter_deaths.html

tab=readtable('AGROUND:PICKED-UP PROBABILITIES OF ALL BUOYS IN DATABASE AS OF SEPTEMBER 30, 2021.txt');

tabIDs=tab.Var1;
tabaground=tab.Var8;
tabpickup=tab.Var9;

tab2=readtable('ALL BUOYS IN DATABASE AS OF October 31, 2022 (Created on- Mon Nov 28 15-29-01 EST 2022)   .txt');
IDs=tab2.Var1;
deathcode=tab2.Var19;
type=tab2.Var21;

aground=(deathcode==1);
agroundID=IDs(aground);

dataset='buoy'; %spot or buoy
location='all'; %ocean to consider
[ds,dt,oceanname]=load_drift_data(dataset,location);


bid=[ds.id];
eq=agroundID==bid;
sum(eq(:))
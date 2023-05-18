%---USAGE---
% [ds,dt,oceanname]=load_drift_data(set,location);
%---DESCRIPTION---
%loads data as a structure and table from the spotter or buoy data sets
%---INPUTS---
%case 1: (data_set)
%case 2: (data_set,ocean_location)
%---OUTPUTS---
%ds: structure with data
%dt: table with data
%ocean_name: full of the ocean
% (e.g. if ocean_location='na',ocean_name='Northern Atlantic)
%---REQUIRED ADDITIONAL FILES---
% 'buoydata2.mat'
% 'spotdata2.mat'
% contact Helena Schreder for these files
%% load_data
function [ds,dt,ocean_name]=load_drift_data(varargin)

%loads all data if no location input
if numel(varargin)==1
    data_set=varargin{1};
    ocean_location='all';
elseif numel(varargin)==2
    data_set=varargin{1};
    ocean_location=varargin{2};
else
    error("Enter a data set ('spot', 'buoy', or 'both') ")
end

%load data
switch data_set
%%% ------------------------------ SPOT ------------------------------ %%%%
    case 'spot'
        switch ocean_location 
            case 'na'
                ocean_name='North Atlantic';
                dataname='north_atlantic';
            case 'np'
                ocean_name='North Pacific';
                dataname='north_pacific';
            case 's'
                ocean_name='South';
                dataname='south';
            case 'all'
                ocean_name='Global';
                dataname='all';
            otherwise
                error(sprintf("Ocean location option for spot data:\n   'na': North Atlantic\n   'np': North Pacific\n   's': South\n   'all': Global"))
        end

        %loads data after everything has been checked
        load('spotdata.mat')
        ds=spotdata.(dataname);
        dt=spotdata.tables.(dataname);

%%% ------------------------------ BUOY ------------------------------ %%%%
    case 'buoy' 
        switch ocean_location 
            case 'na'
                ocean_name='North Atlantic';
                dataname='north_atlantic';
            case 'rest'
                ocean_name='Everything but Nort Atlantic';
                dataname='rest';
            case 'all'
                ocean_name='Global';
                dataname='all';
            otherwise
                error(sprintf("Ocean location option for buoy data:\n   'na': North Atlantic\n   'rest': Everything but Nort Atlantic\n   'all': Global"))
        end

        %loads data
        load('buoydata.mat')
        ds=buoydata.(dataname); 
        dt=buoydata.tables.(dataname);

%%% ------------------------------ BOTH ------------------------------ %%%%
    case 'both' 
        switch ocean_location 
            case 'na'
                ocean_name='North Atlantic';
                dataname='north_atlantic';
            case 'all'
                ocean_name='Global';
                dataname='all';
            otherwise
                error(sprintf("Ocean location option for buoy data:\n   'na': North Atlantic\n   'all': Global"))
        end

        %loads data
        load('buoydata.mat')
        load('spotdata.mat')
        ds=[buoydata.(dataname),spotdata.(dataname)]; 
        dt=[buoydata.tables.(dataname);spotdata.tables.(dataname)];

%%% ------------------------------ GDP ------------------------------ %%%%
    case 'GDP'
        load('GDPra.mat')
        ds=GDPra;
        dt='I didnt make this sorry';
        ocean_name='GDP';

%%% --------------------------- INCORRECT --------------------------- %%%%
    otherwise %incorrect dataset input
        error("Set should be either 'spot', 'buoy', or 'both'")
end
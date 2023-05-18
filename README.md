# Drifters

## Project Overview
Find the probability that an ocean surface drifter will end up on a beach; this will change depending on where in the ocean the drifter is.

## Functions

**TrackDrifter**
Visualizes the trajectory of drifters. Output is interactive gui that shows the trajectory of drifter in time and their distance from the coast.
_Note: you need coastal distances in the struct you use_

**make_grid_fig2**
Creates a gridded map of the globe spaced by either equal degrees or equal area. Input coastal point data for it to plot those points. Can also have the map wrap 

_Note: make_grid_fig is an old version but I haven't been able to figure out how to do the fork thing. It might be used in other places. The varagin is super weird, don't use this._

**beach_segments**
Finds the segments of time where a drifter enters a beached zone, defined by some distance from the shore (bcrit) and/or some maximum speed (vcrit).  

**calc_coastal_velocity**
Calculates coastal distance per hour using 2nd order central difference method (forward/backward for endpoints) taking into account tilmestep jumps. 

**load_drift_data**
Loads requested drifter data as a struct and table. Requested data can be from spotters, buoys, or both and can be requested from a specific region (e.g. North Atlantic).
_Note 1: requires .mat files 'buoydata.mat' and/or 'spotdata.mat'_
_Note 2: This is no longer as useful with updated data_

## Scripts

**BeachvsMaxShore**  Compares percent and number of drifters which beach to the maximum distance they go from the shore. 

**bindata_smallgrids** Bins data into grid cells. Splits into big cells and then small cells to do more efficiently. 

**DeterminingBeaching**<sup>1</sup> _I don’t really know what this does. Probably not important_

**Direction**<sup>1,2</sup> Histograms comparing the positive and negative coastal velocities of drifters

**Divergence**,**Divergence_V2**,**Divergence_V3**: versions of calculating the divergence between the bins. 

**FindBeaching**<sup>1,3</sup> _I don’t really know what this does, needs edits_

**PlotVelocity**<sup>1,2</sup> Interpolated colormap of velocity

**testTrackDrifter**<sup>1,4</sup> Track drifter for all beached spotters

**time2beach**<sup>1,2</sup> Basically an early version of beach_segments

**TrajectoryCompare**<sup>1,2</sup> Time to beach vs. max distance; maximum distance from coast; indivdual trajectories; speed and coast distance

**TransitionMatrix**<sup>1,2</sup> transition matrices. _Should fork the first two or something_

## Footnotes: Data/Functions Needed

**1**: load_data and **spotdata.mat*** and/or **buoydata.mat*** required

**2**: **coast_latlon.mat*** needed

**3**: beach_segments required 

**4**: TrackDrifter required 

*_[access data here](https://drive.google.com/drive/folders/13jtBgm7nScVc3dkiOa-_xQ08GG45zFCk?usp=sharing)_


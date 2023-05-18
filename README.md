# Drifters

## Project Overview
Find the probability that an ocean surface drifter will end up on a beach; this will change depending on where in the ocean the drifter is.

## Functions

**beach_segments**
Finds the segments of time where a drifter enters a beached zone, defined by some distance from the shore (bcrit) and/or some maximum speed (vcrit).  

**calc_coastal_velocity**
Calculates coastal distance per hour using 2nd order central difference method (forward/backward for endpoints) taking into account tilmestep jumps. 

**load_drift_data**
Loads requested drifter data as a struct and table. Requested data can be from spotters, buoys, or both and can be requested from a specific region (e.g. North Atlantic).
_Note: requires .mat files 'buoydata.mat' and/or 'spotdata.mat'_

**TrackDrifter**
Visualizes the trajectory of drifters. Output is interactive gui that shows the trajectory of drifter in time and their distance from the coast.

**make_grid_fig2**
Creates a gridded map of the globe spaced by either equal degrees or equal area. Input coastal point data for it to plot those points. Can also have the map wrap 

_Note: make_grid_fig is an old version but I haven't been able to figure out how to do the fork thing. It might be used in other places. The varagin is super weird, don't use this._

## Scripts

**BeachvsMaxShore**  Compares percent and number of drifters which beach to the maximum distance they go from the shore. 

**DeterminingBeaching**<sup>1</sup> _I don’t really know what this does, needs edits_

**Direction**<sup>1,2</sup> Histograms comparing the positive and negative coastal velocities of drifters

**FindBeaching**<sup>1,3</sup> _I don’t really know what this does, needs edits_

**PlotVelocity**<sup>1,2</sup> Interpolated colormap of velocity [_add quiver plots_]

**testTrackDrifter**<sup>1,4</sup> Track drifter for all beached spotters

**time2beach**<sup>1,2</sup> Basically an early version of beach_segments [_Could get rid of_]

**TrajectoryCompare**<sup>1,2</sup> Time to beach vs. max distance; maximum distance from coast; indivdual trajectories; speed and coast distance

**TransitionMatrix**<sup>1,2</sup> transition matrices. _v1 makes grids with equal area, incorporate this into v2_

## Footnotes: Data/Functions Needed

**1**: load_data and **spotdata.mat*** and/or **buoydata.mat*** required

**2**: **coast_latlon.mat*** needed

**3**: beach_segments required 

**4**: TrackDrifter required 

*_[access data here](https://www.youtube.com/watch?v=mx86-rTclzA)_

## To Do

**PlotVelocity** quiver plot

**TransitionMatrix** clean up and fork

**Other** fill in missing descriptions or get rid of scripts



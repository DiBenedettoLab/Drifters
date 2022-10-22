# Drifters

## Project Overview
Find the probability that an ocean surface drifter will end up on a beach; this will change depending on where in the ocean the drifter is.

## Functions

### beach_segments.m
**Finds the segments of time where a drifter enters a beached zone**, defined by some distance from the shore (bcrit) and/or some maximum speed (vcrit).  

### calc_coastal_velocity.m
**Calculates coastal distance per hour** using 2nd order central difference method (forward/backward for endpoints) taking into account tilmestep jumps. 

Etc. (add later)

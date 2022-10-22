% Function to find the velocity as the drifter approaces the shore. 
% INPUTS
%   coastdist: distance from coast
%   time: corresponding time in unix
% OUTPUTS
%   coastvel: coastal velocity in km/hr
%   hours: time converted into hours
%% Calculate Coastal Velocity, Schreder, 9.9.22
function [coastvel,hours]=calc_coastal_velocity(coastdist,time)
    hours=(time-min(time))/86400*24; %converts time to hours.
    coastvel=nan(numel(coastdist),1);

    %checks that there are the same amount of coast distances and times
    if numel(coastdist)~=numel(time)
        error('Coastal distance and time matrix must be the same size')
    end

    if numel(coastdist)>2
        %finds velocity vectors using central difference methods
        for i=2:numel(coastdist)-1
            h=(hours(i+1)-hours(i-1));
            coastvel(i)=(coastdist(i+1)-coastdist(i-1))/(h);
        end
    
        %values at 1 using forward difference method 0
        i=1;
        coastvel(i)=(-3*coastdist(i)+4*coastdist(i+1)-coastdist(i+2))/(2*h);
        
        %values at end using backward difference method
        i=numel(coastdist);
        coastvel(i)=(coastdist(i-2)-4*coastdist(i-1)+3*coastdist(i))/(2*h);
    
    elseif numel(coastdist)==2 %uses forward and backward with less points
        h=(hours(1)-hours(2));
        coastvel(1)=(coastdist(2)-coastdist(1))/h;
        coastvel(2)=coastvel(1);

    elseif numel(coastdist)==1 %no velocity but doesn't throuw an error
        warning('Coastal velocity could not be calculated, enter more than one coast distance.')
 
    else
        error('Enter a non-empty matrix of coastal distances')
    end
end
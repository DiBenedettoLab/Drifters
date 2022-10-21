%
%% Script to find the velocity to the coast

coastdist=ds(indx).coast;
hours=(ds(indx).time-min(ds(indx).time))/86400*24;

%finds velocity and acceleration vectors using central difference methods
for i=2:numel(coastdist)-1
    h=(hours(i+1)-hours(i-1));
    coastvel(i)=(coastdist(i+1)-coastdist(i-1))/(h);
    coastacc(i)=(coastdist(i-1)-2*coastdist(i)+coastdist(i+1))/(h/2)^2;
end
%values at 1 using forward difference method 0
i=1;
coastvel(i)=(-3*coastdist(i)+4*coastdist(i+1)-coastdist(i+2))/(2*h);
coastacc(i)=(2*coastdist(i)-5*coastdist(i+1)+4*coastdist(i+2)-coastdist(i+3))/h^2;

%values at end using backward difference method
i=numel(coastdist);
coastvel(i)=(coastdist(i-2)-4*coastdist(i-1)+3*coastdist(i))/(2*h);
coastacc(i)=(-coastdist(i-3)+4*coastdist(i-2)-5*coastdist(i-1)+2*coastdist(i))/h^2;

%plots
figure(6);clf
subplot(3,1,1);
plot(hours,coastdist);
title('Coast Distance');xlabel('time (hr)');ylabel('km');
subplot(3,1,2);hold on
plot(hours,coastvel);
aa=(abs(coastvel)<=0.05);
plot(hours(aa),coastvel(aa),'r*')
title('Coast Distance Velocity');xlabel('time (hr)');ylabel('km/hr');
subplot(3,1,3);
plot(hours,coastacc);
title('Coast Distance Acceleration');xlabel('time (hr)');ylabel('km/hr^2');

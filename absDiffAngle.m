function diff = absDiffAngle(newAngle, oldAngle)
%Returns the absolute value of the difference between the two angles
%Bounds the diff output between [-pi,pi].

diff = newAngle - oldAngle;
if diff > pi
    diff = diff - 2*pi;
elseif diff < -pi
    diff = diff + 2*pi;
end

diff = abs(diff);
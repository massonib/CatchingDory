function theta = getAngle(point, center)

ref_to_centre=point-center;
% Finding angle with known centre and reference point:
x=ref_to_centre(1);
y=ref_to_centre(2);

if (y>0)
    theta =atan(x/y);
end

if(y<0) && (x>=0)
    theta =atan(x/y)+pi;
end

if(y<0) && (x<0)
    theta =atan(x/y)-pi;
end

if (y==0) && (x>0)
    theta =pi/2;
end

if (y==0) && (x<0)
    theta =-pi/2;
end

if (y==0) && (x==0)
    theta =0;
end
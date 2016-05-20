function theta_ref = findAngle(RGB)

imshow(RGB)
img_size=size(RGB);
img_cntr= [img_size(1,1)/2 img_size(1,2)/2];
first=getrect;
second=getrect;

first_centre= sqrt((first(1)-img_cntr(1))^2 + (first(2)-img_cntr(2))^2);
second_centre= sqrt((second(1)-img_cntr(1))^2 + (second(2)-img_cntr(2))^2);

if (first_centre<second_centre)
    centre=[first(1) first(2)];
    ref=[second(1) second(2)];
end

if (first_centre>second_centre)
    centre=[second(1) second(2)];
    ref=[first(1) first(2)];
end

ref_to_centre=ref-centre;
% Finding angle with known centre and reference point:
x=ref_to_centre(1);
y=ref_to_centre(2);

if (y>0)
    theta_ref=atan(x/y);
end

if(y<0) && (x>=0)
    theta_ref=atan(x/y)+pi;
end

if(y<0) && (x<0)
    theta_ref=atan(x/y)-pi;
end

if (y==0) && (x>0)
    theta_ref=pi/2;
end

if (y==0) && (x<0)
    theta_ref=-pi/2;
end

if (y==0) && (x==0)
    theta_ref=0;
end
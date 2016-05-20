function theta_ref = findAngle(RGB)

imshow(RGB)
img_size=size(RGB);
%Note that the image size is given as Y,X, so this must be reversed
img_cntr= [img_size(1,2)/2, img_size(1,1)/2 ]; 
first=getrect;
second=getrect;

first_centre= sqrt((first(1)-img_cntr(1))^2 + (first(2)-img_cntr(2))^2);
second_centre= sqrt((second(1)-img_cntr(1))^2 + (second(2)-img_cntr(2))^2);

if (first_centre<second_centre)
    center = [first(1) first(2)];
    ref = [second(1) second(2)];
end

if (first_centre>second_centre)
    center =[second(1) second(2)];
    ref = [first(1) first(2)];
end

theta_ref= getAngle(ref, center);


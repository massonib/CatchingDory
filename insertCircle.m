function [outputImage] = insertCircle(I, centerX, centerY, radius)

ci = [centerY, centerX, radius];
imageSize = size(I);
[xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
mask = uint8((xx.^2)./ci(3)^2 + (yy.^2)./ci(3)^2 > 1);

%Apply the mask individually to all the layers
r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);
r = r.*mask;
g = g.*mask;
b = b.*mask;
I(:,:,1) = r;
I(:,:,2) = g;
I(:,:,3) = b;
outputImage = I;

end
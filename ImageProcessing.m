clc
clear

adjustContrast = 0;

%Load File
a = imread('BoardPic1.jpg');

%a = imresize(a, 0.3); % Use a smaller image for faster
%Adjust the contrast if necessary
if adjustContrast > 0    
    a = imadjust(a,stretchlim(a));
end 

%Prepocess using the rgb values to identify fish by color
red = a(:,:,1); green = a(:,:,2); blue = a(:,:,3);
levelr = 0.65;
levelg = 0.75; %use green to black out yellow sides of board
levelb = 0.65;
i1 = im2bw(red, levelr);
i1 = imcomplement(i1); %inverses the binary colors
i2 = im2bw(green, levelg);
i2 = imcomplement(i2);
i3 = im2bw(blue, levelb);
Isum = (i1&i2&i3);
% subplot(2,2,1), imshow(i1); title('Red Plane');
% subplot(2,2,2), imshow(i2); title('Green Plane');
% subplot(2,2,3), imshow(i3); title('Blue Plane');
% subplot(2,2,4), imshow(Isum); title('Sum of all the Planes');

%inverses the binary colors and fill the holes
Isum = imcomplement(Isum); 
Ifill = imfill(Isum, 'holes');

imshow(Ifill)

%Remove noise by looking for disks
se = strel('disk',5);
Iopenned = imopen(Ifill, se);
imshow(Iopenned)

%Get the region properties
Iregion = regionprops(Iopenned, 'centroid');
[labeled, numObjects] = bwlabel(Iopenned, 4);
stats = regionprops(labeled, 'Eccentricity', 'Area', 'BoundingBox');
areas = [stats.Area];
eccentricities = [stats.Eccentricity];

numFish = find(eccentricities);
statsDefects = stats(numFish);
figure, imshow(Iopenned);
hold on;
for idx = 1 : length(numFish)
    h = rectangle('Position', statsDefects(idx).BoundingBox);
    set(h, 'EdgeColor', [0.75 0 0]);
    hold on;
end

%c = edge(b, 'prewitt'); %default is sobel
% c = edge(Ifill, 'canny', [.3 .4]);
% d = bwmorph(c, 'dilate', 2);
% imshow(d)

%Face Detection
% detector = vision.CascadeObjectDetector(); %could use this for fish 
% detector.MergeThreshold = 1;
% bbox = step(detector, a);
% out = insertObjectAnnotation(a, 'rectangle', bbox, 'detection');
% imshow(out)

%%imopen & bwareaopen to remove small structures (small fish)
%noBackground = imextendedmin(blue, 60);
%imshow(noBackground)

%%Remove small structures
%sedisk = strel('disk', 2);
%noStickers = imopen(noBackground, sedisk);
%noStickers = bwareaopen(noStickers, 150); %removes everything under 150 pixels
%imshow(noStickers);





%Threshholding to get rid of backgroud
%d = impixel(a); %Get pixels for a color that you pick
%out = red > 50 & red < 100 & green > 100 & green < 180 & blue > 180 & blue < 220; % The board
out = red < 50 | red > 100 | green < 100 | green > 180 | blue < 180 | blue > 220; %everything but the board
%noStickers = bwareaopen(out, 50); %First, we need to have distict objects
%Then fill in gaps
se = strel('disk', 2);
%bw = imclose(noStickers, se);
%bw = imfill(bw, 'holes');
%imshow(noStickers)

%Add extra pixels in corner (avoid if not necessary (slow)
out3 = bwmorph(out, 'dilate', 1); %could dialate multiple times

%Fill in holes 
out4 = imfill(out3, 'holes'); 

%Get stats of all properties
stats = regionprops(out4);

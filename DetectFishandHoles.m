clear
clc 
xmin = 110; xDistance = 400; 
ymin = 45; yDistance = 380;


% % % Get the video feed
imaqreset; %Handles mistakely ended video feeds
vid = videoinput('winvideo', 1, 'RGB24_640x480');
vid.ROIPosition = [xmin ymin xDistance yDistance];
src = getselectedsource(vid);
src.FrameRate = '6.0000';
%Now set the video input parameters. 
%These values were determined using imaqtool
src.Saturation = 299; %%Better color disctinction
src.Gamma = 70; 
%src.Saturation = 180;
%src.Contrast = 100; 

preview(vid);

% Capture one frame of data.
pause(1);
image = getsnapshot(vid);
imwrite(image, 'WebCamFish.png', 'png');
% Delete and clear associated variables.
delete(vid)
clear vid;

a = imread('WebCamFish.png');
a = imadjust(a,stretchlim(a)); %maximize contrast
centerX = xDistance/2;
centerY = yDistance/2;
center = [centerX, centerY] ;
mainRadius = 1.05*(yDistance+xDistance)/4;
%lineWidth = 100;
%a = insertShape(a, 'circle', [centerX centerY mainRadius+lineWidth/2], 'LineWidth', lineWidth, 'Color', 'black');% center and radius of circle   
%a = cropWithCircle(a, centerX, centerY, mainRadius);
%imtool(a)
a = cropWithEllipse(a, centerX, centerY, mainRadius*.9, mainRadius);
%Show the image
imshow(a)         
hold on

%Set all the pickup locations
%ring1 is the outer ring
%ring4 is the inner ring
conv = 0.01745; % 1 degree to radians
ring1Pickups = [20.26*conv, 210.55*conv]; 
ring2Pickups = [63.59*conv, 183.80*conv];
ring3Pickups = [100.97*conv, 347.01*conv];
ring4Pickups = [157.42*conv, 291.83*conv];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%    Skew the image on an axis    %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% originalImage = a;
% degrees = 30;
% theta = 0.0175*degrees; %In radians. .0175 per degrees
% [rows, columns, numberOfColorChannels] = size(originalImage);
% newColumns = columns * cos(theta);
% newRows = rows * cos(theta);
% rotatedImage = imresize(originalImage, [rows, newColumns]);
% a = rotatedImage;
% imtool(a)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%  Rotate Image about the X-axis  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%// Generate coordinates and unravel into a single vector
% im = flip(a,1);
% [X,Y] = meshgrid(1:size(im,2), 1:size(im,1));
% x_coord = X(:); y_coord = Y(:);
% 
% red = reshape(im(:,:,1), [], 1);
% green = reshape(im(:,:,2), [], 1);
% blue = reshape(im(:,:,3), [], 1);
% scatter(x_coord, y_coord, 2, double([red green blue])/255);
% %First create a rotation matrix for the x axis for a given rotation angle theta:
% degrees = 10;
% theta = 0.0175*degrees; %In radians. .0175 per degrees
% Rx = [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];
% %Now that you're done, rotate the points:
% Pout = Rx*[x_coord.'; y_coord.'; zeros(1,numel(x_coord))];
% %Ry = [cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];
% %Pout = Ry*[x_coord.'; y_coord.'; zeros(1,numel(x_coord))];
% scatter3(Pout(1,:), Pout(2,:), Pout(3,:), 2, double([red green blue])/255);
% %scatter(Pout(1,:), Pout(2,:), 2, double([red green blue])/255);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%Find Holes and Plot them on Image%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I = a;

%Find the holes
holeStats = findHoles(I);

%Bound the holes in green rectangular boxes.
    for object = 1:length(holeStats)
        bb = holeStats(object).BoundingBox;
        center = holeStats(object).Centroid;
        rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
        plot(center(1),center(2), '-m+')
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%      Find Fish in the Image     %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I = a;

%Find the fish
stats = findFish(I, holeStats);

%Bound the fish in white circles.
for object = 1:length(stats)
        center = stats(object).Centroid;
        plot(center(1),center(2), '-w+', 'LineWidth', 3, 'MarkerSize', 30)
end
hold off

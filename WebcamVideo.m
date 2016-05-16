clear
clc
xmin = 130; xDistance = 360; 
ymin = 50; yDistance = 340;

vid = videoinput('winvideo', 1, 'RGB24_640x480');
vid.ROIPosition = [xmin ymin xDistance yDistance];
src = getselectedsource(vid);
src.FrameRate = '30.0000';
%Now set the video input parameters. 
%These values were determined using imaqtool
src.Saturation = 299; %%Better color disctinction
src.Gamma = 70; 

preview(vid);
stoppreview(vid);

%Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorSpace','rgb')
vid.FrameGrabInterval = 5;

%start the video acquisition
start(vid);

%Set some constant variables outside the while loop
centerX = xDistance/2;
centerY = yDistance/2;
center = [centerX, centerY];
trigger1 = [110, 270]; % X,Y coordinates
vector1 = trigger1 - center;
norm1 = norm(vector1);
trigger1Radii = [130, 170]; % min and max distance from center
mainRadius = (yDistance+xDistance)/4;

% Set a loop that stop after 100 frames of aquisition
while(vid.FramesAcquired<=400)
    
    % Get the snapshot of the current frame
    I = getsnapshot(vid);
    %Maximize the contrast
    I = imadjust(I,stretchlim(I));
    %Crop the image with a circle
    I = cropWithEllipse(I, centerX, centerY, 1*mainRadius, 1.05*mainRadius);
    I = insertEllipse(I, centerX, centerY-15, mainRadius*.9/1.7, mainRadius/1.7);% center and radius of circle   
    
    %Find the holes
    holeStats = findHoles(I);
    %Find the fish
    stats = findFish(I, holeStats);
    
    % Display the image
    imshow(I)
    hold on
    
    %plot the main circle's center point
    plot(centerX,centerY-10, '-r+') %note that the Y-axis is down

    %Bound the fish in white circles.
    for object = 1:length(stats)
        fishCenter = stats(object).Centroid;
        diameter = mean([stats(object).MajorAxisLength stats(object).MinorAxisLength],2);
        radii = diameter/2;
        viscircles(fishCenter,radii,'Color','w');
        plot(fishCenter(1),fishCenter(2), '-w+')
        
        %Check if any of the fish are close to the line.
        fishVector = fishCenter - center;
        if fishVector(2) > 0 % On the bottom side of the board
            fishNorm = norm(fishVector);
            if fishNorm > trigger1Radii(1) && fishNorm < trigger1Radii(2)
                theta = acos(dot(vector1, fishVector) / (norm1*fishNorm)); %returns angle in radians.
                if theta < 0.15 %if missing trigger due to lag, increase this value (though that will decrease accuracy)
                    viscircles(fishCenter,radii,'Color','g');
                    plot(fishCenter(1),fishCenter(2), '-w+')
                end 
            end
        end
    end
    
    
    %Bound the holes in green rectangular boxes.
    for object = 1:length(holeStats)
        bb = holeStats(object).BoundingBox;
        holeCenter = holeStats(object).Centroid;
        rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
        plot(holeCenter(1),holeCenter(2), '-m+')
    end

    hold off
end

% Stop the video aquisition.
stop(vid);
% Flush all the image data stored in the memory buffer.
flushdata(vid);
delete(vid);

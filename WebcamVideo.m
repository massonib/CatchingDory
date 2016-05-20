clear
clc
xmin = 115; xDistance = 400; 
ymin = 55; yDistance = 380;
boardCenterX = 200 -xmin + 115;
boardCenterY = 190 -ymin + 38;
boardCenter = [boardCenterX, boardCenterY];

%%%%%%%%%%%%%%%%%%%%%%%%% CONFIGURE VIDEO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vid = videoinput('winvideo', 1, 'RGB24_640x480');
vid.ROIPosition = [xmin ymin xDistance yDistance];
src = getselectedsource(vid);
src.FrameRate = '6.0000';
%Now set the video input parameters. 
%These values were determined using imaqtool
src.Saturation = 299; %%Better color disctinction
src.Gamma = 70; 

% preview(vid);
%stoppreview(vid);

%Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorSpace','rgb')
vid.FrameGrabInterval = 1;

% Instead of calling getsnapshot, which has a lot of overhead.
% We use a manual approach. See "acquiring a single image in a loop"
% example on Mathworks.com
% Configure the object for manual trigger mode.
triggerconfig(vid, 'manual');

%start the video acquisition
start(vid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Set some constant variables outside the while loop
centerX = xDistance/2;
centerY = yDistance/2;
center = [centerX, centerY];
trigger1 = [300, 325]; % X,Y coordinates
vector1 = trigger1 - center;
norm1 = norm(vector1);
trigger1Radii = [130, 180]; % min and max distance from center
mainRadius = (yDistance+xDistance)/4;

tic
while(toc < 20) %Run for 30 seconds
    
    % Get the snapshot of the current frame
    % Instead of calling getsnapshot, which has a lot of overhead.
    % We use a manual approach. See acquiring a single image in a loop
    % example on Mathworks.com
    I = getsnapshot(vid);
    
    %Maximize the contrast
    I = imadjust(I,stretchlim(I));
    %Crop the image with a circle
    I = cropWithEllipse(I, centerX, centerY, 1*mainRadius, 1.05*mainRadius);
    %I = insertEllipse(I, centerX, centerY, mainRadius*.9/1.7, mainRadius/1.7);% center and radius of circle   
    
    %Find the holes
    holeStats = findHoles(I);
    %Find the fish
    stats = findFish(I, holeStats);
    
    % Display the image
    imshow(I)
    hold on
    
    %plot the main circle's center point
    plot(boardCenterX, boardCenterY, '-r+', 'LineWidth', 1, 'MarkerSize', 400) %note that the Y-axis is down

    %Bound the fish in white circles.
    for object = 1:length(stats)
        fishCenter = stats(object).Centroid;
        plot(fishCenter(1),fishCenter(2), '-w+', 'LineWidth', 3, 'MarkerSize', 30)
        
        %Check if any of the fish are close to the line.
        fishVector = fishCenter - boardCenter;
        if fishVector(2) > 0 % On the bottom side of the board
            fishNorm = norm(fishVector);
            if fishNorm > trigger1Radii(1) && fishNorm < trigger1Radii(2)
                theta = acos(dot(vector1, fishVector) / (norm1*fishNorm)); %returns angle in radians.
                if theta < 0.15 %if missing trigger due to lag, increase this value (though that will decrease accuracy)
                    plot(fishCenter(1),fishCenter(2), '-g+', 'LineWidth', 3, 'MarkerSize', 30)
                end 
            end
        end
    end
    
    
    %Bound the holes in green rectangular boxes.
    for object = 1:length(holeStats)
        holeCenter = holeStats(object).Centroid;
        plot(holeCenter(1),holeCenter(2), '-m+', 'LineWidth', 3, 'MarkerSize', 10)
    end

    hold off
    
end
% Stop the video aquisition.
stop(vid);
% Flush all the image data stored in the memory buffer.
flushdata(vid);
delete(vid);


% catch
% % Stop the video aquisition.
% stop(vid);
% % Flush all the image data stored in the memory buffer.
% flushdata(vid);
% delete(vid);   
%end

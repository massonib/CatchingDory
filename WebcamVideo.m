clear
clc

offsetAngle = -1.09;
robotLag = 0.5;

xmin = 98; xDistance = 400; 
ymin = 52; yDistance = 380;
boardCenterX = 200 -xmin + 98;
boardCenterY = 190 -ymin + 35;
boardCenter = [boardCenterX, boardCenterY];

%%%%%%%%%%%%%%%%%%%%%%%%% CONFIGURE VIDEO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imaqreset;
vid = videoinput('winvideo', 1, 'RGB24_640x480');
vid.ROIPosition = [xmin ymin xDistance yDistance];
src = getselectedsource(vid);
src.FrameRate = '6.0000';
frameRate = 6;
%Now set the video input parameters. 
%These values were determined using imaqtool
src.Saturation = 299; %%Better color disctinction
src.Gamma = 70; 

% preview(vid);
%stoppreview(vid);

%Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorSpace','rgb')
frameGrabRate = 1;
vid.FrameGrabInterval = frameGrabRate;

% Instead of calling getsnapshot, which has a lot of overhead.
% We use a manual approach. See "acquiring a single image in a loop"
% example on Mathworks.com
% Configure the object for manual trigger mode.
triggerconfig(vid, 'manual');

%start the video acquisition
start(vid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Set some constant variables outside the while loop
vidCenterX = xDistance/2;
vidCenterY = yDistance/2;
vidCenter = [vidCenterX, vidCenterY];
mainRadius = (yDistance+xDistance)/4;

%Radian Positions for Open Mouth Fish, with row1 = ring 1 (outerRing)
ringAnglesPreOffset = [0.39, -2.48 ; 0.99, -3.03 ; -0.19, 1.7 ; 2.81, -1.03]; 
ringAngles = [0,0,0,0];
%For each row, get the closer value to -1.2 radians (robot's 0) after
%offset
for i = 1:4
    newPositions = [0, 0];
    differences = [0, 0];
    for j = 1:2
        position = ringAnglesPreOffset(i,j);
        new = position + offsetAngle;
        if new > pi %CCW rotation over the 12 on a clock 
            new = new - 2*pi;
        elseif new < -pi %CW rotation over the 12 on a clock
            new = new + 2*pi;
        end
        newPositions(j) = new;
        differences(j) = absDiffAngle(-1.2, new);
    end
    [val, j] = min(differences);
    ringAngles(i) = newPositions(j);
end

cropMultipliers = [1, 0.75, 0.51, 0.4];
cropH = cropMultipliers.*(mainRadius);
cropV = cropMultipliers.*(1.05*mainRadius);
ringMultipliers = [0.6, 0.35, 0.2, 0.01];
ringH = ringMultipliers.*(.9*mainRadius);
ringV = ringMultipliers.*(mainRadius);

currentRing = 1;
tic
needNewFish = 1;
V = [];
timerVal = tic;
Vmean = 1;
try
while(toc < 30) %Run for 30 seconds
    lagStart = tic; 
    % Get the snapshot of the current frame
    % Instead of calling getsnapshot, which has a lot of overhead.
    % We use a manual approach. See acquiring a single image in a loop
    % example on Mathworks.com
    I = getsnapshot(vid);
    
    %Maximize the contrast
    I = imadjust(I,stretchlim(I));
    %Crop the image with a circle
    if currentRing == 1
        I = cropWithEllipse(I, vidCenterX, vidCenterY, cropH(currentRing), cropV(currentRing));
        %I = insertEllipse(I, boardCenterX, boardCenterY, ringH(currentRing), ringV(currentRing));% center and radius of circle    
    elseif currentRing > 1
        cropCenterX = (boardCenterX + vidCenterX)/2;
        cropCenterY =(boardCenterY + vidCenterY)/2;
        I = cropWithEllipse(I, cropCenterX, cropCenterY, cropH(currentRing), cropV(currentRing));
        %I = insertEllipse(I, boardCenterX, boardCenterY, ringH(currentRing), ringV(currentRing));% center and radius of circle    
    end
    %Find the holes
    holeStats = findHoles(I);
    %Find the fish
    stats = findFish(I, holeStats);
    
    %Calculate Velocity
    elapsedTime = toc(timerVal);
    timerVal = tic;
    if ~isempty(stats) %if not empty
        if needNewFish == 1;
            firstFish = stats(1);
            needNewFish = 0;
        else
            needNewFish = 1;
            %Try to track the firstFish from last image
            oldAngle = getAngle(firstFish.Centroid, boardCenter);
            %Check all the current fish for a match
            for i = 1:length(stats)
                newAngle = getAngle(stats(i).Centroid, boardCenter);
                if newAngle > 0 && oldAngle < 0
                    diff = (pi - newAngle) + (pi + oldAngle);
                else
                    diff = oldAngle - newAngle;
                end
                %Diff should never be negative!!
                if diff > 0 && diff < 0.2 %.2 radians
                    needNewFish = 0;
                    %Found the fish. Now calculate the angular velocity
                    angleVelocity = diff/elapsedTime;
                    if angleVelocity > 0.2 && angleVelocity < 1.5
                        V = [angleVelocity V];
                        sizeOfV = 50;
                        if length(V) > sizeOfV
                            V = V(1:sizeOfV);
                        end
                        Vmean = mean(V);
                    end
                    break
                end
            end
        end
    end
    
    % Display the image
    imshow(I)
    hold on
    
    %plot the main circle's center point
    plot(boardCenterX, boardCenterY, '-r+', 'LineWidth', 1, 'MarkerSize', 400) %note that the Y-axis is down

    %Bound the fish in white circles.
    for object = 1:length(stats)
        fishCenter = stats(object).Centroid;
        plot(fishCenter(1),fishCenter(2), '-w+', 'LineWidth', 3, 'MarkerSize', 30)
    end
    
    %Offset ringAngle for velocity and lag
    processLag = toc(lagStart);
    pickupAngle =  ringAngles(currentRing) + Vmean*(processLag + robotLag);
    if pickupAngle > pi 
        pickupAngle = pickupAngle - 2*pi;
    end
    pickupAngle;
    
    %Check if any of the fish are close to the line.
    for object = 1:length(stats)
        fishCenter = stats(object).Centroid;
        fishAngle = getAngle(fishCenter, boardCenter);
        diff = absDiffAngle(fishAngle, pickupAngle);
        if diff < 0.1 %if missing trigger due to lag, increase this value (though that will decrease accuracy)
            plot(fishCenter(1),fishCenter(2), '-g+', 'LineWidth', 3, 'MarkerSize', 30)
            break
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


catch
% Stop the video aquisition.
stop(vid);
% Flush all the image data stored in the memory buffer.
flushdata(vid);
delete(vid);   
end

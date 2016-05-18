clear
clc

%%%%%%%%%%%%%%%% Setup Camera %%%%%%%%%%%%%%%%%%%%%%%%%
xmin = 110; xDistance = 400; 
ymin = 45; yDistance = 380;

vid = videoinput('winvideo', 1, 'RGB24_640x480');
vid.ROIPosition = [xmin ymin xDistance yDistance];
src = getselectedsource(vid);
src.FrameRate = '30.0000';
%Now set the video input parameters. 
%These values were determined using imaqtool
src.Saturation = 299; %%Better color disctinction
src.Gamma = 70; 
I = getsnapshot(vid);
imshow(I);
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
trigger1 = [300, 325]; % X,Y coordinates
vector1 = trigger1 - center;
norm1 = norm(vector1);
trigger1Radii = [130, 180]; % min and max distance from center
mainRadius = (yDistance+xDistance)/4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Find angle 

%%%%%%%%%%%%%%% Setup Arduino %%%%%%%%%%%%%%%%%%%%%%%%
arduino=serial('COM4','BaudRate',9600); % create serial communication object on port COM4
fopen(arduino); % initiate arduino communication
stopValue = 'done';
pause(5); %Pause for 5 seconds to allow for connection to be established

%Send angle to Arduino "Note that the first three values will always be an
%angle +> 010 = ten degrees. 348 = 348 degrees.

resetRobot(arduino);
currentRing = 1;
goToRing(arduino, currentRing);
%Check position on all rings
%Start at position above inner ring
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cropH = mainRadius;
cropV = 1.05*mainRadius;
ringH = mainRadius*.9/1.7;
ringV = mainRadius/1.7;
%%Note that the Arduino controls when to start and stop the game
%%This code can be running before and after without inference or penalty.
% Set a loop that stop after signal is changed????
while(vid.FramesAcquired<=400 && currentRing < 5)
    % Get the snapshot of the current frame
    I = getsnapshot(vid);
    %Maximize the contrast
    I = imadjust(I,stretchlim(I));
    %Crop the image with a circle
    I = cropWithEllipse(I, centerX, centerY, cropH, cropV);
    I = insertEllipse(I, centerX, centerY-15, ringH, ringV);% center and radius of circle   
    
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
                if theta < 0.3 %if missing trigger due to lag, increase this value (though that will decrease accuracy)
                    viscircles(fishCenter,radii,'Color','g');
                    plot(fishCenter(1),fishCenter(2), '-w+')
                    dropPole(arduino);
                    success = checkIfCaught(vid);
                    %If caught, drop it off. Else, continue fishing.
                    if(success == 1)
                        %Note that video processing will not continue until
                        %The drop off fish function has returned 
                        dropOffFish(arduino);
                    end
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
    
    %If no fish, update the ellipse variables 
    %and tell the arduino to go to the next ring.
    if length(stats) < 1
        cropH = cropH/1.7;
        cropV = cropV/1.7;
        ringH = ringH/1.7;
        ringV = ringV/1.7;
        currentRing = currentRing + 1;
        if(currentRing < 5)
            goToRing(arduino, currentRing);
        end
    end 
end

%%Tackle the blue fish if we ever get here.

% Stop the video aquisition.
stop(vid);
% Flush all the image data stored in the memory buffer.
flushdata(vid);
delete(vid);
fclose(arduino); 

clear
clc

%%%%%%%%%%%%%%% Setup Arduino %%%%%%%%%%%%%%%%%%%%%%%%
arduino=serial('COM4','BaudRate',9600); % create serial communication object on port COM4
%arduino.ReadAsyncMode = 'continuous'; %manual did not work when I tried it turning off and on async.
fopen(arduino); % initiate arduino communication
closeFID = onCleanup(@() fclose(arduino));
closeFID2 = onCleanup(@() delete(arduino));
stopValue = 'done';
pause(5); %Pause for 5 seconds to allow for connection to be established
status = 1; %This is the equivalent of a boolean for 'Ready'. 0 = 'Busy'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Setup Angle
RobotZero = -1.12;
robotLag = 0.4;
imaqreset;%Handles mistakely ended video feeds
vid = videoinput('winvideo', 1, 'RGB24_640x480');
src = getselectedsource(vid);
src.FrameRate = '6.0000';
preview(vid);
anglePic = getsnapshot(vid);
delete(vid)
clear vid;
offsetAngle = findAngle(anglePic);
robotOffsetAngle = robotAngle(offsetAngle);%Degrees
fprintf('Offset = %s Degrees\n',robotOffsetAngle);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% Setup Camera %%%%%%%%%%%%%%%%%%%%%%%%%
xmin = 98; xDistance = 400; 
ymin = 52; yDistance = 380;
boardCenterX = 200 -xmin + 98;
boardCenterY = 190 -ymin + 35;
boardCenter = [boardCenterX, boardCenterY];

%Create video 1 and set it parameters
vid = videoinput('winvideo', 1, 'RGB24_640x480');
vid.ROIPosition = [xmin ymin xDistance yDistance];
src = getselectedsource(vid);
src.FrameRate = '6.0000';
frameRate = 6;
src.Saturation = 299; %%Better color disctinction
src.Gamma = 70; 
I = getsnapshot(vid);
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorSpace','rgb')
frameGrabRate = 1;
vid.FrameGrabInterval = frameGrabRate;
% Instead of calling getsnapshot, which has a lot of overhead.
% We use a manual approach. See "acquiring a single image in a loop"
% example on Mathworks.com
% Configure the object for manual trigger mode
triggerconfig(vid, 'manual');
%start the video acquisition
start(vid);
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
        differences(j) = absDiffAngle(RobotZero, new);
    end
    [val, j] = min(differences);
    ringAngles(i) = newPositions(j);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cropMultipliers = [1, 0.75, 0.55, 0.45];
cropH = cropMultipliers.*(mainRadius);
cropV = cropMultipliers.*(1.05*mainRadius);
ringMultipliers = [0.6, 0.35, 0.2, 0.01];
ringH = ringMultipliers.*(.9*mainRadius);
ringV = ringMultipliers.*(mainRadius);
%%Note that the Arduino controls when to start and stop the game
%%This code can be running before and after without inference or penalty.
% Set a loop that stop after signal is changed????

counter = 0;
needNewFish = 1;
V = [];
Vmean = 1; %Initialization
timerVal = tic;

read = '';
if arduino.BytesAvailable > 0
    read = fscanf(arduino, '%s');  
end
fprintf('Ready to Start\n');
while strcmp(read, 'Ready') ~= 1
    pause(0.5);
    if arduino.BytesAvailable > 0      
        read = fscanf(arduino, '%s');  
    end
end

fwrite(arduino, robotOffsetAngle);
resetRobot(arduino);
fwrite(arduino, '8');
currentRing = 2;
status = goToRing(arduino, currentRing, status);
missedCounter = 0;
goToNextRing = 0;
timeOfLastTrigger = tic;

tic
startTimeInRing = tic;
while(toc < 1400)%2 minutes + 20 seconds
    %Go to the next ring if no fish in hole or time in ring has exceeded 40
    %seconds
    timeInRing = toc(startTimeInRing);
    if currentRing == 2 && timeInRing > 60 
        goToNextRing = 1;
    end
    if goToNextRing == 1
        if currentRing == 2
            currentRing = 1;
        elseif currentRing == 1
            currentRing = 3;
        elseif currentRing == 3
            currentRing = 4;
        elseif currentRing == 4
            currentRing = 2;
        end
        resetRobot(arduino);
        status = goToRing(arduino, currentRing, status);
        goToNextRing = 0;
        startTimeInRing = tic;
        timeOfLastTrigger = tic;
    end
    
    lagStart = tic; 
    % Get the snapshot of the current frame
    I = getsnapshot(vid);
    %Maximize the contrast
    I = imadjust(I,stretchlim(I));

    %Crop the image with a circle
    if currentRing == 1
        I = cropWithEllipse(I, vidCenterX, vidCenterY, cropH(currentRing), cropV(currentRing));
        I = insertEllipse(I, boardCenterX, boardCenterY+5, ringH(currentRing), ringV(currentRing));% center and radius of circle    
    elseif currentRing > 1
        cropCenterX = (boardCenterX + vidCenterX)/2;
        cropCenterY =(boardCenterY + vidCenterY)/2;
        I = cropWithEllipse(I, cropCenterX, cropCenterY, cropH(currentRing), cropV(currentRing));
        I = insertEllipse(I, boardCenterX, boardCenterY, ringH(currentRing), ringV(currentRing));% center and radius of circle    
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
                    diff = 2*pi - newAngle + oldAngle;
                else
                    diff = oldAngle - newAngle;
                end
                %Diff should never be negative!!
                if diff > 0 && diff < 0.2 %.2 radians
                    needNewFish = 0;
                    %Found the fish. Now calculate the angular velocity
                    angleVelocity = diff/elapsedTime;
                    if angleVelocity > 0.5 && angleVelocity < 1.5
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
    %TODO: erro on next line after it moves.
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
            %First, check if the arduino is ready 
            %Note, have the arduino send a 'Ready' signal every
            %second
            status = isReady(arduino, status);
            if status == 1 %If 'Ready' 
                fwrite(arduino, '5'); %drop off fish
            end
            timeOfLastTrigger = tic;
            break;
        end 
    end
    
    
    %Bound the holes in green rectangular boxes.
    for object = 1:length(holeStats)
        holeCenter = holeStats(object).Centroid;
        plot(holeCenter(1),holeCenter(2), '-m+', 'LineWidth', 3, 'MarkerSize', 10)
    end

    hold off
    
    %If no fish, update the ellipse variables 
    %and tell the arduino to go to the next ring.   
    if isempty(stats) %if empty
        counter = counter + 1;
        if counter > 12 %30 frames. 2 seconds
            goToNextRing = 1;
        end
    else
        counter = 0;
    end 
    timeFromLastTrigger = toc(timeOfLastTrigger);
    if timeFromLastTrigger > 10 %10 Seconds
        goToNextRing = 1;
    end
end

%%Tackle the blue fish if we ever get here.

% Stop the video aquisition.
stop(vid);
% Flush all the image data stored in the memory buffer.
flushdata(vid);
delete(vid);
fclose(arduino); 
delete(arduino);

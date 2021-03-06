clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%% CONFIGURE VIDEO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imaqreset; %Handles mistakely ended video feeds
vid = videoinput('winvideo', 3, 'MJPG_640x480');
vid.ROIPosition = [293 296 119 149];
src = getselectedsource(vid);
src.Contrast = 64;
src.Saturation = 128;
src.FrameRate = '5.0000';
frameRate = 5;
frameGrabRate = 1;
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorSpace','rgb')
vid.FrameGrabInterval = frameGrabRate;

%preview(vid);
%stoppreview(vid);

% Instead of calling getsnapshot, which has a lot of overhead.
% We use a manual approach. See "acquiring a single image in a loop"
% example on Mathworks.com
% Configure the object for manual trigger mode.
triggerconfig(vid, 'manual');

%start the video acquisition
start(vid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
while(toc < 30) %Run for 30 seconds
    I = getsnapshot(vid);
    imshow(I)
    %Do image processing to determine if we have a fish
end

% Stop the video aquisition & flush all the stored image data.
stop(vid);
flushdata(vid);
delete(vid);

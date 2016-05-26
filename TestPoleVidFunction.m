clc
clear
Vid2Position = [0 83 352 182];
%Set second video 

imaqreset;
vid2 = videoinput('winvideo', 3, 'YUY2_352x288');
vid2.ROIPosition = Vid2Position;
src2 = getselectedsource(vid2);
src2.FrameRate = '5.0000';
src2.BacklightCompensation = 'off';
%src2.Contrast = 64;
set(vid2, 'FramesPerTrigger', Inf);
set(vid2, 'ReturnedColorSpace','rgb')
vid2.FrameGrabInterval = 1;
triggerconfig(vid2, 'manual');
start(vid2);
%preview(vid2);
pause(1);

I2 = getsnapshot(vid2);
imwrite(I2, 'WebCamFish.png', 'png');
I2 = imread('WebCamFish.png');
isFishOnHook = fishOnHook(I2, Vid2Position)
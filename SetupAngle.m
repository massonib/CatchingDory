clc
clear

% vid = videoinput('winvideo', 1, 'RGB24_640x480');
% src = getselectedsource(vid);
% src.FrameRate = '6.0000';
% %Now set the video input parameters. 
% %These values were determined using imaqtool
% % src.Saturation = 299; %%Better color disctinction
% % src.Gamma = 70; 
% 
% % % Open a live preview window.  Point camera onto a piece of colorful fabric.
% preview(vid);
% % pause(1);
% % Capture one frame of data.
% I = getsnapshot(vid);
% % Delete and clear associated variables.
% delete(vid)
% clear vid;

I = imread('ZeroAngle.png');
offsetAngle = findAngle(I);

clear
clc 
xmin = 130; xDistance = 360; 
ymin = 64; yDistance = 326;

%Get the video feed
% vid = videoinput('winvideo', 1, 'RGB24_640x480');
% vid.ROIPosition = [xmin ymin xDistance yDistance];
% src = getselectedsource(vid);
% src.FrameRate = '30.0000';
% %Now set the video input parameters. 
% %These values were determined using imaqtool
% src.Saturation = 299; %%Better color disctinction
% src.Gamma = 70; 
% 
% % % Open a live preview window.
% preview(vid);
% stoppreview(vid);


% % Capture one frame of data.
% image = getsnapshot(vid);
% imwrite(image,'WebCamFish.png','png');
% % Delete and clear associated variables.
% delete(vid)
% clear vid;

a = imread('WebCamFish.png');
a = imadjust(a,stretchlim(a)); %maximize contrast
centerX = xDistance/2;
centerY = yDistance/2;
mainRadius = 1.05*(yDistance+xDistance)/4;
a = cropWithEllipse(a, centerX, centerY, mainRadius*.9, mainRadius);
lineWidth = 100;
a = insertEllipse(a, centerX, centerY-15, mainRadius*.9/1.7, mainRadius/1.7);% center and radius of circle   
%Show the image
imshow(a)         
hold on

%plot the main circle's center point
plot(centerX,centerY-10, '-r+') %note that the Y-axis is down

theta1_ref=1.1363; %angle between first pole and the reference axis
r1= 130; %distance between center of the board and the corner of the preferred window
ref=[328 903];
ref_new=[ref(1)-centerX ref(2)-centerY]; %coordinates of reference point in 
radius=sqrt((ref_new(1))^2+(ref_new(2))^2); %radius of the board

x=ref_new(1);
y=ref_new(2);
 
if (x>0)
    theta_ref=atan(y/x);
end

if(x<0) && (y>=0)
    theta_ref=atan(y/x)+pi;
end

if(x<0) && (y<0)
    theta_ref=atan(y/x)-pi;
end

if (x==0) && (y>0)
    theta_ref=pi/2;
end

if (x==0) && (y<0)
    theta_ref=-pi/2;
end

if (x==0) && (y==0)
    theta_ref=0;
end

theta1=theta_ref-theta1_ref;

x1_new=r1*cos(theta1);
y1_new=r1*sin(theta1);

x1=x1_new+centerX;
y1=y1_new+centerY;

plot(x1,y1, '-g+') %note that the Y-axis is down

hold off

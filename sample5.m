clc;
clear all;
close all;

%% properties of pole #1

theta1_ref=1.1363; %angle between first pole and the reference axis
r1= 130; %distance between center of the board and the corner of the preferred window
width1 = 150;
length1= 240;

%%
file = 'board1.jpg';

img = imread(file);
%imshow(img)
%rect=getrect;
 img_grey=rgb2gray(img);
 imshow(img_grey);
%  ref=getrect;
%  centre=getrect;
ref=[328 903];
centre=[668 401];

 ref_new=[ref(1)-centre(1) ref(2)-centre(2)]; %coordinates of reference point in 
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


%%
theta1=theta_ref-theta1_ref;

x1_new=r1*cos(theta1);
y1_new=r1*sin(theta1);

x1=x1_new+centre(1);
y1=y1_new+centre(2);
x1_end=x1+width1;
y1_end=y1+length1;

img_grey2=img(x1:x1_end,y1:y1_end);
imshow(img_grey2)
 % We need to change the origin of the coordinates to the center point
% % 
%  RI = imref2d(size(img));
 
%  imshow(img_grey2)
%   imp=detectSURFFeatures(img_grey);
%   hold on
%   plot(selectStrongest(imp,21));
 % imshow(img_grey,[0 100],[0 100]);
% imtool(repmat(img_grey,[1 1 1]))
% 
% figur
% imshow(img,RI);

% [X,map] = imread('board1.jpg');
% imtool(X,map)

%% 

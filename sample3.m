clc;
clear all;
close all;


file = 'board1.jpg';

img = imread(file);
%imshow(img)
%rect=getrect;
 img_grey=rgb2gray(img);
 imshow(img_grey);
 rect=getrect;
% % 
%  RI = imref2d(size(img));
  width = [rect(1) rect(1)+rect(3)];
  length = [rect(2) rect(2)+rect(4)];
  
  img_grey2=img_grey(length(1,1):length(1,2),width(1,1):width(1,2));
 % imshow(img_grey2)
  imp=detectSURFFeatures(img_grey);
  hold on
  plot(selectStrongest(imp,21));
 % imshow(img_grey,[0 100],[0 100]);
% imtool(repmat(img_grey,[1 1 1]))
% 
% figur
% imshow(img,RI);

% [X,map] = imread('board1.jpg');
% imtool(X,map)
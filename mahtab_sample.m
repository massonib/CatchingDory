clc;
clear all;
close all;


file = 'board1.jpg';

img = imread(file);
imshow(img)
img1 = (img(:,:,3) >90) & (img(:,:,3)>img(:,:,2)) & (img(:,:,3)>img(:,:,1));
%figure; imshow(img1)
 img2 = imfill(img1,'holes');
img3=abs(img1-img2);
%figure
%imshow(img3);
img_grey=rgb2gray(img);

boxPoints = detectSURFFeatures(img_grey);
BW=imfill(img3);
%figure
%imshow(img3)
 hold on;
 plot(selectStrongest(boxPoints,80));
 figure
 imshow(boxPoints)
% color = [63 72 204];
% 
% img1 = (img(:,:,1) == color(1)) & (img(:,:,2) == color(2)) & (img(:,:,3) == color(3));
% 
% figure
% imshow(img1)
% % se = strel('square',100);
% % img2 = imdilate(img1,se);
% img2 = imfill(img1,'holes');
% 
% figure;
% imshow(img2)
% 
% figure;
% imshow(abs(img1-img2))
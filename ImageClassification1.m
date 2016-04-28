% % setDir  = fullfile('documents','applied robotics','image processing', '2','OpenMouthSession.mat');
% % imgSets = imageSet(setDir,'recursive');
% load('OpenMouthSession.mat');
% imDir = fullfile('Z:\Windows.Documents\My Documents\applied robotics\image processing\2','OpenMouthSession.mat');
% addpath(imDir);
% 
% negativeFolder1 = fullfile('Z:\Windows.Documents\My Documents\applied robotics\image processing\2','CloseMouthSession.mat');
% negativeFolder2 = fullfile('Z:\Windows.Documents\My Documents\applied robotics\image processing\2','NullSession.mat');
% 
% trainCascadeObjectDetector('stopSignDetector_10stages.xml',data,negativeFolder1,'FalseAlarmRate',0.2,'NumCascadeStages',10);

% setDir  = fullfile(toolboxdir('vision'),'visiondata','imageSets');
% imgSets = imageSet(setDir,'recursive');
% 
% [trainingSets,testSets] = partition(imgSets,0.3,'randomize');

load('stopSigns.mat');
imDir = fullfile(matlabroot,'toolbox','vision','visiondata','stopSignImages');
addpath(imDir);

negativeFolder = fullfile(matlabroot,'toolbox','vision','visiondata','nonStopSigns');

trainCascadeObjectDetector('stopSignDetector.xml',data,negativeFolder,'FalseAlarmRate',0.2,'NumCascadeStages',5);

detector = vision.CascadeObjectDetector('stopSignDetector.xml');
img = imread('stopSignTest.jpg');
bbox = step(detector,img);

detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'stop sign');
figure;
imshow(detectedImg);
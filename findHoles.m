function [objectStats] = findHoles(I)
%Where I is an rgb image and 
%Objects is a list of hoels

I = rgb2gray(I);
%imshow(I)
thresholdValue = 35;
I = I > thresholdValue;
%imshow(I)
I = bwareaopen(I,600);
%imshow(I)
I = imcomplement(I);
I = bwareaopen(I,600);
%imshow(I)
labeled = bwlabel(I, 8);
%imshow(I)

% Here we do the image blob analysis.
%Get the region properties
stats = regionprops(labeled, 'Eccentricity', 'Area', 'BoundingBox', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
majorLengths = [stats.MajorAxisLength];
minorLengths = [stats.MinorAxisLength];
removeIdx = [];
for i = 1:length(stats)
    %If abnormally large, remove it. If abnormally small, remove it.
    if majorLengths(i) > 70  || majorLengths(i) < 10
        removeIdx(end+1) = i;
    end
    if minorLengths(i) > 70 || minorLengths(i) < 10
        removeIdx(end+1) = i;
    end
end
stats(removeIdx) = []; %removes indices
objectStats = stats;

end

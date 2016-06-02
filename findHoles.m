function [objectStats] = findHoles(I)
%Where I is an rgb image and 
%Objects is a list of hoels

I = rgb2gray(I);
%imshow(I)
thresholdValue = 50; %C1 = 40. C2 = 10
I = I > thresholdValue;
%imshow(I)
I = bwareaopen(I,200);
%imshow(I)
I = imcomplement(I);
I = bwareaopen(I,200);
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
    
    %If 
%     x1 = stats(i).Centroid(1);
%     y1 = stats(i).Centroid(2);
%     for j = 1:length(stats)
%         if i ~= j
%             x2 = stats(j).Centroid(1);
%             y2 = stats(j).Centroid(2);
%             %If abnormally large, remove it. If abnormally small, remove it.
%             distance = sqrt((x2-x1)^2+(y2-y1)^2);
%             if distance < 20 
%                 removeIdx(end+1) = j;
%                 removeIdx(end+1) = i;
%                 break
%             end
%         end
%     end
end
stats(removeIdx) = []; %removes indices
objectStats = stats;

end

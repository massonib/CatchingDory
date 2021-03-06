function [objectStats] = findFish(I, holeStats)
%Where I is an rgb image and 
%Objects is a list of fish

blue = I(:,:,3);
%imshow(blue)
blue = im2bw(blue, 0.6); %Camera 1 = 0.6, Competition = 0.9
%imshow(blue)
blue = bwareaopen(blue,700); 
%imshow(blue)
blue = imcomplement(blue);
%imshow(blue)
blue = bwareaopen(blue,700);
%imshow(blue)

% Label all the connected components in the image.
labeled = bwlabel(blue, 8);

% Here we do the image blob analysis.
%Get the region properties
stats = regionprops(labeled, 'Eccentricity', 'Area', 'BoundingBox', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
majorLengths = [stats.MajorAxisLength];
minorLengths = [stats.MinorAxisLength];
medianLength = median(majorLengths);
medianMinorLength = median(minorLengths );
removeIdx = [];
for i = 1:length(stats)
    %If abnormally large, remove it. If abnormally small, remove it.
    if majorLengths(i) > 65  || majorLengths(i) < 40
        removeIdx(end+1) = i;
    end
    if minorLengths(i) > 65  || minorLengths(i) < 40
        removeIdx(end+1) = i;
    end
end
stats(removeIdx) = []; %removes indices

%Remove any objects that have centroids close to the holes
removeIdx = [];
for i = 1:length(stats)
    x1 = stats(i).Centroid(1);
    y1 = stats(i).Centroid(2);
    
    for j = 1:length(holeStats)
        x2 = holeStats(j).Centroid(1);
        y2 = holeStats(j).Centroid(2);
        %If abnormally large, remove it. If abnormally small, remove it.
        distance = sqrt((x2-x1)^2+(y2-y1)^2);
        if distance < 30 
            removeIdx(end+1) = i;
            break
        end
    end
end
stats(removeIdx) = []; %removes indices

objectStats = stats;

end

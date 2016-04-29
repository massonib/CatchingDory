clear
clc
vid = videoinput('winvideo', 1, 'RGB24_640x480');

% src = getselectedsource(vid);
% src.FrameRate = '15.0000';

%Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorSpace','rgb')
vid.FrameGrabInterval = 5;

%start the video acquisition
start(vid);

% Set a loop that stop after 100 frames of aquisition
while(vid.FramesAcquired<=200)
    
    % Get the snapshot of the current frame
    data = getsnapshot(vid);
    
    % Now to track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
    diff_im = imsubtract(data(:,:,1), rgb2gray(data));
    %Use a median filter to filter out noise
    diff_im = medfilt2(diff_im, [3 3]);
    % Convert the resulting grayscale image into a binary image.
    diff_im = im2bw(diff_im,0.18);
    
    % Remove all those pixels less than 300px
    diff_im = bwareaopen(diff_im,300);
    
   % Label all the connected components in the image.
    labeled = bwlabel(diff_im, 8);

    % Here we do the image blob analysis.
    %Get the region properties
    stats = regionprops(labeled, 'Eccentricity', 'Area', 'BoundingBox', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
    areas = [stats.Area];
    majorLengths = [stats.MajorAxisLength];
    minorLengths = [stats.MinorAxisLength];
    medianLength = median(majorLengths);
    medianMinorLength = median(minorLengths );
    removeIdx = [];
    for i = 1:length(stats)
        %If abnormally large, remove it. If abnormally small, remove it.
        if majorLengths(i) > 1.5*medianLength  || areas(i) < medianLength/1.5
            removeIdx(end+1) = i;
        end
        if minorLengths(i) > 1.5*medianMinorLength  || minorLengths(i) < medianMinorLength/1.5
            removeIdx(end+1) = i;
        end
    end
    stats(removeIdx) = []; %removes indices

    % Display the image
    imshow(data)

    hold on

    %This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats)
        bb = stats(object).BoundingBox;
        bc = stats(object).Centroid;
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        plot(bc(1),bc(2), '-m+')
        a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
    end

    hold off
end

% Stop the video aquisition.
stop(vid);

% Flush all the image data stored in the memory buffer.
flushdata(vid);

delete(vid);


% % Now to track red objects in real time
%     % we have to subtract the red component 
%     % from the grayscale image to extract the red components in the image.
%     diff_im = imsubtract(data(:,:,1), rgb2gray(data));
%     %Use a median filter to filter out noise
%     diff_im = medfilt2(diff_im, [3 3]);
%     % Convert the resulting grayscale image into a binary image.
%     diff_im = im2bw(diff_im,0.18);
%     
%     % Remove all those pixels less than 300px
%     diff_im = bwareaopen(diff_im,300);

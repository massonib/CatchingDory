function resetRobot(arduino)

fwrite(arduino, '9'); %Send to 0.
% stopValue = 'Done';
% read = '';
% tic
% while strcmp(read, stopValue) == 0 && toc < 5 %While not the same (with a backup timer)
%     read = fscanf(arduino, '%s');
% end
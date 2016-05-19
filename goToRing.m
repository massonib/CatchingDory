function goToRing(arduino, value)

%Rings are numbered 1-4, which corresponds to their call function

fprintf(arduino, int2str(value)); %Send to 0.
% stopValue = 'Done';
% read = '';
% tic
% while strcmp(read, stopValue) == 0 && toc < 5 %While not the same (with a backup timer)
%     read = fscanf(arduino, '%s', 14);
% end
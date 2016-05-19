function dropOffFish(arduino)

fwrite(arduino, '6');
% value = 'Done';
% read = '';
% tic
% while strcmp(read, value) == 0 && toc < 10 %While not the same (with a backup timer)
%     read = fscanf(arduino, '%s', 14);
% end
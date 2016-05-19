function dropPole(arduino)

fwrite(arduino, '5');
% value = 'Done';
% read = '';
% tic
% while strcmp(read, value) == 0 && toc < 4 %While not the same (with a backup timer)
%     read = fscanf(arduino, '%s', 14);
% end
% clear
% clc
%  
% answer=5; % this is where we'll store the user's answer
arduino=serial('COM4','BaudRate',9600); % create serial communication object on port COM4
fopen(arduino); % initiate arduino communication

try
pause(5);
% value = '5';
%fprintf(arduino, '%s', value); % send answer variable content to arduino
fwrite(arduino, '9');
value = 'eached';
read = '';
tic
while strcmp(read, value) == 0 && toc < 5 %While not the same (with a backup timer)
    read = fscanf(arduino, '%s', 14);
end
%pause(4);
fwrite(arduino, '1');
% pause(2);
% fwrite(arduino, '5'); 
% pause(2);
% fwrite(arduino, '6');
% pause(10);
% fwrite(arduino, '9');
% pause(4);
% fwrite(arduino, '2');
% pause(2);
% fwrite(arduino, '5'); 
% pause(2);
% fwrite(arduino, '6');
% pause(10);
% fwrite(arduino, '9');
% pause(4);

fclose(arduino); 

catch me
    fclose(arduino); %Make absolutely sure this is closed
end
%delete(arduino);
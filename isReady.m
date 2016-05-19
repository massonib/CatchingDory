function currentStatus = isReady(arduino, oldStatus)      
%Checks on the current status of the Arudino. 1 = Ready. 0 = Busy.

%Empty out the current buffer and all new text
read = 'noByte';
while arduino.BytesAvailable > 0
    read = fscanf(arduino, '%s');
end

%Do not change the status if no bites were available
if strcmp(read, 'noByte') == 1
    currentStatus = oldStatus;
elseif strcmp(read, 'Busy') == 1
    currentStatus = 0;
%Check if last fscanf resulted in a 'Ready'
elseif strcmp(read, 'Ready') == 1 
   currentStatus = 1;            
end

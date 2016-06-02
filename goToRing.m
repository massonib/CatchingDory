function status = goToRing(arduino, value, status)

%Rings are numbered 1-4, which corresponds to their call function

fprintf(arduino, int2str(value));

%Wait till ready
status = isReady(arduino, status);
while status ~= 1 %If 'Ready' 
    pause(0.5)
    status = isReady(arduino, status);
end
pause(2); %Pause for 2 additional seconds
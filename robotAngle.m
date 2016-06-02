function str = robotAngle(theta)
if ((theta>-1.1) && (theta<=0))  
    theta_arduino= 1.1 + theta;
    flag=0;
end

if ((0<theta)&& (theta<pi))
    theta_arduino=1.1+theta;
    flag=1;
end

if ((-pi<theta) && (theta<-1.1))
  theta_arduino=2*pi+theta+1.1;
  flag=2;
end

if(theta==-1.1)
   theta_arduino=0;
end

if(theta==pi)
   theta_arduino=pi+1.1;
end

if(theta==-pi)
    theta_arduino=pi+1.1;
end

degrees = 180*theta_arduino/pi;

rounded = round(degrees);
if rounded < 10 
    str = int2str(rounded);
    str = strcat('00', str);
elseif rounded < 100 && rounded > 9
    str = int2str(rounded);
    str = strcat('0', str);
else 
    str = int2str(rounded);
end

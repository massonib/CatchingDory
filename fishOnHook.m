function [catchFish_flag, dropFish_flag] = fishOnHook(I, position)

x = position(1); width = position(3);
y = position(2); height = position(4);

I = im2bw(I,0.35);
imshow(I)
I = bwareaopen(I, 50);
%imshow(I)

White_pix=0;
Black_pix=0;
 for j=1:(width)-1
    for i=1:(height)-1
        if I(i,j)==1
            White_pix=White_pix+1;
        else
            Black_pix=Black_pix+1;
        end
    end
 end

 
 %For checking whether we catch the fish or not
 %flag=1 --> we are good! catch the fish

 if (White_pix<1500)
     catchFish_flag=1;
 else
     catchFish_flag=0;
 end
 
 
 %To check whether we drop the fish or not
 %flag=1 --> drop the fish completely
 
 if (White_pix>5000)
     dropFish_flag=1;
 else
     dropFish_flag=0;
 end
 
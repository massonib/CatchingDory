function isFishOnHook = fishOnHook(I, position)

x = position(1); width = position(3);
y = position(2); height = position(4);

imshow(I);
I = im2bw(I,0.20);%Set upper bound to Yellow Fish as Black
imshow(I);

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
 if (White_pix > 4000)
     isFishOnHook = 1;
 else
     isFishOnHook = 0;
 end
 
 
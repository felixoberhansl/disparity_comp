function [disp_left,disp_right,IL,IR] = calculateDisparityMap(IL,IR, ...
    max_image_size,max_disp_factor,window_size_factor,gauss_filt,outlier_compensation,median_filter)
%Inputs: IL,IR rectified color images
%        mode - either 'feat' or 'block' to choose the two different modes.
%               block seems to perform better
%Outputs: IL_resized,IR_resized images scaled to save processing power,
%         dispmap_left the disparity map from the left position

%%%%%%%%%%%%%%%%%%%%%%%%
%%Play with these for different results!
max_disp=max_disp_factor*max_image_size;
window_size=(window_size_factor*max_image_size*2)/2 +2;
num_clusters=25;
%%%%%%%%%%%%%%%%%%%%%%%%



%%preprocessing, gain and bias compensation has to be tested!

IL_prep=single(IL);
IR_prep=single(IR);
if(gauss_filt>0)
    IL_prep=imgaussfilt(IL_prep,gauss_filt);
    IR_prep=imgaussfilt(IR_prep,gauss_filt);
end

if(size(IL)~= size(IR))
    error('images must be the same size');
end

offset=round(0.1*size(IL_prep,2));
%add padding to the image so that all disp is positive
bm=zeros(size(IL_prep,1),offset,3,'uint8');
IL_prep=[bm IL_prep];
IR_prep=[IR_prep bm];


if(max(size(IL))>max_image_size)
    size_factor=max_image_size/max(size(IL));
    IL_prep=imresize(IL_prep,size_factor);
    IR_prep=imresize(IR_prep,size_factor);

    %save uncompensated images for output
end

%%end of preprocessing

        disp_left =stereomatch(IL_prep,IR_prep,window_size,max_disp,0);
        disp_right=stereomatch(fliplr(IR_prep),fliplr(IL_prep),window_size,max_disp,0);
        disp_right=fliplr(disp_right);

    %check for bad vals
    disp_left(disp_left>=max_disp)=max_disp;
    disp_left(disp_left<=-max_disp)=-max_disp;
    disp_right(disp_right>=max_disp)=max_disp;
    disp_right(disp_right<=-max_disp)=-max_disp;
    
    if(median_filter~=0)
        disp_left=medFilter(disp_left,median_filter);
        disp_right=medFilter(disp_right,median_filter);
    end

    %size back to original if needed
    if(size(IL,1)>max_image_size ||size(IL,2)>max_image_size)

        disp_left=imresize(disp_left,[size(IL,1),size(IL,2)+offset]);
        disp_right=imresize(disp_right,[size(IR,1),size(IR,2)+offset]);
        disp_left=disp_left*(1/size_factor);
        disp_right=disp_right*(1/size_factor);
        disp_left=int16(disp_left);
        disp_right=int16(disp_right);
    end
    %subtract padding
        disp_left=disp_left(:,(offset+1):end,:);
        disp_right=disp_right(:,1:size(IL,2),:);
        disp_left=disp_left-offset;
        disp_right=disp_right-offset;

    disp_left(rgb2gray(IL)==0)=0;
    disp_right(rgb2gray(IR)==0)=0;



    %outlier compensation
    if(outlier_compensation)
        disp_l_fill=imgaussfilt(disp_left,20);
        disp_r_fill=imgaussfilt(disp_right,20);
        a=quant(disp_left,0.05);
        b=quant(disp_left,0.95);
        disp_left(disp_left<a)=disp_l_fill(disp_left<a);
        disp_left(disp_left>b)=disp_l_fill(disp_left>b);
        a=quant(disp_right,0.05);
        b=quant(disp_right,0.95);
        disp_right(disp_right<a)=disp_r_fill(disp_right<a);
        disp_right(disp_right>b)=disp_r_fill(disp_right>b);
    end
    
    
end

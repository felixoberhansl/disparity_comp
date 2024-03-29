function [disp_left,disp_right] = calculateDisparityMap(IL,IR, ...
    max_image_size,max_disp_factor,window_size,gauss_filt,outlier_compensation,median_filter)
% Inputs: IL,IR: rectified color images
%         max_image_size: defines a max iamge size which is used to
%                         caclulate the resize factor (speed vs. accuracy)
%         max_disp_factor: defines the percentage of the image width which
%                          is used as max disparity
%         window_size: defines size of the search window
%         gauss_filt: if and with hich input gauss filtering (pre) is used
%         outlier_compensation: if outlier compensation (pre) is used
%         median_filter: if and with which input median filtering (post) is used
%
% Outputs: disp_left, disp_right: disparity maps from left and right point
%          of view

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%% input error checking
if(size(IL)~= size(IR))
    error('images must be the same size');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%% Initializing variables
max_disp = max_disp_factor*size(IL,2);                                      % max_disp := percentage of the image width

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%% pre-processing
IL_prep=single(IL);
IR_prep=single(IR);
if(gauss_filt>0)
    IL_prep=gaussfilt(IL_prep);
    IR_prep=gaussfilt(IR_prep);
end

% image resizing
if(max(size(IL))>max_image_size)
    size_factor=max_image_size/max(size(IL));
    IL_prep=imresize2(IL_prep,size_factor,size_factor);
    IR_prep=imresize2(IR_prep,size_factor,size_factor);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%% calculate disparity
disp_left =stereomatch(IL_prep,IR_prep,window_size,max_disp,0);
disp_right=stereomatch(fliplr(IR_prep),fliplr(IL_prep),window_size,max_disp,0);
disp_right=fliplr(disp_right);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%% post-processing
% check for bad values
disp_left(disp_left>=max_disp)=max_disp;
disp_left(disp_left<=-max_disp)=-max_disp;
disp_right(disp_right>=max_disp)=max_disp;
disp_right(disp_right<=-max_disp)=-max_disp;

% median filtering
if(median_filter~=0)
    disp_left=medFilter(disp_left,median_filter);
    disp_right=medFilter(disp_right,median_filter);
end

% size back to original
if(size(IL,1)>max_image_size ||size(IL,2)>max_image_size)
    disp_left=imresize2(disp_left,size(IL,1)/size(disp_left,1),(size(IL,2))/size(disp_left,2));
    disp_right=imresize2(disp_right,size(IR,1)/size(disp_right,1),(size(IR,2))/size(disp_right,2));
    disp_left=disp_left*(1/size_factor);
    disp_right=disp_right*(1/size_factor);
    disp_left=int16(disp_left);
    disp_right=int16(disp_right);
end

end

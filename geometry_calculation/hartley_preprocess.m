function [hartley_correspondences] = hartley_preprocess(correspondences, img1, img2)
    % This function translates the coordinates of the correspondences in a
    % fashion that allows a less noise-sensitve calculation of E or F
    % according to the paper "In the defense of the 8-point-algorithm by
    % Hartley
    
    hartley_correspondences = correspondences;
    
    % calculate new origins
    origin1 = [size(img1,1); size(img1,2)]./2;
    origin2 = [size(img2,1); size(img2,2)]./2;
    
    % translate all correspondences to new reference coordinate system
    hartley_correspondences(1:2,:) = hartley_correspondences(1:2,:) - repmat(origin1,1,size(correspondences,2));
    hartley_correspondences(3:4,:) = hartley_correspondences(3:4,:) - repmat(origin2,1,size(correspondences,2));

    
    % calculate isotropic scaling factors such that the avg correspondence 
    % point has a distance of sqrt(2) to centroid
    
    avg_point1 = [mean(hartley_correspondences(1,:)), mean(hartley_correspondences(2,:))];
    isotrop_scale1 = sqrt(2) / norm(avg_point1);    
    
    avg_point2 = [mean(hartley_correspondences(3,:)), mean(hartley_correspondences(4,:))];
    isotrop_scale2 = sqrt(2) / norm(avg_point2);
    
    hartley_correspondences(1:2,:) = hartley_correspondences(1:2,:) .* isotrop_scale1;
    hartley_correspondences(3:4,:) = hartley_correspondences(3:4,:) .* isotrop_scale2;
    

end
    
    
    
    
    
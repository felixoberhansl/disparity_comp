function [EF] = eightpointalgorithm(correspondences, K)
    % This function calculates the essential matrix or the fundamental matrix using the
    % Eight-Point-Algortihm, depending on whether the calibration matrix K
    % is given.

    % homogenize x1, x2
    x1 = [correspondences(1:2,:); ones(1, size(correspondences,2))];
    x2 = [correspondences(3:4,:); ones(1, size(correspondences,2))];
    
    % calibrate x1, x2 (if K is given)
    if (nargin>1)               
        x1 = (K^-1)*x1;              
        x2 = (K^-1)*x2;              
    end
    
    % calculate A
    for i = 1:size(correspondences,2)           
        A(i,:) = (kron(x1(:,i), x2(:,i))).';        % compute the Kronecker products
    end
    
    % V
    [~,~,V] = svd(A);
    
    %% estimate the matrices
    G = reshape(V(:,9), [3 3]);     % "unstack"
    [UG,SG,VG] = svd(G);
  
    if nargin>1         % K given -> essential matrix
        EF = UG * [1 0 0;0 1 0; 0 0 0] * VG.';
    else                % -> fundamental matrix
        SG(3,3) = 0;    % set 3. singular value to 0
        EF = UG * SG * VG.';
    end
end
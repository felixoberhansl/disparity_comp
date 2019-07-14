function filteredA = medFilter(A,n)
% This function implements Hybrid Median Filter, without using
% additional toolboxes

    A = uint8(A);

    if mod(n,2) == 0
        n = n+1;
    end
    
    n2 = ceil(n/2);
    
    % Plus & Cross masks
    Plus = zeros(n,n);
    Plus(uint8((n+1)/2),:) = 1;
    Plus(:,uint8((n+1)/2)) = 1;
    Plus(n2,n2)=0;
    Plus = uint8(Plus);

    Cross = zeros(n,n);
    Cross((1:n)+n*(0:n-1)) = 1;
    Cross((1:n)+n*((n-1):-1:0)) = 1;
    Cross(n2,n2)=0;
    Cross = uint8(Cross);
    
    filteredA = uint8(zeros(size(A,1), size(A,2)));
    
    roi = uint8(zeros(n,n));  

    for r = n2:size(A,1)-n2
        
        for c = n2:size(A,2)-n2
            
            roi = A((r-n2+1):(r+n2-1),(c-n2+1):(c+n2-1));
            
            filteredA(r,c) = median_calc([median_calc(roi(Plus~=0)); median_calc(roi(Cross~=0)); A(r,c)]);
            
            
        end
        
        
    end
    
end

function med = median_calc(A)


    if size(A,1) > 0

        A = sort(A);

        med = A(ceil(size(A,1)/2));
    else
        med = 0;
        
    end
    
end
    
   
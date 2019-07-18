function filteredA = medFilter(A,n)
% This function implements Hybrid Median Filter, without using
% additional toolboxes

    A = uint8(A);
    
    if mod(n,2) == 0
        n = n+1;
    end
    
    n2 = ceil(n/2);
    
    
    A_padded = zeros(size(A,1)+(n2-1)*2, size(A,2)+(n2-1)*2);

    A_padded(n2:size(A,1)+n2-1,n2:size(A,2)+n2-1) = A;

    
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
    
    r_padded = 0;
    c_padded = 0;

    for r = 1:size(A,1)
        
        for c = 1:size(A,2)
            
            r_padded = r + n2 -1;
            c_padded = c + n2 -1;
            
            roi = A_padded((r_padded-n2+1):(r_padded+n2-1),(c_padded-n2+1):(c_padded+n2-1));
            
            filteredA(r,c) = median_calc([median_calc(roi(Plus~=0)); median_calc(roi(Cross~=0)); A_padded(r_padded,c_padded)]);
            
            
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
    
   
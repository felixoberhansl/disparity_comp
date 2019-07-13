function p = verify_dmap(D,G)
% This function compares 2 calculations of a disparity map and returns the
% PSNR

    D = double(D);
    G = double(G);
    
    % check if matrices are normed to 0 ... 255
    if (all(D >= 0 & D <= 255, 'all') && all(G >= 0 & G <= 255, 'all'))
        
        if (size(D,1) == size(G,1)) && (size(D,2) == size(G,2)) 
        
            mse = (norm(D(:)-G(:),2).^2)/numel(D);
            
            p = 10*log10(255^2/mse); 
            
        else
            
            error("Matrices do not have the same size")
            
        end
        
        
    else
        error("Matrices are not normed to interval [0, 255]")
    end


end


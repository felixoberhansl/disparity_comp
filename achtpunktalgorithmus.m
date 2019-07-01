function [EF] = achtpunktalgorithmus(Korrespondenzen, K)
    % Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix
    % mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K'
    % vorliegt oder nicht

    x1 = [Korrespondenzen(1,:);Korrespondenzen(2,:);ones(1,size(Korrespondenzen,2))];
    x2 = [Korrespondenzen(3,:);Korrespondenzen(4,:);ones(1,size(Korrespondenzen,2))]; 
    
    % if K exists, calibrate
    point = zeros(3,1);
    if (exist('K','var'))
        
        for i = 1:size(Korrespondenzen,2)
            point = x1(:,i);
            point = K^-1 * point;            
            x1(:,i) = point;
            
            point = x2(:,i);
            point = K^-1 * point;            
            x2(:,i) = point;           
            
        end   
          
    end
    
    A = zeros(size(x1,2),9);
    
    for i = 1:size(A,1)
       A(i,:) = kron(x1(:,i),x2(:,i)); 
    end
    
    [U,sigma,V] = svd(A);
    
    
    
    
    %% Schaetzung der Matrizen
    G_stacked = V(:,9);
    
    G = zeros(3,3);
    G(:,1) = G_stacked(1:3);
    G(:,2) = G_stacked(4:6);
    G(:,3) = G_stacked(7:9);
    

    
    [U_G, sigma_G, V_G] = svd(G);
    
    if(exist('K','var'))
        % K exists, we can calculate the essential matrix
        
        % sigma_mean = ((sigma_G(1,1) + sigma_G(2,2)) / 2);
    
        sigma_G(1,1) = 1;
        sigma_G(2,2) = 1;
        sigma_G(3,3) = 0;
        
    else

        sigma_G(3,3) = 0;
        
    end
    
    EF = U_G * sigma_G * V_G';
    
    
    
end
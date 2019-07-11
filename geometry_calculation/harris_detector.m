function features = harris_detector(input_image)
    % This function implements the Harris-Detector to extract image
    % features
    %% set default values
    segment_length = 15;
    k = 0.05;
    tau = 10^6;
    min_dist = 20;
    tile_size = [200, 200];
    N = 5;
        
    %% Pre-Processing of the image
    % check if image is gray-scale
    if size(input_image,3) ~= 1
        error('Image format has to be NxMx1');
    end
    % convert to double
    dInputImage = double(input_image);
    % Approximate the image gradient
    [Fx, Fy] = sobel_xy(dInputImage);
    % computing weight vector
    w1 = [1:segment_length/2 + 1];
    w2 = [int16(segment_length/2 - 1):-1:1];
    w = [w1, w2];
    w_norm = double(w)/norm(double(w),1);
    % Harris Matrix G
    G11 = conv2(w_norm,w_norm.',(Fx .* Fx),'same');        % G11
    G12 = conv2(w_norm,w_norm.',(Fx .* Fy),'same');        % G12
    G21 = G12;                                             % G21
    G22 = conv2(w_norm,w_norm.',(Fy .* Fy),'same');        % G22
    
    %% Feature extraction
    H = G11.*G22 - G12.*G12 - k*((G11+G22).^2);                 % det(G) - k*(trace(G)^2)
    corners = (H > tau).*H;                                          % corner if H > threshold tau
    %[rowMerkmale, colMerkmale] = find(corners);
    %disp(corners);
    
    %% Post-Processing features
    % add zeroes to the edges
    corners = [zeros(size(corners,1),min_dist), corners, zeros(size(corners,1),min_dist)];
    corners = [zeros(min_dist,size(corners,2)); corners; zeros(min_dist,size(corners,2))];
    
    % sort features
    [~, sorted_index_withZeroNull] = sort(corners(:), 'descend');      % corners(:) -> stack matrix to vector
    sorted_index = sorted_index_withZeroNull(1:size(find(corners)));   % 1 : number of non-zeros
    
    %% Akkumulator
    iAnzTilesHeight = ceil(size(input_image,1)/tile_size(1,1));       % Anzahl Tiles in x(Width) und y(Height) Richtung
    iAnzTilesWidth  = ceil(size(input_image,2)/tile_size(1,2));       % tile_size nicht geeignet gewählt! aufrunden?!
    AKKA = zeros(iAnzTilesHeight, iAnzTilesWidth);
    if numel(AKKA)*N <=size(sorted_index,1)                          % max N Merkmale pro Kachel -> N*numel(AKKA)
        features = zeros(2,numel(AKKA)*N);                           % ausser in sorted_index sind schon weniger Elemente
    else                                                             % dann -> size(sorted_index,2)
        features = zeros(2,size(sorted_index,1));
    end
    
    %% extract features with the constraints: min_dist and max number of features for each tile
    [row_sorted_index,col_sorted_index] = ind2sub(size(corners),sorted_index);  % extract rows and cols of the sorted_index
    iNumFeatures = 0;                                                           
    iNumFeaturesMax = size(features, 2);                                         % depends on max number of features or tiles*N
    for i=1:size(sorted_index)
        row_AKKA = ceil((row_sorted_index(i)-min_dist)/tile_size(1));        
        col_AKKA = ceil((col_sorted_index(i)-min_dist)/tile_size(2));        
        if AKKA(row_AKKA,col_AKKA) < N                                       % check if max number of features in this tile is reached
            if corners(row_sorted_index(i), col_sorted_index(i)) ~= 0        % check if feature is outside min_dist
                AKKA(row_AKKA,col_AKKA) = AKKA(row_AKKA,col_AKKA) + 1;
                % extrat the part of the image which should be multplied
                % with the "cake"(min_dist to every direction)
                corners(row_sorted_index(i) - min_dist : row_sorted_index(i) + min_dist, col_sorted_index(i) - min_dist : col_sorted_index(i) + min_dist) = corners(row_sorted_index(i) - min_dist : row_sorted_index(i) + min_dist, col_sorted_index(i) - min_dist : col_sorted_index(i) + min_dist) .* cake(min_dist);
                iNumFeatures = iNumFeatures + 1;
                features(:,iNumFeatures) = [col_sorted_index(i)-min_dist; row_sorted_index(i)-min_dist];
                if iNumFeatures == iNumFeaturesMax
                   disp("max erreicht")
                   break                                                     % break, if max number of tiles is reached
                end
            end
        end
    end
    features(:, all(features == 0) ) = [];                                   % delete zeros
end

%-------------------------functions----------------------------------------
%--------------------------------------------------------------------------

function Cake = cake(min_dist)
    % This funciton creates a "cake-matrix" which contains circle of zeros
    % and fills the other parts of the matrix with ones. Can be used to
    % suppress features within the min distance.
    
    Cake = true(2*min_dist+1,2*min_dist+1);

    for i = 1:size(Cake,1)
        for j = 1:size(Cake,2)
            if (min_dist)^2 >= (i-(min_dist+1))^2+(j-(min_dist+1))^2
                Cake(i,j)=false;
            end
        end
    end
    
end
% based on:
% Master Thesis: Real-Time Stereo Vision     Wim Abbeloos    May 2010
% Karel de Grote-Hogeschool University College, Belgium

function [spdmap, dcost, pcost, wcost] = stereomatch(imgleft, imgright, windowsize, disparity, spacc)
% FAST MATLAB STEREO MATCHING ALGORITHM (SAD)
% Description: This function performs the computationally expensive step of
% matching two rectified and undistorted stereo images.  The output is a
% dense disparity map.

% Set Parameters
WS  = uint16(windowsize);               % Set window size, must be uneven
WS2 = uint16( ( WS - 1 ) / 2 );         % Half window
D   = uint16(disparity)+1;              % number of disparities

% Read image sizes
heightL = uint16( size( imgleft, 1 ) );    heightR = uint16( size( imgright, 1 ) );
widthL  = uint16( size( imgleft, 2 ) );    widthR  = uint16( size( imgright, 2 ) );
if ( heightL ~= heightR  ||  widthL ~= widthR )
    error('Height and width of left and right image must be equal');
end

% Initialization
pcost = zeros( heightL, widthL, D, 'uint8' );
wcost = zeros( heightL, widthL, D, 'single' );
dmap  = zeros( heightL, widthL, 'uint8' );
dcost = zeros( heightL, widthL, 'single' );
h = zeros(WS,WS,'double'); h(1,1) = 1; h(1,WS) = -1; h(WS,1) = -1; h(WS,WS) = 1;

% Calculate pixel cost
for Dc = 1 : D
    maxL = widthL + 1 - Dc;
    % probably not the fastest solution..?
    pcost(:, Dc : widthL, Dc ) = uint8(abs(int16(imgright( :, 1 : maxL)) - int16(imgleft( :, Dc : widthL))));
end

% Calculate integral cost
icost = single(pcost);
icost = cumsum( cumsum( icost ), 2 );

% Calculate window cost
% zero matrix -> add edges -> put icost in the middle -> fill up edges
icost_padded = zeros(size(icost,1)+2*WS2, size(icost,2)+2*WS2, size(icost,3));
for i = 1:size(icost,3)
    % zero matrix -> add edges -> put icost in the middle -> fill up edges
    icost_padded(WS2+1:end-WS2,WS2+1:end-WS2,i) = icost(:,:,i);
    %up
    icost_padded(1:WS2,WS2+1:end-WS2,i) = icost_padded(2*WS2:-1:WS2+1, WS2+1:end-WS2,i);
    %down
    icost_padded(end-WS2+1:end,WS2+1:end-WS2,i) = icost_padded(end-WS2:-1:end-2*WS2+1, WS2+1:end-WS2,i);
    %left
    icost_padded(WS2+1:end-WS2,1:WS2,i) = icost_padded(WS2+1:end-WS2,2*WS2:-1:WS2+1,i);
    %right
    icost_padded(WS2+1:end-WS2, end-WS2+1:end,i) = icost_padded(WS2+1:end-WS2,end-WS2:-1:end-2*WS2+1,i);
    %filtering
    wcost(:,:,i) = filter2(h, icost_padded(:,:,i), 'valid');
end


% Search disparity value
[ dcost(:,D+WS2:widthL), dmap(:,D+WS2:widthL)] = min( wcost(:,D+WS2:widthL,:),[], 3 );
for j=WS2+1:D+WS2
    [ dcost(:,j), dmap(:,j)] = min( wcost(:, j, 1 : (j - WS2) ),[], 3 );
end

% Adjust disparity map
warning off;
spdmap = single(dmap-1);

% Subpixel interpolation
if spacc==1
    for j=D+1:widthL
        for i=1:heightL
            if dmap(i,j)>1 && dmap(i,j)<D
                p = polyfit2((single(dmap(i,j)-2:dmap(i,j))),shiftdim(single(wcost(i,j,dmap(i,j)-1:dmap(i,j)+1)),1),2);
                temp=roots(p);
                spdmap(i,j)=real(temp(1));
            end
        end
    end
end

% needed because the algorithm sometimes puts out weird values
spdmap=int16(spdmap);

warning on;
end

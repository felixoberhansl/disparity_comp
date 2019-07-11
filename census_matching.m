function disparity_map = census_matching(img1, img2, tolerance_h, tolerance_w, censusframe_size)
    % This function maps pixels of stereo images using corresponding
    % geometry and census filtering


    width = size(img1,2);
    heigth = size(img1,1);
    
    disparity_map = zeros(heigth, width);
    
    censusframe_leftdown = zeros(2,1);
    censusframe_rightup = zeros(2,1);
    matchframe_leftdown = zeros(2,1);
    matchframe_rightup = zeros(2,1);

    for w = 1+censusframe_size:width-censusframe_size
        
        disp("Column: " + num2str(w) + " of " + num2str(width))
        
        for h = 1+censusframe_size: heigth-censusframe_size
            
            % extract census frame from image 1
            
            % calculate left bottom and right top coordinate of frame
            censusframe_leftdown = uint16([max(1,w - censusframe_size/2); min(heigth, h + censusframe_size/2)]);
            censusframe_rightup = uint16([min(width, w + censusframe_size/2); max(1, h - censusframe_size/2)]);
            
            % extract frame
            censusframe = img1(censusframe_rightup(2):censusframe_leftdown(2), censusframe_leftdown(1):censusframe_rightup(1));
            
            % CENSUS filtering, replace values with binary values
            % indicating if higher or lower intensity
            censusframe = censusframe > censusframe(round(censusframe_size/2), round(censusframe_size/2));
            
            
            
            % extract region to search for matching    
            h_min = max(1, h-tolerance_h);
            h_max = min(heigth, h+tolerance_h);
            
            
            % search region of interest for identical censusframe
            best_match_pixel = [0;0];
            best_match_val = inf;
            
            
            for roi_w = w:min(width-censusframe_size, w + tolerance_w)
                for roi_h = h_min:h_max
                    
                    % calculate left bottom and right top coordinate of frame
                    matchframe_leftdown = uint16([max(1,roi_w - censusframe_size/2); min(heigth, roi_h + censusframe_size/2)]);
                    matchframe_rightup = uint16([min(width, roi_w + censusframe_size/2); max(1, roi_h - censusframe_size/2)]);
                    
                    
                    % extract frame
                    matchframe = img2(matchframe_rightup(2):matchframe_leftdown(2), matchframe_leftdown(1):matchframe_rightup(1));
                    
                    % CENSUS filtering
                    matchframe = matchframe > matchframe(round(censusframe_size/2), round(censusframe_size/2));
                                        
                    % difference between frames
                    diff = (matchframe ~= censusframe);
                    
                    % save pixel with best CENSUS matching
                    current_match_val = sum(sum(diff));
                    if current_match_val <= best_match_val
                        
                        best_match_val = current_match_val;
                        best_match_pixel = [roi_h; roi_w];
                        
                    end                   
                    
                end                    
            end
                        
            disparity_map(h,w) = best_match_pixel(2) - w;           
            
        end
    end
    

    


end
function plot_correspondences(correspondences, img1, img2)
    % plot the correspondences, to check correctness
    
    figure
    subplot(1,2,1)
    imshow(img1)
    hold on
    
    for i = 1:size(correspondences,2)
        plot(correspondences(1,i), correspondences(2,i),'+','Color','green')        
    end
    
    hold off
    
    subplot(1,2,2)
    imshow(img2)
    hold on
    for i = 1:size(correspondences,2)
        plot(correspondences(3,i), correspondences(4,i),'+','Color','red')        
    end
    
    hold off
    
function plotCorrespondences(img1, img2, correspondences, title)

figure('Name',title)
imshow(img1)
hold on
imshow(img2)
alpha(0.5)       % transparency
plot(correspondences(1,:), correspondences(2,:), 'or')
plot(correspondences(3,:), correspondences(4,:), 'ob')

for i=1:size(correspondences,2)
    plot([correspondences(1,i), correspondences(3,i)], [correspondences(2,i), correspondences(4,i)], '-g')
end
hold off
end
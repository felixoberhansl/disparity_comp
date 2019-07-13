%Authors:   Christoph PREISINGER


function groundtruth = disparityshow (path)

    groundtruth=readpfm(path);
    figure(1)
    imshow(groundtruth, [])
    colormap('jet')
    colorbar

end
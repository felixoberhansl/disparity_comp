function rt = unittest(scene_path)
        save('path.mat','scene_path');
        result = runtests('test');
        rt = table(result);

% Source: https://de.mathworks.com/help/matlab/matlab_prog/write-script-based-unit-tests.html
end
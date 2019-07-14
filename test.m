classdef test < matlab.unittest.TestCase
    %Test your challenge solution here using matlab unit tests
        %% Test Method Block
    methods (Test)
            
            function check_toolboxes(testCase)
            [fList,pList] = matlab.codetools.requiredFilesAndProducts('challenge.m');
            UsedTB = {pList.Name};
                for k=1:length(UsedTB)
                    VarElements = cell2mat(UsedTB(k));
                    InuseTB = cell2mat(UsedTB);
                    assert(strcmp(VarElements,'MATLAB'), "Further toolboxes are inuse!"+ mat2str(InuseTB))
                end
            end
            %{
            function check_disparity_map(testCase)
            [fList,pList] = matlab.codetools.requiredFilesAndProducts('disparity_map.m');
            UsedTB = {pList.Name};
                for k=1:length(UsedTB)
                    VarElements = cell2mat(UsedTB(k));
                    assert(strcmp(VarElements,'MATLAB'), "Further toolboxes are inuse in disparity_map.m!"+ mat2str(InuseTB))
                end
            end
            
            function check_verify_dmap(testCase)
            [fList,pList] = matlab.codetools.requiredFilesAndProducts('verify_dmap.m');
            UsedTB = {pList.Name};
                for k=1:length(UsedTB)
                    VarElements = cell2mat(UsedTB(k));
                    assert(strcmp(VarElements,'MATLAB'), "Further toolboxes are inuse in verify_dmap.m!"+ mat2str(InuseTB))
                end
            end
            %}
            function check_variables(testCase)
                clear
                load('path.mat');
                challenge(scene_path);
                load('challenge.mat');
                Var = who;
                for k=1:length(Var)
                    VarElements = eval(cell2mat(Var(k)));   
                    if(iscell(VarElements))
                        VarElements = VarElements';
                        for i = 1:size(VarElements,1)
                            VarElement = cell2mat(VarElements(i));
                            assert(strcmp(convertCharsToStrings(VarElement),"") == 0, "Not all variables are set in file challenge.m!"+ mat2str(VarElement) ) 
                        end
                    elseif (ischar(VarElements) == 0)
                        VarElements = double(VarElements);
                        assert(norm(VarElements) > 0, "Not all variables are set in file challenge.m!"+ mat2str(VarElements) )
                        assert(isempty(VarElements) == 0, "Empty variable(s) in file challenge.m!"+ mat2str(VarElements) )

                    else
                      assert(strcmp(convertCharsToStrings(VarElements),"") == 0, "Not all variables are set in file challenge.m!"+ mat2str(VarElements) )    
                    end
                end
            end
            
            function check_psnr(testCase)
            load('challenge.mat');
            Result_IPTB = psnr(double(D),double(G));
            tol = 0; 
            assert(abs(p-Result_IPTB) <= 0, "Peak Signal-To-Noise Ratio (PNSR) out of tolerance! Difference is (dB): " + mat2str(abs(p-Result_IPTB)));
            end
         
           
    end
end


% test input

% Define an absolute tolerance

% preconditions



%% Test 1: check_toolboxes

[fList,pList] = matlab.codetools.requiredFilesAndProducts('test_calculateDisparityMap.m');
UsedTB = {pList.Name};
for k=1:length(UsedTB)
    VarElements = cell2mat(UsedTB(k));
    assert(strcmp(VarElements,'MATLAB'), "Further toolboxes are inuse in calculateDisparityMap.m!"+ mat2str(VarElements) )
end

%{
[fList,pList] = matlab.codetools.requiredFilesAndProducts('disparity_map.m');
UsedTB = {pList.Name};
for k=1:length(UsedTB)
    VarElements = cell2mat(UsedTB(k));
    assert(strcmp(VarElements,'MATLAB'), 'Further toolboxes are inuse in disparity_map.m!')
end


[fList,pList] = matlab.codetools.requiredFilesAndProducts('verify_dmap.m');
UsedTB = {pList.Name};
for k=1:length(UsedTB)
    VarElements = cell2mat(UsedTB(k));
    assert(strcmp(VarElements,'MATLAB'), 'Further toolboxes are inuse in verify_dmap.m!')
end


%% Test 2: check_variable
clear;
challenge
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

%% Test 3: check_psnr
challenge
Result = verify_dmap(D,G); 
Result_IPTB = psnr(D,G);
tol = 0; 
assert(abs(Result-Result_IPTB) <= tol, "Peak Signal-To-Noise Ratio (PNSR) out of tolerance! " + mat2str(abs(Result-Result_IPTB)));
%}
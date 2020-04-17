function fixDroppedTrialExperimentStructure(folderLoc)
% This function will fix a last dropped trial in a processed
% experimentStructure file. Will only fix window average fields.
% USE WITH CAUTION!!!!


load([folderLoc 'experimentStructure.mat']);

if range(experimentStructure.cndTotal) == 1
    cnd2Fix = find(experimentStructure.cndTotal < mode(experimentStructure.cndTotal));
    
    names = fieldnames(experimentStructure);
    
    for i = 1:length(names)
    matches(i) =  ~isempty(regexp(names{i}, regexptranslate('wildcard', 'dF*owAver*')));
    end
     
    matchesNum = find(matches);
    for x = 1:length(matchesNum)
        for cc = 1:experimentStructure.cellCount
        eval(['experimentStructure.' names{matchesNum(x)} '{1,' num2str(cc) '}{10,' num2str(cnd2Fix) '} =' ... 
            'mean(cell2mat(experimentStructure.' names{matchesNum(x)} '{1,' num2str(cc) '}(1:9,' num2str(cnd2Fix) ')));'])
        end
    end
    
end

save([folderLoc '\experimentStructure.mat'], 'experimentStructure');

end
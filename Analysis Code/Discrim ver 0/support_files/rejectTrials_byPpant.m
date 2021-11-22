% rejectTrials_byPpant;
badtrials=[];
if strcmp(subjID, 'ph01_2021-11-16-11-50') 
    badtrials = 81;
end



for itrial = badtrials
    % remove the identified trials from consideration in further analysis.
    HeadPos(itrial).isPrac=1;
    
end
% plotj1_wholetrialGrandAverage

% using the whole trial information (no gait-cycle splitting), plot
% the accumulated average head trajectory, location of all H, M, and FA

% cd ../Raw_Data
% datadir=pwd;
cd([datadir filesep 'ProcessedData'])

pfols = dir([pwd filesep '*summary_data.mat']);
nsubs= length(pfols);
% nPrac=[21,41,41,41];
%%
clf;
for ippant=1:length(pfols)
    %%
    
    cd([datadir filesep 'ProcessedData'])
    load(pfols(ippant).name);
    %%
    expindx= [HeadPos(:).isPrac];
    nprac= length(find(expindx>0));    
    %restrict Head Y data:
    HeadY = squeeze(Head_posmatrix(2,nprac:end,:));
    trial_ends=[];
    for it=1:size(HeadY,1)
    trial_ends = [trial_ends, find(HeadY(it,:)<1, 1 )];   
    end
    vecend= median(trial_ends); 
    HeadY= HeadY(:, 1:vecend);
    timevec = [0:vecend]/90; % Fs 
    %% compare to tOnsets in t summary:
    tOnsets_smry = [];
    tOnsets_Hit_smry = [];
    tOnsets_Miss_smry = [];
    tOnsets_FA_smry = [];
     % plot
    figure(1);clf;
    set(gcf, 'units' ,'normalized', 'position', [0 0 .5 .5]);
    
    for itrial = nprac:length(trial_TargetSummary)
        % plot head data this trial:
        plot(HeadPos(itrial).times, HeadPos(itrial).Y, 'color', 'k', 'linew', 1);
        hold on;
        ylabel('Head height')
        title(['Grand mean, nWalk(' num2str(nTrials) '), nTargs(' num2str(nTargs) ') -' ppant])
        
        
        % all onsets:
        tO = trial_TargetSummary(itrial).targOnsets;
        tOnsets_smry = [tOnsets_smry, tO'];
        % all FAs:
        tF= trial_TargetSummary(itrial).FalseAlarms;
        if iscell(tF)
            tF= cell2mat(tF);
        end
        
        tOnsets_FA_smry = [tOnsets_FA_smry, tF'];
        % split by Resp Class (correct and incorrect).
       
        hm = find( trial_TargetSummary(itrial).targRespCorrect);
        hits= tO(hm);
        tm =  find( trial_TargetSummary(itrial).targRespCorrect ==0);
        misses = tO(tm);
        
        tOnsets_Hit_smry = [tOnsets_Hit_smry, hits'];
        tOnsets_Miss_smry = [tOnsets_Miss_smry, misses'];
        
    end
    hold on;
    plot(timevec, nanmean(HeadY(:, 1:vecend),1), 'r')
    %remove "-1" this is a targ absent place holder.
    tOnsets_smry = tOnsets_smry(tOnsets_smry>0);
    tOnsets_Hit_smry = tOnsets_Hit_smry(tOnsets_Hit_smry>0);
    tOnsets_Miss_smry = tOnsets_Miss_smry(tOnsets_Miss_smry>0);
    tOnsets_FA_smry = tOnsets_FA_smry(tOnsets_FA_smry>0);
    
    nTrials = size(HeadY,1);
    nTargs = length(tOnsets_smry);
   
    
    yyaxis right
    %     hg=histogram(tOnsets_smry, 100);
    % Hits / Miss split
    hH= histogram(tOnsets_Hit_smry, 100, 'Facecolor', [.2 1 .2]); hold on;
    hM=histogram(tOnsets_Miss_smry, 100, 'FaceColor', [1, .2 .2], 'BinWidth', hH.BinWidth); hold on;
%     
%     if ~isempty(tOnsets_FA_smry)
% %     hFA= histogram(tOnsets_FA_smry, 100, 'FaceColor', 'b', 'BinWidth', hH.BinWidth); hold on;
%      legend([hH, hM, hFA], ...
%         {['Hit:' num2str(length(tOnsets_Hit_smry))],...
%         ['Miss: ' num2str(length(tOnsets_Miss_smry))],...
%         ['FA: ' num2str(length(tOnsets_FA_smry))]}, 'location', 'NorthWest')
%     else
          legend([hH, hM], ...
        {['Hit:' num2str(length(tOnsets_Hit_smry))],...
        ['Miss: ' num2str(length(tOnsets_Miss_smry))]},...
        'location', 'NorthWest')
%     end
    ylabel('Target count')
   
    set(gca, 'fontsize', 15)
    %%
    cd([datadir filesep 'Figures' filesep 'wholeTrial_summary'])
    
    print('-dpng', [subjID  ' whole trial summary'])
end
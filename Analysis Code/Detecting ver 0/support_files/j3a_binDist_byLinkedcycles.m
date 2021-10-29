% j3_binDist_bycycle
% here we will bin average distance (error), between
% target and hand, by the gait cycle points.

% to better visualuze error, we will concat 2 successive cycles.

% a little tricky, as gait cycle duration varies.

% First take: resample time vector of each gait to 100 points, then average across
% gaits.


% clear all; close all;
datadir = 'C:\Users\vrlab\Documents\Matt\Projects\Output\walking_Ver0';
cd([datadir filesep 'ProcessedData'])
pfols= dir([pwd  filesep '*raw.mat']);
nsubs= length(pfols);
Fs = 90;
Timevec = [1:500]*1/90;

resampSize = 200; % resample the gait cycle (DUAL CYCLE) to this many samps.
%%
for ippant = 1:nsubs
cd([datadir filesep 'ProcessedData'])    %%load data from import job.

load(pfols(ippant).name)
savename = pfols(ippant).name;
disp(['Preparing j3a ' savename]);

%% Gait extraction.
% Per trial, extract gait samples (trough to trough), normalize along x
% axis, and store various metrics.

TargetError_perTrialpergait_doubleGC =[];

for itrial=1:size(Head_posmatrix,2)
    
    trs = HeadPos(itrial).Y_gait_troughs;
    pks = HeadPos(itrial).Y_gait_peaks;
    
    % plot gaits overlayed;
    nSteps = length(pks) -2;
    tmpPos=  squeeze(Head_posmatrix(2,itrial,:));
    tmpErr = squeeze(Hand_Targ_dist(itrial,:));
    
    %preAllocate for easy storage
    gaitD=[]; %struct
%     [gaitHeadY, gaitErr]= deal(zeros(length(trs), resampSize)); % we will normalize the vector lengths.
    [gaitHeadY, gaitErr]= deal([]); % we will normalize the vector lengths.
    
    for igait=1:length(pks)-2
        
        % now using 2 steps!
        gaitsamps =[trs(igait):trs(igait+2)];
        % head Y data this gait:
        gaitDtmp = tmpPos(gaitsamps);
        
        % normalize height between 0 and 1
        gaitDtmp_n = rescale(gaitDtmp);
        
        %error (hand-targ) this gait:
        errtmp = tmpErr(gaitsamps);
        
        gaitD(igait).Head_Yraw = gaitDtmp;
        gaitD(igait).Head_Ynorm = gaitDtmp_n;
        gaitD(igait).Hand_Targ_err = errtmp;
        gaitD(igait).Head_Y_resampled = imresize(gaitDtmp_n', [1,resampSize]);
        gaitD(igait).Hand_Targ_err_resampled = imresize(errtmp, [1,resampSize]);
        
        %also store in matrix for easy handling:
        gaitHeadY(igait,:) = imresize(gaitDtmp_n', [1,resampSize]);
        gaitErr(igait,:) = imresize(errtmp, [1,resampSize]);
        
        
    end % gait in trial.
    TargetError_perTrialpergait_doubleGC(itrial).gaitError = gaitErr;
    TargetError_perTrialpergait_doubleGC(itrial).gaitHeadY= gaitHeadY;
    
    % save this gait info per trial in structure as well.
    HandPos(itrial).DUALgaitData = gaitD;
    
end %trial

%% for all trials, compute the average error and head pos per time point
ntrials = size(HeadPos,2);
% plot average error over gait cycle, first averaging within trials.
[PFX_err_doubleGC, PFX_headY_doubleGC]= deal(zeros(ntrials,resampSize));
[PFX_binnedVar_pertrialsteps_doubleGC]= deal(zeros(ntrials,18)); % also plot the binned variance
PFX_allsteps_Err_doubleGC=[];
stepCount=1;
for itrial= 1:size(TargetError_perTrialpergait_doubleGC,2)
    
    % omit first and last gaitcycle from each trial
    TrialD= TargetError_perTrialpergait_doubleGC(itrial).gaitError([2:(end-1)],:);
    TrialY= TargetError_perTrialpergait_doubleGC(itrial).gaitHeadY([2:(end-1)],:);
    
    PFX_err_doubleGC(itrial,:) = mean(TrialD,1);
    PFX_headY_doubleGC(itrial,:)= mean(TrialY,1);
    
    
    for ibin= 1:18
        idx = [1:10] + (ibin-1)*10;
        PFX_binnedVar_pertrialsteps_doubleGC(itrial, ibin) = mean(var(TrialD(:,idx))); % mean var across steps.
        
    end
    %may want to instead calculate variance across all steps in exp,
    %without sub averaging.
    
    PFX_allsteps_Err_doubleGC = [PFX_allsteps_Err_doubleGC; TrialD];
    
    
         %% debug, check first and last trial are missing;
%             clf;
%             allD=(squeeze(TargetError_perTrialpergait_doubleGC(itrial).gaitError));
%             for ig = 1:size(allD,1)
%             subplot(2, size(allD,1), ig);
%             plot(allD(ig,:));
%             end
%             for ig2=1:size(TrialD,1)
%             subplot(2,size(allD,1), ig2+ig);
%             plot(TrialD(ig2,:));
%             end
        
    
end % trial

%calculate binned variance across entire experiment.
PFX_binnedVar_allsteps_doubleGC=[];
for ibin= 1:18
    idx = [1:10] + (ibin-1)*10;
    tmp = PFX_allsteps_Err_doubleGC(:,idx);
    PFX_binnedVar_allsteps_doubleGC(ibin) = mean(var(tmp));
end
%% visualize ppant error (debugging)
clf
plot(mean(PFX_headY_doubleGC,1))
hold on;
yyaxis right
plot(mean(PFX_err_doubleGC,1));


%%
save(savename, 'HandPos', 'TargetError_perTrialpergait_doubleGC',...
    'PFX_err_doubleGC', 'PFX_headY_doubleGC', 'PFX_allsteps_Err_doubleGC',...
    'PFX_binnedVar_pertrialsteps_doubleGC', 'PFX_binnedVar_allsteps_doubleGC', '-append');
end % subject


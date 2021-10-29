% j3_binDist_bycycle
% here we will bin trial information into gait cycles.

% a little tricky, as gait cycle duration varies.

% First take: resample time vector of each gait to 100 points, for alignment across
% gaits.


% clear all; close all;
datadir = 'C:\Users\vrlab\Documents\Matt\Projects\Output\walking_Ver1_Detect';
cd([datadir filesep 'ProcessedData'])
pfols= dir([pwd  filesep '*Frame_raw.mat']);
nsubs= length(pfols);
Fs = 90;
Timevec = [1:150]*1/90;
%%
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name);
    savename = pfols(ippant).name;
    disp(['Preparing j3 ' savename]);
    
    %% Gait extraction.
    % Per trial, extract gait samples (trough to trough), normalize along x
    % axis, and store various metrics.
    
    Data_perTrialpergait =[];
    
    for itrial=1:size(Head_posmatrix,2)
        
        trs = HeadPos(itrial).Y_gait_troughs;
        pks = HeadPos(itrial).Y_gait_peaks;
        
        % plot gaits overlayed;
        nSteps = length(pks) -2;
        tmpPos=  squeeze(Head_posmatrix(2,itrial,:));
%         tmpErr = squeeze(Hand_Targ_dist(itrial,:));
        
        %preAllocate for easy storage
        gaitD=[]; %struct
        [gaitHeadY, gaitErr]= deal(zeros(length(pks), 100)); % we will normalize the vector lengths.
        
        for igait=1:length(pks)
            gaitsamps =[trs(igait):trs(igait+1)];
            % head Y data this gait:
            gaitDtmp = tmpPos(gaitsamps);
            
            % normalize height between 0 and 1
            gaitDtmp_n = rescale(gaitDtmp);

            
            % record t onset, and click this gait:
            
%             %error (hand-targ) this gait:
%             errtmp = tmpErr(gaitsamps);
            
            gaitD(igait).Head_Yraw = gaitDtmp;
            gaitD(igait).Head_Ynorm = gaitDtmp_n;
            gaitD(igait).Hand_Targ_err = errtmp;
            gaitD(igait).Head_Y_resampled = imresize(gaitDtmp_n', [1,100]);
            gaitD(igait).Hand_Targ_err_resampled = imresize(errtmp, [1,100]);
            
            %also store in matrix for easy handling:
            gaitHeadY(igait,:) = imresize(gaitDtmp_n', [1,100]);
            gaitErr(igait,:) = imresize(errtmp, [1,100]);
            
            %height
            gaitD(igait).tr2pk = tmpPos(pks(igait)) - tmpPos(trs(igait));
            gaitD(igait).pk2tr = tmpPos(pks(igait)) - tmpPos(trs(igait+1));
            
            %dist
            gaitD(igait).tr2pk_dur = length(trs(igait):pks(igait));
            gaitD(igait).pk2tr_dur = length(pks(igait):trs(igait+1));
            
            %height ./ dist
            risespeed = tmpPos(pks(igait)) - tmpPos(trs(igait)) / length(trs(igait):pks(igait));
            fallspeed = tmpPos(pks(igait)) - tmpPos(trs(igait+1)) / length(pks(igait):trs(igait+1));
            
            gaitD(igait).risespeed = risespeed;
            gaitD(igait).fallspeed = fallspeed;
            %compute prominence? height from peak to interp line between troughs?
            
        end % gait in trial.
        Data_perTrialpergait(itrial).gaitError = gaitErr;
        Data_perTrialpergait(itrial).gaitHeadY= gaitHeadY;
        
        % save this gait info per trial in structure as well.
        HandPos(itrial).gaitData = gaitD;
        
    end %trial
    
    %% for all trials, compute the average error and head pos per time point
    ntrials = size(HeadPos,2);
    % plot average error over gait cycle, first averaging within trials.
    [PFX_err, PFX_headY]= deal(zeros(ntrials,100));
    [PFX_binnedVar_pertrialsteps]= deal(zeros(ntrials,9)); % also plot the binned variance
    PFX_allsteps_Err=[];
    stepCount=1;
    for itrial= 1:size(Data_perTrialpergait,2)
        
        % omit first and last gaitcycle from each trial
        TrialD= Data_perTrialpergait(itrial).gaitError([2:(end-1)],:);
        TrialY= Data_perTrialpergait(itrial).gaitHeadY([2:(end-1)],:);
        
        PFX_err(itrial,:) = mean(TrialD,1);
        PFX_headY(itrial,:)= mean(TrialY,1);
        
        
        for ibin= 1:9
            idx = [1:10] + (ibin-1)*10;
            PFX_binnedVar_pertrialsteps(itrial, ibin) = mean(var(TrialD(:,idx))); % mean var across steps.
            
        end
        %may want to instead calculate variance across all steps in exp,
        %without sub averaging.
        
        PFX_allsteps_Err = [PFX_allsteps_Err; TrialD];
        
        %     %% debug, check first and last trial are missing;
        %     clf;
        %     allD=(squeeze(TargetError_perTrialpergait(itrial).gaitError));
        %     for ig = 1:size(allD,1)
        %     subplot(2, size(allD,1), ig);
        %     plot(squeeze(TargetError_perTrialpergait(itrial).gaitError(ig,:)));
        %     end
        %     for ig2=1:size(TrialD,1)
        %     subplot(2,size(allD,1), ig2+ig);
        %     plot(TrialD(ig2,:));
        %     end
        
        
    end % trial
    
    %calculate binned variance across entire experiment.
    PFX_binnedVar_allsteps=[];
    for ibin= 1:9
        idx = [1:10] + (ibin-1)*10;
        tmp = PFX_allsteps_Err(:,idx);
        PFX_binnedVar_allsteps(ibin) = mean(var(tmp));
    end
    %% visualize ppant error (debugging)
    % clf
    % plot(mean(PFX_err,1));
    % yyaxis right
    % xvec = linspace(1,100,9);
    % plot(xvec, mean(PFX_binnedVar,1), 'k');
    % hold on;
    % plot(xvec, PFX_binnedVartotal);
    %%
    save(savename, 'HandPos', 'TargetError_perTrialpergait',...
        'PFX_err', 'PFX_headY', 'PFX_allsteps_Err',...
        'PFX_binnedVar_pertrialsteps', 'PFX_binnedVar_allsteps', '-append');
end % subject


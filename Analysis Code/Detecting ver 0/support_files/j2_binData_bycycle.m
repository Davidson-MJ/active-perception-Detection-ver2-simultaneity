% j2_binData_bycycle
% here we will bin trial information into gait cycles.

% a little tricky, as gait cycle duration varies.

% First take: resample time vector of each gait to 100 points, for alignment across
% gaits.


% clear all; close all;
datadir = 'C:\Users\vrlab\Documents\Matt\Projects\Output\walking_Ver1_Detect';
cd([datadir filesep 'ProcessedData'])
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);
nPrac=41; % 40 practice trials.
%%
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name);
    savename = pfols(ippant).name;
    disp(['Preparing j2 cycle data... ' savename]);
    
    %% Gait extraction.
    % Per trial, extract gait samples (trough to trough), normalize along x
    % axis, and store various metrics.
    
    Data_perTrialpergait =[];
    % adjust summary data, to make sure it matches
   summaryInfoIDs = [trial_TargetSummary(:).trialID]+1; % unity @ 0
   
 
    for itrial=nPrac:size(Head_posmatrix,2)
        targCount = 1;  % increment targets to collect correct info from summary.
       
        trs = HeadPos(itrial).Y_gait_troughs;
        pks = HeadPos(itrial).Y_gait_peaks;
        
        % plot gaits overlayed;
        nSteps = length(pks) -2;
        % Head position data:
        tmpPos=  squeeze(Head_posmatrix(2,itrial,:));
        % targ onset and click (RT) data:
        tmpTarg = squeeze(TargClickmatrix(1,itrial,:))';
        tmpClick = squeeze(TargClickmatrix(2,itrial,:))';
        
        %preAllocate for easy storage
        gaitD=[]; %struct
        [gaitHeadY, gaitTarg]= deal(zeros(length(pks), 100)); % we will normalize the vector lengths.
        
        for igait=1:length(pks)
            gaitsamps =[trs(igait):trs(igait+1)];
            gaitTimes = avTime(itrial,gaitsamps);
            % head Y data this gait:
            gaitDtmp = tmpPos(gaitsamps);
            
            % normalize height between 0 and 1
            gaitDtmp_n = rescale(gaitDtmp);
    
            
            % was there a target onset in this gait?  
            gaitTargtmp = zeros(1,100);
            
            targDtmp = tmpTarg(gaitsamps); 
            tO = find(targDtmp,1);
            
            [tRT,wasDetected]=deal(nan); % updated below.
            
            if ~isempty(tO) % target Onset occurred:
                
                % preserve percnt position of the gait cycle:
               gPcnt = round(tO/length(gaitsamps)*100);
               gaitTargtmp(gPcnt)=1; %store in resized vector.
              
               % find how long until next RT, if within response bounds.
               
               tOns = gaitsamps(tO);
               time_Onset = avTime(itrial, tOns);
               clickAt = find(tmpClick(tOns:end) > 0);
               % RT = clickAt - tOns;
               if~isempty(clickAt)
                   wasDetected=1;
                   time_Response = avTime(itrial,tOns+clickAt);
                   tRT = time_Response- time_Onset;
               else
                   wasDetected=0;
                   time_Response=nan;
                   tRT=nan;
               end
               
            end 
               
               % store data in matrix for easy handling:
            gaitHeadY(igait,:) = imresize(gaitDtmp_n', [1,100]);
            gaitTarg(igait,:) = gaitTargtmp;
            
            %also store head Y info:
            gaitD(igait).Head_Yraw = gaitDtmp;
            gaitD(igait).Head_Ynorm = gaitDtmp_n;
            gaitD(igait).Head_Y_resampled = imresize(gaitDtmp_n', [1,100]);
            gaitD(igait).gaitsamps = gaitsamps;
            gaitD(igait).tOnset_inTrialidnx = tOns;
            gaitD(igait).tOnset_inGait = tO;
            gaitD(igait).tOnset_inGaitResampled = gPcnt;
            gaitD(igait).wasDetected = wasDetected;
            gaitD(igait).tRT = tRT;
            
            % other cycle info:
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
        Data_perTrialpergait(itrial).gaitTarg = gaitTarg;
        Data_perTrialpergait(itrial).gaitHeadY= gaitHeadY;
        Data_perTrialpergait(itrial).gaitTargs_detected = [gaitD(:).wasDetected];
        
        % save this gait info per trial in structure as well.
        HeadPos(itrial).gaitData = gaitD;
        
    end %trial
    
    %% for all trials, compute the head pos per time point, and stacked Hits vs Misses.
    ntrials = length([nPrac:size(HeadPos,2)]);
    [PFX_headY, PFX_tOnsets, PFX_tHits, PFX_tMiss]= deal(zeros(ntrials,100));
    
    stepCount=1;
    Hit_count=1;
    Miss_count=1;
    for itrial= nPrac:size(Data_perTrialpergait,2)
        
        % omit first and last gaitcycle from each trial
        TrialD= Data_perTrialpergait(itrial).gaitTarg([2:(end-1)],:);
        TrialY= Data_perTrialpergait(itrial).gaitHeadY([2:(end-1)],:);
        
        PFX_tOnsets(itrial,:) = sum(TrialD,1);
        PFX_headY(itrial,:)= mean(TrialY,1);
        
        % also sort into H and misses:
         trialDetected = Data_perTrialpergait(itrial).gaitTargs_detected([2:(end-1)]);
        for it=1:size(TrialD,1)
            if trialDetected(it)==1
               PFX_tHits(Hit_count,:) = TrialD(it,:);
               Hit_count=Hit_count+1;
            elseif trialDetected(it)==0
                  PFX_tMiss(Miss_count,:) = TrialD(it,:);
               Miss_count=Miss_count+1;
            end
                
        end
%      
    end % trial
    %% sanity check plot:
%     %
    clf
    plot(mean(PFX_headY));
    hold on;
    % convert count for histogram plots:
    dataIN=[];
    dataIN(1).d = PFX_tHits;
    dataIN(2).d = PFX_tMiss;
    cols = {'g', 'r'};
    for itype=1:2
        
        sampSum = sum(dataIN(itype).d,1);
        hist_Data=[];
        for id=1:100
            if sampSum(id)>0
                tmp = repmat(id, 1, sampSum(id));
                hist_Data =[ hist_Data, tmp];
            end
        end
        yyaxis right
        histogram(hist_Data, 100, 'FaceColor', cols{itype});
        
    end
%%
    %%
    save(savename, 'HeadPos', 'Data_perTrialpergait',...
        'PFX_headY', 'PFX_tOnsets',...
        'PFX_tHits', 'PFX_tMiss', '-append');
end % subject


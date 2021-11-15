% j2_binData_bycycle
% here we will bin trial information into gait cycles.

% a little tricky, as gait cycle duration varies.

% First take: resample time vector of each gait to 100 points, for alignment across
% gaits.
cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);


% nPractrials=[20,40,40,40]; %?
%%
for ippant = 3%3:4%1:nsubs
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
   
 
    for itrial=1:size(Head_posmatrix,2)
        if HeadPos(itrial).isPrac
            continue
        end
        targCount = 1;  % increment targets to collect correct info from summary.
       
        trs = HeadPos(itrial).Y_gait_troughs;
        pks = HeadPos(itrial).Y_gait_peaks;
        
        % plot gaits overlayed;
        nSteps = length(pks) -2;
        % Head position data:
        tmpPos=  squeeze(HeadPos(itrial).Y);
        % targ onset and click (RT) data:
        tmpTarg = squeeze(TargState(itrial).state);
        tmpClick = squeeze(clickState(itrial).state);
        
      % what trial type?
       targsPresented = max(tmpTarg);
        %preAllocate for easy storage
        gaitD=[]; %struct
        [gaitHeadY, gaitTarg]= deal(zeros(length(pks), 100)); % we will normalize the vector lengths.
        
        %summary info for comparison:
        tOns_sumry= trial_TargetSummary(itrial).targOnsets;
        tTypes_sumry= trial_TargetSummary(itrial).targTypes;
        tCor_sumry = trial_TargetSummary(itrial).targRespCorrect;
        tClickOns_smry= trial_TargetSummary(itrial).clickOnsets;
        tRTs_sumry = trial_TargetSummary(itrial).targRTs;
        
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
               
               %using summary data:
               targIDX_insummary = dsearchn([tOns_sumry], [time_Onset]');
               targTypewas = tTypes_sumry(targIDX_insummary);
               clickAt = tClickOns_smry(targIDX_insummary);
               time_Response = tRTs_sumry(targIDX_insummary);
               respWasCorrect = tCor_sumry(targIDX_insummary);
              
               %also dummy classiy
               %  1= 1flash correct)
               %  2 = 2flash correct
               %  3 = 1flash incorrect
               %  4 = 2flash incorrect
               %  0 = no resp
               if ~isnan(respWasCorrect)
                   if respWasCorrect
                       targRespClass = targTypewas;
                   else 
                       targRespClass = targTypewas+2;
                   end
               else 
                   targRespClass= 0;
               end
               %store
               
               
               gaitD(igait).tOnset_inTrialidnx = tOns;
               gaitD(igait).tOnset_inGait = tO;
               gaitD(igait).tOnset_inGaitResampled = gPcnt;
               gaitD(igait).tType= targTypewas;
               gaitD(igait).tRT = time_Response;
               gaitD(igait).tRespCorr = respWasCorrect;
               gaitD(igait).tRespClass = targRespClass;
               
            else 
                % useful for aligning response classes to correct gaits (below)
                gaitD(igait).tRespClass= nan; 
            end
               % store data in matrix for easy handling:
            gaitHeadY(igait,:) = imresize(gaitDtmp_n', [1,100]);
            gaitTarg(igait,:) = gaitTargtmp;
            
            %also store head Y info:
            gaitD(igait).Head_Yraw = gaitDtmp;
            gaitD(igait).Head_Ynorm = gaitDtmp_n;
            gaitD(igait).Head_Y_resampled = imresize(gaitDtmp_n', [1,100]);
            gaitD(igait).gaitsamps = gaitsamps;
           
            
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
            
            
            
        end % gait in trial.
        trial_TargetSummary(itrial).gaitTarg = gaitTarg;
        trial_TargetSummary(itrial).gaitHeadY= gaitHeadY;
       
        if targsPresented
        trial_TargetSummary(itrial).gaitTargs_detected = [gaitD(:).tRespClass];
        end
        % save this gait info per trial in structure as well.
        HeadPos(itrial).gaitData = gaitD;
        trial_TargetSummary(itrial).gaitData = gaitD;
        
    end %trial
    
    %% for all trials, compute the head pos per time point, and stacked targ Response class,
    % 0, 1, 2, 3, 4  = no resp, correct 1, 2, and incorrect 1 ,2 flashes.
    expindx= [HeadPos(:).isPrac];
    nprac= length(find(expindx>0));
    
    ntrials = size(HeadPos,2)-nprac;
    [PFX_headY, PFX_tOnsets, PFX_tHits_1flash, ...
        PFX_tHits_2flash, PFX_tMiss_1flash, ...
        PFX_tMiss_2flash, PFX_tNoresp]= deal(zeros(ntrials,100));
    
    [h1count, h2count, m1count, m2count, norespcount]=deal(1);
   
    for itrial= 1:size(trial_TargetSummary,2)
        if HeadPos(itrial).isPrac
            continue
        end
       tmp=trial_TargetSummary(itrial).gaitTarg; % nGaits
       nGaits = size(tmp,1);
       allgaits = 1:nGaits;
       % omit first and last gaitcycles from each trial
       usegaits = allgaits;%(3:(end-2));
        
       %data of interest is the resampled gait (1:100) with a position of
       %the targ (now classified as correct or no).
        TrialD= trial_TargetSummary(itrial).gaitTarg(usegaits,:); 
        TrialY= trial_TargetSummary(itrial).gaitHeadY(usegaits,:);
        
        PFX_tOnsets(itrial,:) = sum(TrialD,1);
        PFX_headY(itrial,:)= mean(TrialY,1);
        
        if max(TrialD(:))% if we had targets presented in any gaits:
        % also store by target classificaton, across all gaits:
         trialDetected = trial_TargetSummary(itrial).gaitTargs_detected(usegaits);
        for igait=1:length(trialDetected)
           
            if ~isnan(trialDetected(igait)) %nans were no resp required (no targ presented).
                switch trialDetected(igait)
                    case 1
                        PFX_tHits_1flash(h1count,:) = TrialD(igait,:);
                        h1count=h1count+1;
                    case 2
                        PFX_tHits_2flash(h2count,:) = TrialD(igait,:);
                        h2count=h2count+1;
                    case 3
                        PFX_tMiss_1flash(m1count,:) = TrialD(igait,:);
                        m1count=m1count+1;
                    case 4
                        PFX_tMiss_2flash(m2count,:) = TrialD(igait,:);
                        m2count=m2count+1;
                    case 0
                        PFX_tNoresp(norespcount,:) = TrialD(igait,:);
                        norespcount=norespcount+1;
                end
                
            end 
                
                
        end % all gaits
        end % targ present trial
    end % all trials
  
    allts= norespcount+m2count+m1count+h2count+h1count;
    % check we aren't missing data:
    disp([' ALl targs recorded for participant' num2str(ippant) '=' num2str(allts)]);
    save(savename, 'HeadPos', 'trial_TargetSummary',...
        'PFX_headY', 'PFX_tOnsets',...
       'PFX_tHits_1flash',...
        'PFX_tHits_2flash',...
         'PFX_tMiss_1flash', ...
        'PFX_tMiss_2flash', 'PFX_tNoresp','-append');
end % subject


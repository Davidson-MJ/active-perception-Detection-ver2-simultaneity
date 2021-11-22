% j3_binDist_bycycle - discim version (1 or 2 flash).
%
% here we will bin trial information into consecutive (2) gait cycles.

% a little tricky, as gait cycle duration varies.

% to better visualuze error, we will concat 2 successive cycles.

% First take: resample time vector of each gait to 100 points, then average across
% gaits.


% clear all; close all;
%% %%%% %% SIMULTANEITY

datadir= 'C:\Users\User\Documents\matt\GitHub\active-perception-Detection-ver2-simultaneity\Analysis Code\Discrim ver 0\Raw_data';

cd([datadir filesep 'ProcessedData'])
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);

resampSize = 200; % resample the gait cycle (DUAL CYCLE) to this many samps.
%%
for ippant = 1:nsubs
cd([datadir filesep 'ProcessedData'])    %%load data from import job.

load(pfols(ippant).name)
savename = pfols(ippant).name;
disp(['Preparing j3 linked GCs ' savename]);

%% Gait extraction.
% Per trial, extract gait samples (trough to trough), normalize along x
% axis, and store various metrics.


   
    Data_perTrialpergait_doubleGC =[];
    
    rtcounter=1;
    gaitRTs_doubGC= []; % will be gPcnt , RT, H/M

for itrial=1:size(HeadPos,2)
    if HeadPos(itrial).isPrac
            continue
    end
    targCount = 1;  % increment targets to collect correct info from summary.
    trs = HeadPos(itrial).Y_gait_troughs;
    pks = HeadPos(itrial).Y_gait_peaks;
    
    % plot gaits overlayed;
    nSteps = length(pks) -2;
    tmpPos=  squeeze(Head_posmatrix(2,itrial,:));
    % targ onset and click (RT) data:
    tmpTarg = squeeze(TargState(itrial).state);
    tmpClick = squeeze(clickState(itrial).state);
    
    
    
    % what trial type?
    targsPresented = max(tmpTarg);
    %preAllocate for easy storage
    gaitD=[]; %struct
    [gaitHeadY, gaitTarg, gaitTarg_class]= deal(zeros(length(pks)-2, 200)); % we will normalize the vector lengths.
    
    %summary info for comparison:
    tOns_sumry= trial_TargetSummary(itrial).targOnsets;
    tTypes_sumry= trial_TargetSummary(itrial).targTypes;
    tCor_sumry = trial_TargetSummary(itrial).targRespCorrect;
    tClickOns_smry= trial_TargetSummary(itrial).clickOnsets;
    tRTs_sumry = trial_TargetSummary(itrial).targRTs;
    
    for igait=1:length(pks)-2
        
        % now using 2 steps!
        gaitsamps =[trs(igait):trs(igait+2)];
        gaitTimes = avTime(itrial,gaitsamps);

        % head Y data this gait:
        gaitDtmp = tmpPos(gaitsamps);
        
        % normalize height between 0 and 1
        gaitDtmp_n = rescale(gaitDtmp);
        
            % was there a target onset in this gait?  
            gaitTarg_vector = zeros(1,200);
            
            % similar to gaittargtmp, place the target position, and dummy classifcaiton
            %in rescaled vector
                gaitTarg_classvector= zeros(1,200); 
                
            targDtmp = tmpTarg(gaitsamps); 
            tO = find(targDtmp==1);
            
            [tRT,wasDetected]=deal(nan); % updated below.
            
            if ~isempty(tO) % target Onset occurred:
                
                % any extra targs captured?
                if any(diff(tO)>10)
                    %                 error('check')
                    % multiple targets within double GC:
                    % find onset of 2nd / 3rd target:
                    idx= find(diff(tO)>10) +1;
                    tO = [tO(1), tO(idx)'];
                    
                else
                    tO=tO(1);
                end
                % prepare to collate data across multiple targets:                
                [gPcnt_all,... % pcnt of gait cycle targ appears.
                    tOns_all,... % onset within gait
                 targTypewas_all,... % 1 or 2 flashes
                 time_Response_all,... % RT
                 respWasCorrect_all]...%0 or 1;                
                    = deal(zeros(length(tO),1)); % resp class dummy coded.
                
               
                
             for itarg=1:length(tO)
                % use first target:
                tOnow = tO(itarg);
                
                 % preserve percnt position of the gait cycle:
               gPcnt = round((tOnow/length(gaitsamps))*200);
%                disp(['Targ pcnt at ' num2str(gPcnt)]);
               gaitTarg_vector(gPcnt)=1; %store in resized vector.
               
               gPcnt_all(itarg)= gPcnt;
               % find how long until next RT, if within response bounds.               
               tOns_all(itarg) = gaitsamps(tOnow);
               time_Onset = avTime(itrial, tOns_all(itarg));
               
               %using summary data:
               targIDX_insummary = dsearchn([tOns_sumry], [time_Onset]');
               targTypewas_all(itarg) = tTypes_sumry(targIDX_insummary);           
               time_Response_all(itarg) = tRTs_sumry(targIDX_insummary);
               respWasCorrect_all(itarg) = tCor_sumry(targIDX_insummary);
              
               %also dummy classify. place the classification (below), in
               %position along the rescaled (200 point) gait vector
               %  1= 1flash correct
               %  2 = 2flash correct
               %  3 = 1flash incorrect
               %  4 = 2flash incorrect
               %  0 = no resp
               if ~isnan(respWasCorrect_all(itarg))
                   if respWasCorrect_all(itarg)>0
                       % 1 or 2
                   gaitTarg_classvector(gPcnt) = targTypewas_all(itarg);
                   % add RT information as well.
                   gaitRTs_doubGC(rtcounter,:,:,:) = [gPcnt,  time_Response_all(itarg), targTypewas_all(itarg), NaN] ;
                    rtcounter=rtcounter+1;
                   else 
                       %3 or 4
                   gaitTarg_classvector(gPcnt) = targTypewas_all(itarg)+2;
                   gaitRTs_doubGC(rtcounter,:,:,:) = [gPcnt,  time_Response_all(itarg), targTypewas_all(itarg)+2, NaN] ;
                   rtcounter=rtcounter+1;
                   end
               else 
                   % miss
                   gaitTarg_classvector(gPcnt)= 0.1; % needs to be distinct within the vector (of zeros).
                   

               end
              % concat across targs:
              
              
             end
             
               gaitD(igait).tOnset_inTrialidnx = tOns_all;
               gaitD(igait).tOnset_inGait = tO;
               gaitD(igait).tOnset_inGaitResampled = gPcnt_all;
               %% 
               gaitD(igait).tType= targTypewas_all;
               gaitD(igait).tRT = time_Response_all;
               gaitD(igait).tRespCorr = respWasCorrect_all;
               gaitD(igait).tRespClass = gaitTarg_classvector;
               
            else 
                % useful for aligning response classes to correct gaits (below)
                gaitD(igait).tRespClass= nan; 
            end
               % store key data in matrix for easy handling:
            gaitHeadY(igait,:) = imresize(gaitDtmp_n', [1,200]);
            gaitTarg(igait,:) = gaitTarg_vector;
            gaitTarg_class(igait,:) = gaitTarg_classvector;
            
            %also store head Y info:
            gaitD(igait).Head_Yraw = gaitDtmp;
            gaitD(igait).Head_Ynorm = gaitDtmp_n;
            gaitD(igait).Head_Y_resampled = imresize(gaitDtmp_n', [1,200]);
            gaitD(igait).gaitsamps = gaitsamps;
           
            
               % per gait, also grab when the click occured relevant to Gait 
             % pcnt:
             gaitClick = tmpClick(gaitsamps);
             tR=  find(gaitClick==1);
            
            if ~isempty(tR) % target Onset occurred:
                for iresp=1:length(tR)
                    tRi= tR(iresp);
                    rPcnt = round((tRi/length(gaitsamps))*200);
                    % find the corresponding target (onset), and append the RT
                    % pcnt of gait, to the gaitRT information:
                    time_response = avTime(itrial, gaitsamps(tRi));
                    % find the index of this RT (to find the target).
                    
                    rtIDX_insummary = dsearchn([tClickOns_smry], [time_response]');
                    % what was the recorded RT, associated with this click onset?
                    searchRT =  tRTs_sumry(rtIDX_insummary);
                    % now find this 'row' in the rt information.
                    userow = find(gaitRTs_doubGC(:,2)==searchRT); % 3rd col is rt
                    % append the rPcnt to the correct target onset:
                    gaitRTs_doubGC(max(userow),4) = rPcnt;
                end
              
            end
            
        end % gait in trial.
        % also store matrix data at the trial level:
        trial_TargetSummary(itrial).gaitTarg_doubleGC = gaitTarg;
        trial_TargetSummary(itrial).gaitHeadY_doubleGC= gaitHeadY;       
        trial_TargetSummary(itrial).gaitTargs_detected_doubleGC = gaitTarg_class;
        
        % save this gait info per trial in structure as well.
        HeadPos(itrial).gaitData_doubleGC = gaitD;
        trial_TargetSummary(itrial).gaitData_doubleGC = gaitD;
        
end %trial

%% for all trials, compute the head pos per time point, and stacked targ Response class,
    % 0, 1, 2, 3, 4  = no resp, correct 1, 2, and incorrect 1 ,2 flashes.
    expindx= [HeadPos(:).isPrac];
    nprac= length(find(expindx>0));
    
    ntrials = size(HeadPos,2)-nprac;
    [PFX_headY_doubleGC, PFX_tOnsets_doubleGC, PFX_tHits_1flash_doubleGC, ...
        PFX_tHits_2flash_doubleGC, PFX_tMiss_1flash_doubleGC, ...
        PFX_tMiss_2flash_doubleGC, PFX_tNoresp_doubleGC]= deal(zeros(ntrials,200));
    
    [h1count, h2count, m1count, m2count, norespcount]=deal(1);
   
    for itrial= 1:size(trial_TargetSummary,2)
        if HeadPos(itrial).isPrac
            continue
        end
       tmp=trial_TargetSummary(itrial).gaitTarg_doubleGC; % nGaits
       nGaits = size(tmp,1);
       allgaits = 1:nGaits;
       % omit first and last gaitcycles from each trial
       usegaits = allgaits;%(3:(end-2));
        
       %data of interest is the resampled gait (1:200) with a position of
       %the targ (now classified as correct or no).
        TrialD= trial_TargetSummary(itrial).gaitTarg_doubleGC(usegaits,:); 
        TrialY= trial_TargetSummary(itrial).gaitHeadY_doubleGC(usegaits,:);
        
        PFX_tOnsets_doubleGC(itrial,:) = sum(TrialD,1);
        PFX_headY_doubleGC(itrial,:)= mean(TrialY,1);
        
        if max(TrialD(:))>0% if we had targets presented in any gaits:
        % also store by target classificaton, across all gaits:
         
        trialDetected = trial_TargetSummary(itrial).gaitTargs_detected_doubleGC(usegaits,:);
         
        for igait=1:size(trialDetected,1)
           
            % what was the classifcation on this trial?
            tmpD = trialDetected(igait,:);
            % bit inefficient, but shrink, then store:
            targsClassthisgait = tmpD(tmpD~=0);
            
            for iclass= 1:length(targsClassthisgait)
                tmpclass = targsClassthisgait(iclass);
                
                
                switch tmpclass
                    case 1 % 1 target, correctly perceived.
                        PFX_tHits_1flash_doubleGC(h1count,:) = TrialD(igait,:);
                        h1count=h1count+1;
                    case 2  % 2 targets, correctly perceived.
                        PFX_tHits_2flash_doubleGC(h2count,:) = TrialD(igait,:);
                        h2count=h2count+1;
                    case 3  % 1 target, incorrectly perceived.
                        PFX_tMiss_1flash_doubleGC(m1count,:) = TrialD(igait,:);
                        m1count=m1count+1;
                    case 4  % 2 targets, incorrectly perceived.
                        PFX_tMiss_2flash_doubleGC(m2count,:) = TrialD(igait,:);
                        m2count=m2count+1;
                    case 0.1
                        PFX_tNoresp_doubleGC(norespcount,:) = TrialD(igait,:);
                        norespcount=norespcount+1;
                end % switch
                
            end %iclass 
                
                
        end % all gaits
        end % targ present trial
    end % all trials
  
    allts= norespcount+m2count+m1count+h2count+h1count;
    % check we aren't missing data:
    disp([' All targs recorded for participant' num2str(ippant) '=' num2str(allts)]);
    save(savename, 'HeadPos', 'trial_TargetSummary',...
        'PFX_headY_doubleGC', 'PFX_tOnsets_doubleGC',...
       'PFX_tHits_1flash_doubleGC',...
        'PFX_tHits_2flash_doubleGC',...
         'PFX_tMiss_1flash_doubleGC', ...
        'PFX_tMiss_2flash_doubleGC', 'PFX_tNoresp_doubleGC',...
        'gaitRTs_doubGC','-append');
end % subject


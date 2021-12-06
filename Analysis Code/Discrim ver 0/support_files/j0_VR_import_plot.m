%DISCRIMINATION experiment (1 or 2 flashes)
%%  Import from csv. FramebyFrame, then summary data.

%frame by frame first:


% datadir= '/Users/matthewdavidson/Documents/GitHub/active-perception-Detection-ver2-simultaneity/Analysis Code/Detecting ver 0/Raw_data';
% PC
datadir= 'C:\Users\User\Documents\matt\GitHub\active-perception-Detection-ver2-simultaneity\Analysis Code\Detecting ver 0\Raw_data';
%%
cd(datadir);
%%
pfols = dir([pwd filesep '*framebyframe.csv']);
nsubs= length(pfols);
%% Per csv file, import and wrangle into Matlab Structures, and data matrices:
for ippant = 1:nsubs
    
   cd(datadir)
   
   pfols = dir([pwd filesep '*framebyframe.csv']);
    %% load subject data as table.
    filename = pfols(ippant).name;
    %extract name&date from filename:
    ftmp = find(filename =='_');
    subjID = filename(1:ftmp(end)-1);
    %read table
    opts = detectImportOptions(filename,'NumHeaderLines',0);
    T = readtable(filename,opts);
    ppant = T.participant{1};
    disp(['Preparing participant ' ppant]);
   
    savename = [subjID '_summary_data'];
    
    % simple extract of positions over time.
    [TargPos, HeadPos, TargState, clickState] = deal([]);
    
    %% use logical indexing to find all relevant info (in cells)
    posData = T.position;
    clickData = T.clickstate;
    targStateData= T.targState;
    objs = T.trackedObject;
    axes= T.axis;
    Trials =T.trial;
    Times = T.t;
    walkorStationary= T.isStationary;
    
    targ_rows = find(contains(objs, 'target'));
    head_rows = find(contains(objs, 'head'));
   
    Xpos = find(contains(axes, 'x'));
    Ypos  = find(contains(axes, 'y'));
    Zpos = find(contains(axes, 'z'));
    
    %% now find the intersect of thse indices, to fill the data.
    hx = intersect(head_rows, Xpos);
    hy = intersect(head_rows, Ypos);
    hz = intersect(head_rows, Zpos);
    
    %Targ (XYZ)
    tx = intersect(targ_rows, Xpos);
    ty = intersect(targ_rows, Ypos);
    tz = intersect(targ_rows, Zpos);
    
    %% further store by trials (walking laps).
    vec_lengths=[];
    for itrial = 1:length(unique(Trials))
        
        trial_rows = find(Trials==itrial-1); % indexing from 0 in Unity
        
        
        trial_times = Times(intersect(hx, trial_rows));
        %Head first (X Y Z)
        HeadPos(itrial).X = posData(intersect(hx, trial_rows));
        HeadPos(itrial).Y = posData(intersect(hy, trial_rows));
        HeadPos(itrial).Z = posData(intersect(hz, trial_rows));
        %store time (sec) for matching with summary data:
        HeadPos(itrial).times = trial_times;

        HeadPos(itrial).isPrac = unique(T.isPrac(trial_rows));        
        HeadPos(itrial).isStationary = unique(T.isStationary(trial_rows));
        
        TargPos(itrial).X = posData(intersect(tx, trial_rows));
        TargPos(itrial).Y = posData(intersect(ty, trial_rows));
        TargPos(itrial).Z = posData(intersect(tz, trial_rows));        
        TargPos(itrial).times = trial_times;
        TargPos(itrial).isPrac = unique(T.isPrac(trial_rows));        
        TargPos(itrial).isStationary = unique(T.isStationary(trial_rows));
        
        % because the XYZ have the same time stamp, collect click and targ
        % state as well.
        % note varying lengths some trials, so store in structure:
        TargState(itrial).state = targStateData(intersect(hx, trial_rows));
        TargState(itrial).times = trial_times;
        clickState(itrial).state = clickData(intersect(hx, trial_rows));
        clickState(itrial).simes = trial_times;
        
        
        
    end
    
    
    disp(['Saving position data split by trials... ' subjID]);
    rawFramedata_table = T;
    cd('ProcessedData')
    try save(savename, 'TargPos', 'HeadPos', 'TargState', 'clickState', 'rawFramedata_table', 'subjID', 'ppant', '-append');
    catch
        save(savename, 'TargPos', 'HeadPos', 'TargState', 'clickState', 'rawFramedata_table', 'subjID', 'ppant');
    end
    


%%
%reaarrange XYZ into data matix for basic plotting.
nTrials = size(HeadPos,2);
avTime = zeros(nTrials,150); % we'll store, time info for plots.
for iobj=1:3
    switch iobj
        case 1
            dataIN= HeadPos;
        case 2
            dataIN= TargPos;
        case 3
          %place holder, see below.
           % very long vector. populate with different lengths of data.
           nMat= nan(2,nTrials,150);
     
    end
   
    if iobj <=2
        %  long vector. populate with different lengths of data.
        nMat= nan(3,nTrials,150);
    
        for itrial= 1:nTrials
            tmp = length(dataIN(itrial).X);
            nMat(1,itrial,1:tmp) = dataIN(itrial).X;
            nMat(2,itrial,1:tmp) = dataIN(itrial).Y;
            nMat(3,itrial,1:tmp) = dataIN(itrial).Z;
            avTime(itrial,1:tmp) = dataIN(itrial).times;
        end
        
    else    % store targ and clicks together:
        
          for itrial= 1:nTrials
            tmp = length(dataIN(itrial).X);
            
            nMat(1, itrial, 1:tmp) = TargState(itrial).state;
            nMat(2, itrial, 1:tmp) = clickState(itrial).state;
          end
        
    end
    % save appropr
    switch iobj
        case 1
            Head_posmatrix = nMat;
       
        case 2
            Targ_posmatrix = nMat;
        case 3
            TargClickmatrix= nMat;
    end
    
    
end % iobj = 1:3
disp(['Saving data matrix for participant ' subjID ]);

save(savename, 'Head_posmatrix', 'Targ_posmatrix', 'TargClickmatrix', 'avTime', '-append');

%% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ now summary data

cd(datadir)
pfols = dir([pwd filesep '*trialsummary.csv']);
nsubs= length(pfols);
filename = pfols(ippant).name;
    %extract name&date from filename:
    ftmp = find(filename =='_');
    subjID = filename(1:ftmp(end)-1);
    %read table
    opts = detectImportOptions(filename,'NumHeaderLines',0);
    T = readtable(filename,opts);
    rawSummary_table = T;
    disp(['Preparing participant ' T.participant{1} ]);
    
    
    savename = [subjID '_summary_data'];
    % summarise relevant data:
    % calibration is performed after every dual target presented
    targPrestrials =find(T.nTarg>0);
    practIndex = find(T.isPrac ==1);
    disp([subjID ' has ' num2str((T.trial(practIndex(end)) +1)) ' practice trials']);
    %extract the rows in our table, with relevant data for assessing
    %calibration:
    calibAxis = intersect(targPrestrials, practIndex);
    
    %calculate accuracy:
    calibData = T.targCor(calibAxis);
    calibAcc = zeros(1, length(calibData));
    for itarg=1:length(calibData)
        tmpD = calibData(1:itarg);
        calibAcc(itarg) = sum(tmpD)/length(tmpD);
    end
    %retain contrast values:
    calibGap = T.targGap(calibAxis);
    
    %% extract Target onsets per trial (struct).
    %% and Targ RTs
    alltrials = unique(T.trial);
    trial_TargetSummary=[];
    for itrial= 1:length(alltrials)
        thistrial= alltrials(itrial);
        relvrows = find(T.trial ==thistrial); % unity idx at zero.
        
        %create vectors for storage:
        tOnsets = T.targOnset(relvrows);
        tRTs = T.targRT(relvrows);
        tCor = T.targCor(relvrows);       
        tFAs = unique(T.FA_rt(relvrows));
        
       	tTypes = T.targFlash(relvrows); % nflashes presented
        %RTs
        RTs = (tRTs - tOnsets);
        
        %note that negative RTs, indicate that no response was recorded:
        tOmit = find(RTs<0);
        if ~isempty(tOmit)
            tCor(tOmit) = NaN; % don't count those incorrects, as a mis identification.
            RTs(tOmit)=NaN; % remove no respnse 
        end
        %store in easier to wrangle format
        trial_TargetSummary(itrial).trialID= thistrial;
        trial_TargetSummary(itrial).targOnsets= tOnsets;
        trial_TargetSummary(itrial).targTypes= tTypes;
        trial_TargetSummary(itrial).targRespCorrect= tCor;
        trial_TargetSummary(itrial).targRTs= RTs;
        trial_TargetSummary(itrial).clickOnsets= tRTs;
       
        trial_TargetSummary(itrial).FalseAlarms= tFAs;
        trial_TargetSummary(itrial).isPrac= HeadPos(itrial).isPrac;
        
        trial_TargetSummary(itrial).isStationary= HeadPos(itrial).isStationary;
    end
     
    %% clean up known 'bad trials'
    rejectTrials_byPpant;
    
    %save for later analysis per gait-cycle:
    disp(['Saving trial summary data ... ' subjID]);
    rawdata_table = T;
    cd('ProcessedData')
    save(savename, 'trial_TargetSummary', 'calibGap', 'calibAcc', 'calibData',...
        'rawdata_table', 'subjID','HeadPos','rawSummary_table', '-append');
    

end % participant

%j1_split_bycycle

% Here we will identify the peaks in head position data, for later splitting
% walk trajectories into individual gait cycles.

cd([datadir filesep 'ProcessedData'])
Fs=90;
pfols = dir([pwd filesep '*summary_data.mat']);
nsubs= length(pfols);
Timevec = [1:size(Head_posmatrix,3)] .* 1/Fs;

nPractrials=40;
%%
% threshold between peaks for detection
pkdist = Fs/2.5; % 400ms.
participantstepwidths= [15,15, 8]; %samples, May need to toggle per ppant.
pkheight = 0.0002; % (m)

figure(1); clf;
set(gcf, 'units', 'normalized', 'position', [0,0, .9, .9], 'color', 'w', 'visible', 'off');

for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])
   
    pkdist = participantstepwidths(ippant);
    %%load data from import job.
    load(pfols(ippant).name);
    savename = pfols(ippant).name;
    disp(['Preparing j1 ' subjID]);
    
    %% visualize the peaks and troughs in the head (Y) position.
    %Head position on Y axis, smooth to remove erroneous peaks.
   
    pcount=1; % plot indexer
    figcount=1; %figure counter.
    %% Note that for nPractice trials, there won't be peaks and troughs, as the ppant was stationary.
    for  itrial=1:size(HeadPos,2)
        
        %trial data:
        trialD_sm = smooth(squeeze(Head_posmatrix(2,itrial,:))', 5); % small smoothing factor.
        trialD = squeeze(Head_posmatrix(2,itrial,:))';
            
            
        if itrial < nPractrials+1
            % print pos data, no peak detection:
            
            figure(1);
            if itrial==16 || pcount ==16
                %print that figure, and reset trial count.
                pcount=1;
                 cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
                print('-dpng', [subjID ' trialpeaks ' num2str(figcount)]);
                figcount=figcount+1;
                clf;
                
            end
            subplot(5,3,pcount);
            plot(Timevec, trialD);
            hold on;
            ylabel('Head position');
            xlabel('Time (s)');
            title(['Trial ' num2str(itrial) ' (calibration)']);
            axis tight
            pcount=pcount+1;
        else
            
         
            %find local peaks.
            %Threshold peak finder using something reasonable. like 500ms
            
            
%             [~, locs_p]= findpeaks(trialD_sm, 'MinPeakDistance',pkdist, 'MinPeakProminence', pkheight); %
            [~, locs_p]= findpeaks(trialD_sm, 'MinPeakDistance',pkdist);
            [~, locs_tr]= findpeaks(-trialD_sm, 'MinPeakDistance',pkdist ,'MinPeakProminence', pkheight);
            
            % extract nearest peaks and troughs from unsmoothed data:
            [~, locs_p_r] =  findpeaks(trialD, 'MinPeakDistance', pkdist, 'MinPeakProminence', pkheight);
            %find nearest in raw data, to peaks detected in smoothed version
            locs_ptr=zeros(1,length(locs_p));
            for ip=1:length(locs_p)
                [~, idx] = min(abs(locs_p_r - locs_p(ip)));
                locs_ptr(ip) = locs_p_r(idx);
            end
            %same for troughs:
            [~, locs_tr_r] =  findpeaks(-trialD, 'MinPeakDistance', pkdist, 'MinPeakProminence', pkheight);
            %find nearest in raw data, to peaks detected in smoothed version
            locs_trtr=zeros(1,length(locs_tr));
            for ip=1:length(locs_tr)
                [~,idx] = min(abs(locs_tr_r - locs_tr(ip)));
                locs_trtr(ip) = locs_tr_r(idx);
            end
            
            % for stability, we want to start and end in a trough.
            if locs_trtr(1) > locs_ptr(1) % if trial starts with peak.
                %insert trough, using minimum before first peak
                [~, ftr ] = min(trialD(1:locs_ptr(1)));
                locs_trtr = [ ftr,  locs_trtr];
            end
            %if trial ends with peak, add trough after at local minimum
            if locs_ptr(end) > locs_trtr(end) % if trial ends with peak.
                %insert trough, using minimum after last peak
                [~, ftr ] = min(trialD(locs_ptr(end):end));
                locs_trtr = [locs_trtr, locs_ptr(end)-1+ftr];
            end
            
            % finally, make sure that troughs and peaks alternate, if not, use
            % the maximum (peak) or minimum (trough) option
            % Should only be an issue at trial onset.
            % test if first peak is after a second trough , if so remove the
            % latter.
            
            %store copy to not mess with for loop indexing.
            newpks = locs_ptr;
            
            if length(locs_trtr) ~= length(locs_ptr)+1
                %% correct as necessary:
                
                % find doubled pks (most likely):
                for igait = 1:length(locs_trtr)-1
                    gstart = locs_trtr(igait);
                    gend = locs_trtr(igait+1);
                    try % inspect gait cycles for double peaks.
                        if locs_ptr(igait+1) < gend % if two peaks before gait cycle ends.
                            %retain the max height as true peak.
                            h1= trialD(locs_ptr(igait));
                            h2= trialD(locs_ptr(igait+1));
                            if h1>h2
                                %remove next peak
                                locs_ptr(igait+1)=[];
                            else %remove first peak.
                                locs_ptr(igait)=[];
                            end
                            
                        end
                    catch
                    end
                    
                end
                
                
                
                % now find doubled troughs
                
                for igait = 1:length(locs_ptr)
                    %for each peak, check only one trough before and after.
                    gstart = locs_trtr(igait);
                   try  gend = locs_trtr(igait+1);
                   catch
                       continue
                   end
                    if locs_ptr(igait) > gend % if two troughs before a peak.
                        %retain the min height as true trough.
                        h1= trialD(gstart);
                        h2= trialD(gend);
                        if h1>h2
                            %remove first trough
                            %                        deltroughs = [deltroughs, igait];
                            locs_trtr(igait)=[];
                        else %remove second trough.
                            locs_trtr(igait+1)=[];
                        end
                        
                    end
                    %% check if this is the last peak, that there is only one trough remaining:
                    if igait == length(locs_ptr)
                        %last trough should be max, else error.
                        if locs_trtr(igait+1) ~= (locs_trtr(end))
                            % then retain only the minimum of the remaining
                            % troughs.
                            h1= trialD(locs_trtr(igait+1));
                            h2= trialD(locs_trtr(end));
                            if h1>h2
                                %remove first trough
                                %                        deltroughs = [deltroughs, igait];
                                locs_trtr(igait+1)=[];
                            else %remove second trough.
                                locs_trtr(end)=[];
                            end
                        end
                    end
                    
                    
                end % for each gait
                
                
                
            end % if more troughs than peaks.
            
            if length(locs_trtr) ~= length(locs_ptr)+1
                error('check code')
            end
            
            %%     visualize results.
            
            figure(1);
            if itrial==16 || pcount ==16
                %print that figure, and reset trial count.
                pcount=1;
                cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
                print('-dpng', [subjID ' trialpeaks ' num2str(figcount)]);
                figcount=figcount+1;
                clf;
                
            end
            subplot(5,3,pcount);
            plot(Timevec, trialD);
            hold on;
            plot(Timevec(locs_ptr), trialD(locs_ptr), ['or']);
            plot(Timevec(locs_trtr), trialD(locs_trtr), ['ob']);
            ylabel('Head position');
            xlabel('Time (s)');
            title(['Trial ' num2str(itrial)]);
            axis tight
            pcount=pcount+1;
            
            %add these peaks and troughs to trial structure data.
            HeadPos(itrial).Y_gait_peaks = locs_ptr;
            HeadPos(itrial).Y_gait_troughs = locs_trtr;
            
            % add to adjusted struct as well:
            adjindex = [trial_TargetSummary(:).trialID]+1;
            thistrial = find(adjindex == itrial);
            if ~isempty(thistrial)
            HeadPos_adj(thistrial).Y_gait_peaks = locs_ptr;
            HeadPos_adj(thistrial).Y_gait_troughs = locs_trtr;
            else
                disp([ 'trial ' num2str(itrial) ' summary info missing']);
            end
        end
        %
    end %itrial.
    %%
    
    cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
    
    
    print('-dpng', [subjID ' trialpeaks ' num2str(figcount)]);
    clf;
    cd([datadir filesep 'ProcessedData']);
    save(savename, 'HeadPos', '-append');
end % isub

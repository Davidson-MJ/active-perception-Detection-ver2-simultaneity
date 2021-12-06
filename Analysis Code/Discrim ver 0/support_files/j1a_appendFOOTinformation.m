%j1a_appendFOOTinformation

% Here using the peak/trough information collected in the previous script,
% append whether gaits are left/right foot leading.

cd([datadir filesep 'ProcessedData'])
Fs=90;
pfols = dir([pwd filesep '*summary_data.mat']);
nsubs= length(pfols);

%%
figure(1); clf;
set(gcf, 'units', 'normalized', 'position', [0,0, .9, .9], 'color', 'w', 'visible', 'off');
%%
for ippant =1:nsubs
    cd([datadir filesep 'ProcessedData'])
   
%     pkdist = participantstepwidths(ippant);
    %%load data from import job.
    load(pfols(ippant).name);
    savename = pfols(ippant).name;
    disp(['Preparing j1 ' subjID]);
        
    %% visualize a top-down view of the trajectory, to identify left/right foot per gait.
    
    pcount=1; % plot indexer
    figcount=1; %figure counter.
    %% Note that for nPractice trials, there won't be peaks and troughs, as the ppant was stationary.
    for  itrial=1:size(HeadPos,2)
        
        %% trial data:
        trialtmp = HeadPos(itrial).Z; % axis
        trialD_sm = smooth(trialtmp, 5); % small smoothing factor.
        trialDz = squeeze(trialtmp);
        
         trialtmp = HeadPos(itrial).Y; % axis
        trialD_sm = smooth(trialtmp, 5); % small smoothing factor.
        trialDy = squeeze(trialtmp);
        
        
        
        trialtmp = HeadPos(itrial).X; % axis
        trialD_sm = smooth(trialtmp, 5); % small smoothing factor.
        trialDx = squeeze(trialtmp);
        
        Timevec = HeadPos(itrial).times;
        %%
        if HeadPos(itrial).isPrac
            % print pos data, no peak detection:
            
            figure(1);
            if itrial==16 || pcount ==16
                %print that figure, and reset trial count.
                pcount=1;
                 cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
                print('-dpng', [subjID ' trialFoot ' num2str(figcount)]);
                figcount=figcount+1;
                clf;
                
            end
            subplot(5,3,pcount);
            plot(Timevec, trialDz);
            hold on;            
            ylabel('Head position (Z)');
            yyaxis right
             plot(Timevec, trialDx);
             ylabel('Head position (X)');
            xlabel('Time (s)');
            title(['Trial ' num2str(itrial) ' (calibration)']);
            % add targ and response info:
           
            axis tight
            pcount=pcount+1;
        else
            
          %% load the prev calculated pks and trs.
          locs_ptr= HeadPos(itrial).Y_gait_peaks;
          locs_trtr= HeadPos(itrial).Y_gait_troughs;
          %based on heading direction, calculate Left/Right orientation.
          % if the x position is descending, then lower z values correspond
          % to left roll. if x position is ascending, participant has
          % turned 180, on the return path. Now lower z values correspnd to
          % right roll.
          if trialDx(1)>trialDx(end)
              PosOrientation= {'L', 'R'};
          else
              PosOrientation= {'R', 'L'};
          end
              
            %%     visualize results.
            
            figure(1);
            if itrial==16 || pcount ==16
                %print that figure, and reset trial count.
                pcount=1;
                cd([datadir filesep 'Figures' filesep 'Trial_headYpeaks'])
                print('-dpng', [subjID ' trialFoot ' num2str(figcount)]);
                figcount=figcount+1;
                clf;
                
            end
            %%
            subplot(5,3,pcount);
            %%   
            figure();
            plot(Timevec, trialDz, 'linew', 2); hold on;
            plot(Timevec(locs_ptr), trialDz(locs_ptr), ['or']);
            plot(Timevec(locs_trtr), trialDz(locs_trtr), ['ob']);
            ylabel('Head position (z)')
            hold on;
            yyaxis right
            plot(Timevec, trialDy, 'color', [.5 .5 .5]);
            
            
            ylabel('Head position');
            xlabel('Time (s)');
            title(['Trial ' num2str(itrial)]);
            %%
           
            
            axis tight
            pcount=pcount+1;
            
        end
        %
       
    end %itrial.
    %%
    
    cd([datadir filesep 'Figures' filesep 'Trial_FeetPos'])
    
    
    print('-dpng', [subjID ' trialpeaks ' num2str(figcount)]);
    clf;
    cd([datadir filesep 'ProcessedData']);
    save(savename, 'HeadPos', '-append');
end % isub

% plotj2_targClassification_winGait

% loads the ppant data collated in j2_binData_bycycle.

%plots the position of correctly and incorrectly identified targets, per
%pariticpant, as a position of the gait cycle.

cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);

job.plot_targDistribution=0; % plot the incidence of all targs (correct, incorrect, and missed)
job.plot_targDistribution_doubleGC=0; % as above, but 2 linked steps.

job.plot_targBinned=0; % single GC, binning into 7 regions to show proportion accuracy.

%%%%
job.plot_targBinned_doubleGC=1; % double GC, as above.
job.basicPermtest =1; %create null distribution for quick plot:
job.plotGFX_targBinned_doubleGC=1; % requires plot_targBinned_doubleGC first.
GFX_allbinned=[];
GFX_headY=[];
%%%%
dataIN=[];
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name, ...
        'PFX_tHits_1flash','PFX_tMiss_1flash', 'PFX_tHits_2flash','PFX_tMiss_2flash', ...
        'PFX_tHits_1flash_doubleGC','PFX_tMiss_1flash_doubleGC', ...
        'PFX_tHits_2flash_doubleGC','PFX_tMiss_2flash_doubleGC', ...
        'PFX_tNoresp', 'PFX_tNoresp_doubleGC', ...
        'PFX_headY', 'PFX_headY_doubleGC', 'subjID');
    
    % shrink for easier readbility:
    
    dataIN(1,ippant).gc = PFX_tHits_1flash;
    dataIN(2,ippant).gc = PFX_tHits_2flash;
    dataIN(3,ippant).gc = PFX_tMiss_1flash;
    dataIN(4,ippant).gc = PFX_tMiss_2flash;
    dataIN(5,ippant).gc = PFX_tNoresp;
    dataIN(1,ippant).doubgc = PFX_tHits_1flash_doubleGC;
    dataIN(2,ippant).doubgc = PFX_tHits_2flash_doubleGC;
    dataIN(3,ippant).doubgc = PFX_tMiss_1flash_doubleGC;
    dataIN(4,ippant).doubgc = PFX_tMiss_2flash_doubleGC;
    dataIN(5,ippant).doubgc = PFX_tNoresp_doubleGC;
    
    if job.plot_targDistribution==1
        %% figure:
        figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
        
        titles={'Single flash', 'Double flash'};
        for itarg = 1:2
            switch itarg
                case 1 % single flashes presented
                    corrD= PFX_tHits_1flash;
                    errD = PFX_tMiss_1flash;
                case 2
                    corrD= PFX_tHits_2flash;
                    errD = PFX_tMiss_2flash;
            end
            
            % convert the data for histogram:
            hleg=[];
            counts=[];
            for idata= 1:2 % corr and err
                switch idata
                    case 1
                        sampSum = sum(corrD,1);
                        col='g';
                    case 2
                        sampSum = sum(errD,1);
                        col='r';
                end
                
                %convert to counts for histogram:
                hist_Data=[];
                for idx=1:100 % sample position
                    if sampSum(idx)>0
                        tmp = repmat(idx, 1, sampSum(idx));
                        hist_Data =[ hist_Data, tmp];
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                % plot
                subplot(2,2,itarg);
                % Head height as background:
                hold on;
                yyaxis left
                plot(nanmean(PFX_headY), ['k-o']); hold on
                % now data:
                yyaxis right
                hg= histogram(hist_Data, 100, 'FaceColor', col );
                %             title(titlesare{itype});
                hleg(idata)= hg;
                counts(idata) = length(hist_Data);
                
                title(titles{itarg});
                
                %also plot grand total in bottom right:
                subplot(2,2,4); hold on;
                yyaxis left
                plot(nanmean(PFX_headY));
                hold on;
                yyaxis right
                hg= histogram(hist_Data, 100, 'FaceColor', col);
                title('All')
            end
            legend([hleg(1), hleg(2)], {['correct (' num2str(counts(1)) ')'],...
                ['error (' num2str(counts(2)) ')']});
            
            title(titles{idata});
        end % each targ.
        %% add the misses (all cases)
        %convert to counts for histogram:
        sampSum = sum(PFX_tNoresp,1);
        hist_Data=[];
        for idx=1:100 % sample position
            if sampSum(idx)>0
                tmp = repmat(idx, 1, sampSum(idx));
                hist_Data =[ hist_Data, tmp];
            end
        end
        subplot(2,2,3);
        
        % Head height as background:
        hold on;
        yyaxis left
        plot(nanmean(PFX_headY), ['k-o']); hold on
        % now data:
        yyaxis right
        hg= histogram(hist_Data, 100, 'FaceColor', col );
        legend(hg, {['Missed (' num2str(length(hist_Data)) ')']});
        
        %% subjID:
        sgtitle(subjID, 'interpreter', 'none')
        
        cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
        print([subjID ' targs within gait'],'-dpng');
    end
    
    
    %%%%%%% as above, but 2 steps
    if job.plot_targDistribution_doubleGC==1
        %% figure:
        figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
        
        titles={'Single flash', 'Double flash'};
        for itarg = 1:2
            switch itarg
                case 1 % single flashes presented
                    corrD= PFX_tHits_1flash_doubleGC;
                    errD = PFX_tMiss_1flash_doubleGC;
                case 2
                    corrD= PFX_tHits_2flash_doubleGC;
                    errD = PFX_tMiss_2flash_doubleGC;
            end
            
            % convert the data for histogram:
            hleg=[];
            counts=[];
            for idata= 1:2 % corr and err
                switch idata
                    case 1
                        sampSum = sum(corrD,1);
                        col='g';
                    case 2
                        sampSum = sum(errD,1);
                        col='r';
                end
                
                %convert to counts for histogram:
                hist_Data=[];
                for idx=1:size(sampSum,2) % sample position
                    if sampSum(idx)>0
                        tmp = repmat(idx, 1, sampSum(idx));
                        hist_Data =[ hist_Data, tmp];
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                % plot
                subplot(2,2,itarg);
                % Head height as background:
                hold on;
                yyaxis left
                plot(nanmean(PFX_headY_doubleGC), ['k-o']); hold on
                % now data:
                yyaxis right
                hg= histogram(hist_Data, 200, 'FaceColor', col );
                %             title(titlesare{itype});
                hleg(idata)= hg;
                counts(idata) = length(hist_Data);
                
                title(titles{itarg});
                
                %also plot grand total in bottom right:
                subplot(2,2,4); hold on;
                yyaxis left
                plot(nanmean(PFX_headY_doubleGC));
                hold on;
                yyaxis right
                hg= histogram(hist_Data, 200, 'FaceColor', col);
                title('All targets')
            end
            legend([hleg(1), hleg(2)], {['correct (' num2str(counts(1)) ')'],...
                ['error (' num2str(counts(2)) ')']});
            
        end % each targ.
        %% add the misses (all cases)
        %convert to counts for histogram:
        sampSum = sum(PFX_tNoresp_doubleGC,1);
        hist_Data=[];
        for idx=1:length(sampSum)% sample position
            if sampSum(idx)>0
                tmp = repmat(idx, 1, sampSum(idx));
                hist_Data =[ hist_Data, tmp];
            end
        end
        subplot(2,2,3);
        
        % Head height as background:
        hold on;
        yyaxis left
        plot(nanmean(PFX_headY_doubleGC), ['k-o']); hold on
        % now data:
        yyaxis right
        hg= histogram(hist_Data, 200, 'FaceColor', col );
        legend(hg, {['Missed (' num2str(length(hist_Data)) ')']});
        
        sgtitle(subjID, 'interpreter', 'none');
        
        
        %     title(pfols(ippant).name, 'interpreter', 'none');
        cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
        print([subjID ' targs within double gait'],'-dpng');
    end
    
    if job.plot_targBinned
        %% calculate proportions per binned section.
        bins=[1:25; 26:50; 51:75; 76:100];
        pidx= ceil(linspace(1,100,7));
        
        
        figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
        
        titles={'Single flash', 'Double flash'};
        for itarg=1:2
            if itarg==1
                tmpC= PFX_tHits_1flash; % 1 corr.
                tmpErr= PFX_tMiss_1flash; % 1 err.
            else
                tmpC= PFX_tHits_2flash; % 1 corr.
                tmpErr= PFX_tMiss_2flash; % 2 err.
            end
            
            prop=[];
            for ibin=1:length(pidx)-1
                idx = pidx(ibin):pidx(ibin+1);
                
                prop(ibin) = sum(nansum(tmpC(:,idx)))/ (  sum(nansum(tmpC(:,idx))) + sum(nansum(tmpErr(:,idx))));
            end
            
            subplot(1,2, itarg);
            yyaxis left
            ylim([0 1]);
            plot(nanmean(PFX_headY)); hold on
            yyaxis right
            bar(pidx(1:end-1), prop, 'FaceAlpha', 0.2)
            title(titles{itarg})
            ylabel(['Proportion correct'])
            ylim([0 1]);
            set(gca, 'fontsize', 15)
            sgtitle(subjID, 'interpreter', 'none');
%             if itarg==2
%                 GFX_allbinned= [GFX_allbinned;prop];
%             end
        end
        shg
        
        
    end
    
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
    print([subjID ' targs within gait, proportion binned'], '-dpng');
    
    if job.plot_targBinned_doubleGC
        %% calculate proportions per binned section.
        % bins=[1:25; 26:50; 51:75; 76:100];
        pidx= ceil(linspace(1,200,14));
        
        
        figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
        
        titles={'Single flash', 'Double flash'};
        for itarg=1:2
            if itarg==1
                tmpC= PFX_tHits_1flash_doubleGC; % 1 corr.
                tmpErr= PFX_tMiss_1flash_doubleGC; % 1 err.
            else
                tmpC= PFX_tHits_2flash_doubleGC; % 1 corr.
                tmpErr= PFX_tMiss_2flash_doubleGC; % 2 err.
            end
            
            prop=[];
            for ibin=1:length(pidx)-1
                idx = pidx(ibin):pidx(ibin+1);
                
                prop(ibin) = sum(nansum(tmpC(:,idx)))/ ( sum(nansum(tmpC(:,idx))) + sum(nansum(tmpErr(:,idx))));
            end
            
            subplot(1,2, itarg);
            yyaxis left
            ylim([0 1]);
            plot(nanmean(PFX_headY_doubleGC)); hold on
            yyaxis right
            bar(pidx(1:end-1), prop, 'FaceAlpha', 0.2)
            title(titles{itarg})
            ylabel(['Proportion correct'])
            ylim([0 1]);
            set(gca, 'fontsize', 15)
            sgtitle(subjID, 'interpreter', 'none');
            
            
                GFX_allbinned(itarg,ippant,:)= prop;
                GFX_headY(itarg, ippant,:) = nanmean(PFX_headY_doubleGC);
        end
        shg
        
        
        cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
        print([subjID ' targs within gait, proportion binned doubleGC'], '-dpng');
    end % job
end % all ppants

if job.basicPermtest
   %% quick one for now. calculate the proportion per bin (double GC), if sampling from a random subset of samples each time.
   %concat d across ppnts.
   permDataOUT=[];
   for iperm=1:1000
       tmpProp=[];
       for ippant=1:nsubs
           for itarg=1:2
               if itarg==1
                   tmpC= dataIN(1,ippant).doubgc; % 1 corr.
                   tmpErr= dataIN(3,ippant).doubgc; % 1 err.
               else
                   tmpC= dataIN(2,ippant).doubgc; % 2 corr.
                   tmpErr= dataIN(4,ippant).doubgc; % 2 err.
               end
               
               prop=[];
               for ibin=1:length(pidx)-1
                    % choose points at random!                    
                   %idx = pidx(ibin):pidx(ibin+1);
                   idx = randi(200,[1,16]);
                   
                   prop(ibin) = sum(nansum(tmpC(:,idx)))/ ( sum(nansum(tmpC(:,idx))) + sum(nansum(tmpErr(:,idx))));
               end
               tmpProp(itarg,ippant,:) = prop;
               
           end% targ
       end % ppant
       % calc mean prop across ppants, this perm, and save:
       permDataOUT(iperm,1,:) = nanmean(tmpProp(1,:,:),2);
       permDataOUT(iperm,2,:) = nanmean(tmpProp(2,:,:),2);
       
       disp(['Fin perm ' num2str(iperm) ' of 1000']); 
   end % perm
   
   % for each position (bin), calculate the median, and uppwer and lower
   % bounds of the probability density function (used in next plot).
   
   shufftoPlot= zeros(2,3,size(permDataOUT,3)); % targs. [lower,med,upper], samps
   for itarg=1:2
   for ibin = 1:size(permDataOUT,3)
       
       datadist= squeeze(permDataOUT(:,itarg,ibin));
       shufftoPlot(itarg,:,ibin) = quantile(datadist, [.05, .5, .95]);
   end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
if job.plotGFX_targBinned_doubleGC==1 % concats and then plots.
    %%
    figure(3); clf
    
    for itarg=1:2
        % plot mean accuracy.
        subplot(1,2,itarg)
        pD = squeeze(GFX_allbinned(itarg,:,:));
        pH=squeeze(GFX_headY(itarg,:,:));
        
        bar(pidx(1:end-1), mean(pD,1), 'FaceAlpha', 0.2);
        stE= CousineauSEM(pD);
        hold on;
        
        errorbar(pidx(1:end-1), mean(pD,1), stE, 'linestyle', 'none');
        ylim([.5 1])
        title(titles{itarg})
        
        
        % plot shuff likelihood for comp.
        upB = plot(pidx(1:end-1), squeeze(shufftoPlot(itarg,1,:))', ['k:']);
        medB = plot(pidx(1:end-1), squeeze(shufftoPlot(itarg,2,:)), ['k-']);
        lowB = plot(pidx(1:end-1), squeeze(shufftoPlot(itarg,3,:)), ['k:']);
        
        %% plot mean head pos
        yyaxis right
        plot(nanmean(pH)); hold on
        set(gca, 'ytick', [])
        
        
    end
end
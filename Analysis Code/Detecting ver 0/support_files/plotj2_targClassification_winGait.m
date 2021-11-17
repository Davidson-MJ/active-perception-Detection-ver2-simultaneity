% plotj2_targClassification_winGait

% loads the ppant data collated in j2_binData_bycycle.

%plots the position of correctly and incorrectly identified targets, per
%pariticpant, as a position of the gait cycle.

cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);

% how many gaits to plot?
nGaits_toPlot=1; % 1 or 2.

job.concat_GFX=0;
job.basicPermtest =1; %create null distribution for quick plot:

job.plot_targDistribution=0; % plot the incidence of all targs (correct, incorrect, and missed)
job.plot_targBinned=0; % single GC, binning into 7 regions to show proportion accuracy.

%%%%
job.plotGFX_targBinned=1; % note also calls on the results of basicPermtest.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%data wrangling first: Concat, and create null distribution.

gaittypes = {'single gait' , 'double gait'};
%%
if job.concat_GFX
    dataIN=[];
    GFX_allbinned=[];
    GFX_headY=[];
    subjIDs={};
    for ippant = 1:nsubs
        cd([datadir filesep 'ProcessedData'])    %%load data from import job.
        load(pfols(ippant).name, ...
            'PFX_tHits_1flash','PFX_tMiss_1flash', 'PFX_tHits_2flash','PFX_tMiss_2flash', ...
            'PFX_tHits_1flash_doubleGC','PFX_tMiss_1flash_doubleGC', ...
            'PFX_tHits_2flash_doubleGC','PFX_tMiss_2flash_doubleGC', ...
            'PFX_tNoresp', 'PFX_tNoresp_doubleGC', ...
            'PFX_headY', 'PFX_headY_doubleGC', 'subjID');
        
        subjIDs{ippant} = subjID;
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
        
        % mean head pos:
        
        GFX_headY(ippant).gc = nanmean(PFX_headY);
        
        GFX_headY(ippant).doubgc = nanmean(PFX_headY_doubleGC);
        
        
        % calculate proportions for easy plotting later:
        for nGait=1:2
            if nGait==1
                pidx= ceil(linspace(1,100,7));
                %set data for 1 and 2 flash case:
                use1cor= PFX_tHits_1flash;
                use1err = PFX_tMiss_1flash;
                use2corr = PFX_tHits_2flash;
                use2err = PFX_tMiss_2flash;
            else
                pidx= ceil(linspace(1,200,14));
                
                use1cor= PFX_tHits_1flash_doubleGC;
                use1err = PFX_tMiss_1flash_doubleGC;
                use2corr = PFX_tHits_2flash_doubleGC;
                use2err = PFX_tMiss_2flash_doubleGC;
            end
            for nTarg=1:2
                if nTarg==1
                    tmpC= use1cor; % 1 corr.
                    tmpErr= use1err; % 1 err.
                else
                    tmpC= use2corr; % 2 corr.
                    tmpErr= use2err; % 2 err.
                end
                
                prop=[];
                for ibin=1:length(pidx)-1
                    idx = pidx(ibin):pidx(ibin+1);
                    
                    prop(ibin) = sum(nansum(tmpC(:,idx)))/ (  sum(nansum(tmpC(:,idx))) + sum(nansum(tmpErr(:,idx))));
                end
                %store across ppants.
                if nGait==1
                    GFX_allbinned(nTarg, ippant).gc = prop;
                else
                    GFX_allbinned(nTarg, ippant).doubgc = prop;
                end
                
            end % itarg
        end % ntarg
        
    end % ppant
    dimsare = {'1flashcor', '2flashcor','1flasherr', '2flasherr', 'miss'};
    GFX_data= dataIN;
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    save('GFX_targClassification_inGaits', 'GFX_data', 'GFX_allbinned', 'GFX_headY', 'subjIDs');
else
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    load('GFX_targClassification_inGaits');
end
% job



%% perform (and save, perm data for comparison in GFX plots?
if job.basicPermtest
    %% quick one for now. calculate the proportion per bin (double GC), if sampling from a random subset of samples each time.
    %concat d across ppnts.
    shuffData=[];
    shuffData_toplot=[];
    
    for nGait=1:2
        permDataOUT=[];
        if nGait==1 % set bin indexing.
            pidx = linspace(1,100,7);
            
        else
            pidx = linspace(1,200,14);
        end
        
        
        for iperm=1:1000
            tmpProp=[];
            for ippant=1:nsubs
                for itarg=1:2
                    if itarg==1
                        if nGait==1
                            tmpC= GFX_data(1,ippant).gc; % 1 corr.
                            tmpErr= GFX_data(3,ippant).gc; % 1 err.
                        else
                            tmpC= GFX_data(1,ippant).doubgc; % 1 corr.
                            tmpErr= GFX_data(3,ippant).doubgc; % 1 err.
                        end
                        
                    else
                        if nGait==1
                            tmpC= GFX_data(2,ippant).gc; % 2 corr.
                            tmpErr= GFX_data(4,ippant).gc; % 2 err.
                        else
                            tmpC= GFX_data(2,ippant).doubgc; % 2 corr.
                            tmpErr= GFX_data(4,ippant).doubgc; % 2 err.
                        end
                        
                    end
                    
                    prop=[];
                    for ibin=1:length(pidx)-1
                        % choose points at random!
                        %idx = pidx(ibin):pidx(ibin+1);
                        idx = randi(100*nGait, [1,16]);
                        
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
                %                 stDt= std(datadist);
                shufftoPlot(itarg,:,ibin) = quantile(datadist, [.25, .5, .75]);
            end
        end
        
        %rename and save:
        if nGait==1
            shuffData.gc= permDataOUT;
            shuffData_toplot.gc = shufftoPlot;
        else
            shuffData.doubgc= permDataOUT;
            shuffData_toplot.doubgc = shufftoPlot;
        end
        
    end % Ntargs
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    save('GFX_targClassification_inGaits','shuffData', 'shuffData_toplot', '-append');
end % basic perm test job
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% plots at Participant level:

if job.plot_targDistribution==1
    for ippant = 1:nsubs
        
        
        %% figure:
        figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
        
        titles={'Single flash', 'Double flash'};
        for itarg = 1:2
            switch itarg
                case 1 % single flashes presented
                    if nGaits_toPlot==1
                        corrD= GFX_data(1, ippant).gc; %1 flash cor
                        errD = GFX_data(3, ippant).gc; % 1 flash err
                        missD = GFX_data(5, ippant).gc;
                        plotHead = GFX_headY(ippant).gc;
                    else
                        corrD= GFX_data(1, ippant).doubgc; %1 flash cor
                        errD = GFX_data(3, ippant).doubgc; % 1 flash err
                        missD = GFX_data(5, ippant).doubgc;
                        
                        plotHead = GFX_headY(ippant).doubgc;
                    end
                case 2
                    if nGaits_toPlot==1
                        corrD=  GFX_data(2, ippant).gc; % 2 flash case
                        errD =  GFX_data(4, ippant).gc;
                        missD = GFX_data(5, ippant).gc;
                        
                    else
                        corrD=  GFX_data(2, ippant).doubgc; % 2 flash case
                        errD =  GFX_data(4, ippant).doubgc;
                        missD = GFX_data(5, ippant).doubgc;
                    end
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
                for idx=1:length(sampSum) % sample position
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
                plot(plotHead, ['k-o']); hold on
                % now data:
                yyaxis right
                hg= histogram(hist_Data, length(sampSum), 'FaceColor', col );
                %             title(titlesare{itype});
                hleg(idata)= hg;
                counts(idata) = length(hist_Data);
                
                title(titles{itarg});
                
                %also plot grand total in bottom right:
                subplot(2,2,4); hold on;
                yyaxis left
                plot(plotHead);
                hold on;
                yyaxis right
                hg= histogram(hist_Data, length(sampSum), 'FaceColor', col);
                title('All')
            end
            legend([hleg(1), hleg(2)], {['correct (' num2str(counts(1)) ')'],...
                ['error (' num2str(counts(2)) ')']});
            
            
        end % each targ.
        %% add the misses (all cases)
        %convert to counts for histogram:
        sampSum = sum(missD,1);
        hist_Data=[];
        for idx=1:length(sampSum) % sample position
            if sampSum(idx)>0
                tmp = repmat(idx, 1, sampSum(idx));
                hist_Data =[ hist_Data, tmp];
            end
        end
        subplot(2,2,3);
        
        % Head height as background:
        hold on;
        yyaxis left
        plot(plotHead, ['k-o']); hold on
        % now data:
        yyaxis right
        hg= histogram(hist_Data, length(sampSum), 'FaceColor', col );
        legend(hg, {['Missed (' num2str(length(hist_Data)) ')']});
        
        %% subjID:
        sgtitle(subjIDs{ippant}, 'interpreter', 'none')
        
        cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
        
        print([subjIDs{ippant} ' targs within ' gaittypes{nGaits_toPlot} ],'-dpng');
    end
end
%% job

if job.plot_targBinned
    for ippant= 1:nsubs
        
        
        figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
        
        titles={'Single flash', 'Double flash'};
        for itarg=1:2
            if nGaits_toPlot==1
                plotProb = GFX_allbinned(itarg, ippant).gc;
                plotHeadY = GFX_headY(ippant).gc;
                pidx= ceil(linspace(1,100,7));
            else
                plotProb = GFX_allbinned(itarg, ippant).doubgc;
                plotHeadY = GFX_headY(ippant).doubgc;
                pidx= ceil(linspace(1,200,14));
            end
            
            
            subplot(1,2, itarg);
            yyaxis left
            ylim([0 1]);
            plot(plotHeadY); hold on
            yyaxis right
            bar(pidx(1:end-1), plotProb, 'FaceAlpha', 0.2)
            title(titles{itarg})
            ylabel(['Proportion correct'])
            ylim([0 1]);
            set(gca, 'fontsize', 15)
            sgtitle(subjIDs{ippant}, 'interpreter', 'none');
            
        end
        shg
        cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
        print([subjIDs{ippant} ' targs within ' gaittypes{nGaits_toPlot} ', proportion binned'], '-dpng');
    end % ppant
    
end % job
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
if job.plotGFX_targBinned==1 % concats and then plots.
    %%
    
    figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
    
    
    for itarg=1:2
        %extract data into matrix:
        [pD, pH]= deal([]);
        
        if nGaits_toPlot==1
            for ip=1:size(GFX_allbinned,2)
                pD(ip,:) = GFX_allbinned(itarg, ip).gc;
                pH(ip,:) = GFX_headY(ippant).gc;
            end
            pidx= ceil(linspace(1,100,7));
            
            shufftoplot = shuffData_toplot.gc;
        else
            for ip=1:size(GFX_allbinned,2)
                pD(ip,:) = GFX_allbinned(itarg, ip).doubgc;
                pH(ip,:) = GFX_headY(ippant).doubgc;
            end
            pidx= ceil(linspace(1,200,14));
            
            shufftoplot = shuffData_toplot.doubgc;
        end
        %% plot mean accuracy.
        subplot(1,2,itarg)
        bar(pidx(1:end-1), mean(pD,1), 'FaceAlpha', 0.2);
        stE= CousineauSEM(pD);
        hold on;
        
        errorbar(pidx(1:end-1), mean(pD,1), stE, 'linestyle', 'none');
        ylim([.5 1])
        ylabel('Accuracy')
        title(titles{itarg})
        
        
        % plot shuff likelihood for comp.
        upB = plot(pidx(1:end-1), squeeze(shufftoplot(itarg,1,:))', ['k:']);
        medB = plot(pidx(1:end-1), squeeze(shufftoplot(itarg,2,:)), ['k-']);
        lowB = plot(pidx(1:end-1), squeeze(shufftoplot(itarg,3,:)), ['k:']);
        rangep = squeeze(shufftoplot(itarg,3,:)) - squeeze(shufftoplot(itarg,1,:));
        %%
        shadedErrorBar(pidx(1:end-1), squeeze(shufftoplot(itarg,2,:)), rangep/2,[],1)
        
        %% plot mean head pos
        yyaxis right
        plot(nanmean(pH), ['k-o']); hold on
        set(gca, 'ytick', [], 'xtick', [], 'fontsize', 15)
        
    end
    
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
    print(['GFX targs within ' gaittypes{nGaits_toPlot} ', proportion binned'], '-dpng');
    
end
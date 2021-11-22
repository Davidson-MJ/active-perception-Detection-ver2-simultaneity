% plotj2_targClassification_winGait - %discrimination version (1 or 2
% flashes)

% loads the ppant data collated in j2_binData_bycycle.

%plots the position of correctly and incorrectly identified targets, per
%pariticpant, as a position of the gait cycle.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detection experiment (discrimination 1-2 flashes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% macbook
% datadir= '/Users/matthewdavidson/Documents/GitHub/active-perception-Detection-ver2-simultaneity/Analysis Code/Detecting ver 0/Raw_data';
% PC
datadir= 'C:\Users\User\Documents\matt\GitHub\active-perception-Detection-ver2-simultaneity\Analysis Code\Detecting ver 0\Raw_data';


%%
cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);

% how many gaits to plot?
nGaits_toPlot=2; % 1 or 2.

job.concat_GFX=0;
job.basicPermtest =0; %create null distribution for quick plot:

job.plot_targDistribution=0; % plot the incidence of all targs (correct, incorrect, and missed)
job.plot_targBinned=0; % single GC, binning into 7 regions to show proportion accuracy.

%%%%
job.plotGFX_targBinned=1; % note also calls on the results of basicPermtest.
job.plotGFX_targBinned_norm=1;
job.plotGFX_slidingAcc=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%data wrangling first: Concat, and create null distribution.
pidx1=ceil(linspace(1,100,8));
pidx2=ceil(linspace(1,200,16));

gaittypes = {'single gait' , 'double gait'};
titles={'Single flash', 'Double flash', 'all'};
%%
if job.concat_GFX
    dataIN=[];
%     GFX_allbinned=[];
    GFX_allbinned_Accuracy=[];
    GFX_sliding_Accuracy=[];
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
                pidx= pidx1;
                %set data for 1 and 2 flash case:
                use1cor= PFX_tHits_1flash;
                use1err = PFX_tMiss_1flash;
                use2corr = PFX_tHits_2flash;
                use2err = PFX_tMiss_2flash;
            else
                pidx=pidx2;
                
                use1cor= PFX_tHits_1flash_doubleGC;
                use1err = PFX_tMiss_1flash_doubleGC;
                use2corr = PFX_tHits_2flash_doubleGC;
                use2err = PFX_tMiss_2flash_doubleGC;
            end
            for nTarg=1:3
                if nTarg==1
                    tmpC= use1cor; % 1 corr.
                    tmpErr= use1err; % 1 err.
                elseif nTarg==2
                    tmpC= use2corr; % 2 corr.
                    tmpErr= use2err; % 2 err.
                elseif nTarg==3
                     tmpC= [use1cor; use2corr]; %combined.
                    tmpErr= [use1err;use2err]; %combined.
                end
                
                prop=[];
                for ibin=1:length(pidx)-1
                    idx = pidx(ibin):pidx(ibin+1);
                    
                    prop(ibin) = sum(nansum(tmpC(:,idx)))/ (  sum(nansum(tmpC(:,idx))) + sum(nansum(tmpErr(:,idx))));
                end
                %store across ppants.
                if nGait==1
                    GFX_allbinned_Accuracy(nTarg, ippant).gc = prop;
                else
                    GFX_allbinned_Accuracy(nTarg, ippant).doubgc = prop;
                end
                
                % also compute sliding accuracy:
                movingwin= [5,1]; % average over 10, step in 5.
                
                nsamps= size(tmpC,2);
                Nwin=movingwin(1); % number of samples in window
                Nstep=round(movingwin(2)); % number of samples to step through
                
                winstart=1:Nstep:nsamps-Nwin+1;
                nw=length(winstart);
                %%
                outgoing =zeros(1,nw);
                
                
                for n=1:nw
                    indx=winstart(n):winstart(n)+Nwin-1;
                
                    % compute acc over this window.
                    outgoing(n) = sum(nansum(tmpC(:,indx)))/ (  sum(nansum(tmpC(:,indx))) + sum(nansum(tmpErr(:,indx))));
                end
                
                
                if nGait==1
                    GFX_sliding_Accuracy(nTarg,ippant).gc = outgoing;
                    sliding_cntrpoints.gc=winstart;
                else
                    GFX_sliding_Accuracy(nTarg,ippant).doubgc = outgoing;
                    sliding_cntrpoints.doubgc=winstart;
                end
            end % itarg
        end % ntarg
        
    end % ppant
    dimsare = {'1flashcor', '2flashcor','1flasherr', '2flasherr', 'miss'};
    GFX_data= dataIN;
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    save('GFX_targClassification_inGaits', 'GFX_data', 'GFX_allbinned_Accuracy', 'GFX_sliding_Accuracy','GFX_headY', 'subjIDs');
else
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    load('GFX_targClassification_inGaits');
end
% job



%% perform (and save, perm data for comparison in GFX plots?
if job.basicPermtest
    %% quick one for now.
    %calculate the proportion per bin (double GC), if sampling from a random subset of samples each time.
    %concat d across ppnts.
    shuffData=[];
    shuffData_toplot=[];
      for nGait=1:2
    
        permDataOUT=[];
        permDataOUT_norm=[];
        permDataOUT_sliding=[];
    
        if nGait==1 % set bin indexing.
            pidx = pidx1;
            
        else
            pidx =pidx2;
        end
        
        
        for iperm=1:1000
            
            tmpProp=[];
            tmpProp_n=[];
            tmpAcc_sliding=[];
            for ippant=1:nsubs
                for itarg=1:3
                    if itarg==1
                        if nGait==1
                            tmpC= GFX_data(1,ippant).gc; % 1 corr.
                            tmpErr= GFX_data(3,ippant).gc; % 1 err.
                        else
                            tmpC= GFX_data(1,ippant).doubgc; % 1 corr.
                            tmpErr= GFX_data(3,ippant).doubgc; % 1 err.
                        end
                        
                    elseif itarg==2
                        if nGait==1
                            tmpC= GFX_data(2,ippant).gc; % 2 corr.
                            tmpErr= GFX_data(4,ippant).gc; % 2 err.
                        else
                            tmpC= GFX_data(2,ippant).doubgc; % 2 corr.
                            tmpErr= GFX_data(4,ippant).doubgc; % 2 err.
                        end
                        
                    elseif itarg==3 % combined data
                         if nGait==1
                            tmpC= [GFX_data(1,ippant).gc;GFX_data(2,ippant).gc]; % all corr.
                            tmpErr=[GFX_data(3,ippant).gc;GFX_data(4,ippant).gc];  % all err.
                        else
                            tmpC= [GFX_data(1,ippant).doubgc;GFX_data(2,ippant).doubgc]; % all corr.
                            tmpErr=[GFX_data(3,ippant).doubgc;GFX_data(4,ippant).doubgc];  % all err.
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
                    tmpProp_n(itarg,ippant,:) = prop ./ (mean(prop));
                    %% also compute sliding acc, as above.
                nsamps= size(tmpC,2);
                Nwin=movingwin(1); % number of samples in window
                Nstep=round(movingwin(2)); % number of samples to step through
                
                winstart=1:Nstep:nsamps-Nwin+1;
                nw=length(winstart);
                outgoing =zeros(1,nw);
                %what length indx (to randomize)
                n=1;
                 nind=length(winstart(n):winstart(n)+Nwin-1);
                 
                for n=1:nw
%                     indx=winstart(n):winstart(n)+Nwin-1;
                    indx = randi(100*nGait, [1,nind]);
                
                    % compute acc over this window.
                    outgoing(n) = sum(nansum(tmpC(:,indx)))/ (  sum(nansum(tmpC(:,indx))) + sum(nansum(tmpErr(:,indx))));
                end
                tmpAcc_sliding(itarg, ippant,:) = outgoing;
                
                    
                end% targ
            end % ppant
            % calc mean prop across ppants, this perm, and save:
            permDataOUT(iperm,:,:) = nanmean(tmpProp,2);                 
            permDataOUT_norm(iperm,:,:) = nanmean(tmpProp_n,2);                  
            permDataOUT_sliding(iperm,:,:) = nanmean(tmpAcc_sliding,2);
            disp(['Fin perm ' num2str(iperm) ' of 1000']);
        end % perm
        
        % for each position (bin), calculate the median, and uppwer and lower
        % bounds of the probability density function (used in next plot).
        
        [shufftoPlot, shufftoPlot_norm]= ...
            deal(zeros(2,3,size(permDataOUT,3))); % targs, [lower,med,upper], bins
        
        shufftoPlot_sliding= zeros(2,3,size(permDataOUT_sliding,3));
        
        for itarg=1:3
            for ibin = 1:size(permDataOUT,3)
                
                datadist= squeeze(permDataOUT(:,itarg,ibin));
                shufftoPlot(itarg,:,ibin) = quantile(datadist, [.05, .5, .95]);
                
                     
                datadist= squeeze(permDataOUT_norm(:,itarg,ibin));             
                shufftoPlot_norm(itarg,:,ibin) = quantile(datadist, [.05, .5, .95]);
            end
            
            
            for ibin = 1:size(permDataOUT_sliding,3)
                %sliding
                datadist= squeeze(permDataOUT_sliding(:,itarg,ibin));
                shufftoPlot_sliding(itarg,:, ibin) =  quantile(datadist, [.05, .5, .95]);
            end
            
        end
        
         %rename and save:
        if nGait==1
            shuffData.gc= permDataOUT;
            shuffData_toplot.gc = shufftoPlot;
            shuffData_toplot.gc_n = shufftoPlot_norm;
            shuffData_toplot.gc_sliding = shufftoPlot_sliding;
        else
            shuffData.doubgc= permDataOUT;
            shuffData_toplot.doubgc = shufftoPlot;
            shuffData_toplot.doubgc_n = shufftoPlot_norm;
            shuffData_toplot.doubgc_sliding = shufftoPlot_sliding;

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
        figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5  .5]);
        
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
clf
if job.plot_targBinned
    for ippant= 1:nsubs
        
        
        figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5  1]);
        
         titlesare={'1flash', '2flash', 'combined'};
        for itarg=1:3
            if nGaits_toPlot==1
                plotProb = GFX_allbinned_Accuracy(itarg, ippant).gc;
                plotHeadY = GFX_headY(ippant).gc;
                pidx= pidx1;
            else
                plotProb = GFX_allbinned_Accuracy(itarg, ippant).doubgc;
                plotHeadY = GFX_headY(ippant).doubgc;
                pidx= pidx2;
           
            end
            
            timevec = pidx(1:end-1);
            subplot(3,1,itarg)
            bar(timevec, plotProb, 'FaceAlpha', 0.2);
            ylabel(['Proportion correct'])
            sP= std(plotProb);
            mP= mean(plotProb);
            ylim([mP-4*sP mP+4*sP]);
            set(gca, 'fontsize', 15)
            sgtitle(subjIDs{ippant}, 'interpreter', 'none');
            
            yyaxis right
            ylim([0 1]);
            plot(plotHeadY); hold on
            %tidy axes.
            midp=timevec(ceil(length(timevec)/2));
            set(gca,'fontsize', 15, 'xtick', [1, midp, timevec(end)], 'XTickLabels', {'0', '50', '100%'})
            title(titlesare{itarg})
            shg
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
    
    figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5  1]);
    
    titlesare= {'1flash', '2flash', 'combined'};
    for itarg=1:3
        %extract data into matrix:
        [pD, pH]= deal([]);
        
        if nGaits_toPlot==1
            for ip=1:size(GFX_allbinned_Accuracy,2)
                pD(ip,:) = GFX_allbinned_Accuracy(itarg, ip).gc;
                pH(ip,:) = GFX_headY(ippant).gc;
            end
            pidx= pidx1;
             ylimsU= [.88 .97];
            shufftoplot = squeeze(shuffData_toplot.gc(itarg,:,:));
        else
            for ip=1:size(GFX_allbinned_Accuracy,2)
                pD(ip,:) = GFX_allbinned_Accuracy(itarg, ip).doubgc;
                pH(ip,:) = GFX_headY(ippant).doubgc;
            end
            pidx=pidx2;
                    ylimsU= [.8 1];

            shufftoplot = squeeze(shuffData_toplot.doubgc(itarg,:,:));
        end
        % plot mean head pos
    timevec=pidx(1:end-1); % xvector for data plots:
    
    
    subplot(3,1,itarg)
%     clf
    yyaxis right
    plot(1:length(pH),nanmean(pH), ['k-o']); hold on
    set(gca, 'ytick',[])
    title(titlesare{itarg})
    yyaxis left
    bar(timevec, mean(pD,1), 'FaceAlpha', 0.2);
    stE= CousineauSEM(pD);
    %%           set(gca, 'ytick', [0:.02:1], 'xtick', xts, 'xticklabels', {'0', '25', '50', '75', '100'}, 'fontsize', 15)
    hold on;
    
    errorbar(pidx(1:end-1), mean(pD,1), stE, 'linestyle', 'none', 'color', 'b', 'linew', 2);
    set(gca, 'fontsize', 25)
    ylabel('Accuracy')
 
    sP= std(mean(pD));
    mP= mean(mean(pD));
    ylim([mP-4*sP mP+4*sP]);
%     box off
    
    % plot shuff likelihood for comp.
    %%
    lowB = squeeze(shufftoplot(1,:))'; %lower boundary of 95% null
     upB = squeeze(shufftoplot(3,:))'; %upper boundary of 95% null     
    medB =squeeze(shufftoplot(2,:))';% median
    plot(timevec, upB, ['k:']);
     plot(timevec,medB, ['k-']);
   plot(timevec,lowB, ['k:']);
   % shade the region beween    
       ph= patch([timevec fliplr(timevec)], [ upB' fliplr(lowB')], [.8 .8 .8], 'FaceAlpha', .2);
%     ylim([ylimsU])
    legend(ph, {'H0: 95% CI'})
    end
    %%
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
    print(['GFX targs within ' gaittypes{nGaits_toPlot} ', proportion binned'], '-dpng');
    
end

if job.plotGFX_targBinned_norm==1 % concats and then plots.
 %%
    
    figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
    
    
    %extract data into matrix:
    [pD, pH]= deal([]);
    titlesare={'1flash', '2flash','combined'};
    plts=[1,2;3,4;5,6];
    for itarg=1:3
    if nGaits_toPlot==1
        for ip=1:size(GFX_allbinned_Accuracy,2)
            pD(ip,:) = GFX_allbinned_Accuracy(itarg, ip).gc ./ (mean( GFX_allbinned_Accuracy( itarg,ip).gc));
            pH(ip,:) = GFX_headY(ip).gc;
        end
        pidx= pidx1;
        
        shufftoplot = squeeze(shuffData_toplot.gc_n(itarg,:,:));
    else
        for ip=1:size(GFX_allbinned_Accuracy,2)
            pD(ip,:) =  GFX_allbinned_Accuracy(itarg, ip).doubgc ./ (mean( GFX_allbinned_Accuracy(itarg, ip).doubgc));
            pH(ip,:) = GFX_headY(ip).doubgc;
        end
        pidx= pidx2;
        
        shufftoplot = squeeze(shuffData_toplot.doubgc_n(itarg,:,:));
    end
    %% plot mean accuracy.
%     clf
    for is=1:2
        if is==2
            plotd= pD-1; % shows change rel to mean .
            ylimsU=[-.04 .04];
shufftoplot= shufftoplot-1;
        else
            plotd=pD;
            ylimsU=[.8 1.2];
        end
        %%       
        subplot(3,2,plts(itarg,is));
        
         yyaxis left
        mPD= mean(plotd,1);
        %% arrange to baseline:
        timevec= pidx(1:end-1);
        bar(timevec,mPD, 'FaceAlpha', 0.2); hold on;
        stE= CousineauSEM(plotd);
        errorbar(timevec, mPD, stE, 'linestyle', 'none'); %steM
       plot(xlim, [0, 0], ['k-'])
        %%
        ylabel('normalized Accuracy')
        medCI= squeeze(shufftoplot(2,:));
        upCI=squeeze(shufftoplot(3,:));
        lowCI=squeeze(shufftoplot(1,:));
        % plot shuff likelihood for comp.
        plot(timevec, lowCI, ['k:']);
        plot(timevec,medCI , ['k-']);
        plot(timevec, upCI, ['k:']);
        
        
    sP= std(mPD);
    mP= mean(mPD);
    ylim([mP-4*sP mP+4*sP]);
        % fill patch
        ph= patch([timevec fliplr(timevec)], [ upCI fliplr(lowCI)], [.8 .8 .8], 'FaceAlpha', .2);
        %% add dist from median shuff?
%         hold on
%         for ip= 1:length(pD)
%             plot([pidx(ip) pidx(ip) ], [medCI(ip) mPD(ip)], ['b:'], 'linew',3)
%         end
%         
        yyaxis right % add  head pos
       hh= plot(nanmean(pH), ['k-o']); hold on
        ylabel('head height')
    title(titlesare{itarg})    
          legend([ph hh], {'H0: 95% CI', 'head pos (Y)'})
          midp=timevec(ceil(length(timevec)/2));
          set(gca,'fontsize', 15, 'xtick', [1, midp, timevec(end)], 'XTickLabels', {'0', '50', '100%'})
    end
    
    
    end % targ

    %%
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
    print(['GFX targs within ' gaittypes{nGaits_toPlot} ', proportion binned (normalized)'], '-dpng');
end

if job.plotGFX_slidingAcc % note also calls on the results of basicPermtest.

    
    
    figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5  1]);
    
    
    %extract data into matrix:
    [pD, pH]= deal([]);
    titlesare= {'1flash', '2flash', 'combined'};
    for itarg=3
        
    if nGaits_toPlot==1
        for ip=1:size(GFX_sliding_Accuracy,2)
            pD(ip,:) = GFX_sliding_Accuracy(itarg, ip).gc ;
            pH(ip,:) = GFX_headY(ip).gc;
        end
        pidx= pidx1;
        timevec = sliding_cntrpoints.gc;
        
        shufftoplot = squeeze(shuffData_toplot.gc_sliding(itarg,:,:));

    else
        for ip=1:size(GFX_allbinned_Accuracy,2)
            pD(ip,:) =  GFX_sliding_Accuracy(itarg, ip).doubgc ;
            pH(ip,:) = GFX_headY(ip).doubgc;
        end
        pidx= pidx2;
        timevec = sliding_cntrpoints.doubgc;
        shufftoplot = squeeze(shuffData_toplot.doubgc_sliding(itarg,:,:));
    end
   %%
    subplot(211);
        plot(nanmean(pH), ['k-o']); hold on
        set(gca, 'ytick', [], 'xtick', [], 'fontsize', 15)

        subplot(212)
%         yyaxis left
       
         mPD= mean(pD,1);
        stE= CousineauSEM(pD);
        sh=shadedErrorBar(timevec,mPD, stE,['b-'],1);   
        sh.mainLine.LineWidth=3;
        hold on;
        axis tight;
        
        ylabel('Accuracy')
%         title('Target detection')
        
%         %%
        % plot shuff likelihood for comp.
        lowerCI=squeeze(shufftoplot(1,:))';
        upperCI=squeeze(shufftoplot(3,:))';
        medCI=squeeze(shufftoplot(2,:))';
         
        upB = plot(timevec, upperCI, ['k:']);
        medB = plot(timevec, medCI, ['k-']);
        lowB = plot(timevec, lowerCI, ['k:']);
     %
       ph=  patch([timevec fliplr(timevec)], [ upperCI' fliplr(lowerCI')], [.8 .8 .8], 'FaceAlpha', .2);
        title(titlesare{itarg})
       legend([sh.mainLine, ph], {'meanAcc', 'H0: 95% CI'})
    end
    %%
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
    print(['GFX targs within ' gaittypes{nGaits_toPlot} ', sliding accuracy'], '-dpng');
end
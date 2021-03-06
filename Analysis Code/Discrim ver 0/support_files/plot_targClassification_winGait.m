% plotj2_targClassification_winGait

% loads the ppant data collated in j2_binData_bycycle.

%plots the position of correctly and incorrectly identified targets, per
%pariticpant, as a position of the gait cycle.

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

job.plotGFX_targBinned_norm=0; % note also calls on the results of basicPermtest.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%data wrangling first: Concat, and create null distribution.
pidx1=ceil(linspace(1,100,6));
pidx2=ceil(linspace(1,200,10));
gaittypes = {'single gait' , 'double gait'};
%% %%

if job.concat_GFX
    %%
    dataIN=[];
    GFX_allbinned_Accuracy=[];
    GFX_allbinned_dprime=[];
    GFX_headY=[];
    GFX_Acc=[];
    subjIDs={};
    for ippant = 1:nsubs
        cd([datadir filesep 'ProcessedData'])    %%load data from import job.
        load(pfols(ippant).name, ...
            'PFX_tHits_1flash', 'PFX_tHits_2flash',...
            'PFX_tMiss_1flash', 'PFX_tMiss_2flash',...
            'PFX_tHits_1flash_doubleGC', 'PFX_tHits_2flash_doubleGC',...
            'PFX_tMiss_1flash_doubleGC', 'PFX_tMiss_2flash_doubleGC',...
            'PFX_tNoresp','PFX_tNoresp_doubleGC', ...
            'PFX_headY', 'PFX_headY_doubleGC', 'calibAcc', 'subjID');
        
        subjIDs{ippant} = subjID;
      
    dataIN(1,ippant).gc = PFX_tHits_1flash;
    dataIN(2,ippant).gc = PFX_tHits_2flash;
    dataIN(3, ippant).gc = PFX_tMiss_1flash;    
    dataIN(4, ippant).gc = PFX_tMiss_2flash;
    dataIN(5,ippant).gc = PFX_tNoresp;
    
    dataIN(1,ippant).doubgc = PFX_tHits_1flash_doubleGC;
    dataIN(2,ippant).doubgc = PFX_tHits_2flash_doubleGC;
    dataIN(3, ippant).doubgc = PFX_tMiss_1flash_doubleGC;    
    dataIN(4, ippant).doubgc = PFX_tMiss_2flash_doubleGC;
    dataIN(5,ippant).doubgc = PFX_tNoresp_doubleGC;
        
        
        % mean head pos:
        
        GFX_headY(ippant).gc = nanmean(PFX_headY);
        
        GFX_headY(ippant).doubgc = nanmean(PFX_headY_doubleGC);
        
        
        % calculate proportions for easy plotting later:
        for iTarg=1:3
        for nGait=1:2
            if nGait==1
                pidx= pidx1;
                %set data for 1 and 2 flash case:
                if iTarg==1
                use1cor= PFX_tHits_1flash;
                use1err = PFX_tMiss_1flash;
                elseif iTarg==2
                    use1cor= PFX_tHits_2flash;
                use1err = PFX_tMiss_2flash;
                elseif iTarg==3 % combined!
                    use1cor = [PFX_tHits_1flash; PFX_tHits_2flash];                    
                    use1err = [PFX_tMiss_1flash; PFX_tMiss_2flash];
                end
            else
                pidx= pidx2;
                if iTarg==1
                use1cor= PFX_tHits_1flash_doubleGC;
                use1err = PFX_tMiss_1flash_doubleGC;
                elseif iTarg==2
                    use1cor= PFX_tHits_2flash_doubleGC;
                use1err = PFX_tMiss_2flash_doubleGC;
                elseif iTarg==3
                     use1cor = [PFX_tHits_1flash_doubleGC; PFX_tHits_2flash_doubleGC];                    
                    use1err = [PFX_tMiss_1flash_doubleGC; PFX_tMiss_2flash_doubleGC];
                end
                
            end
           
            
                
                prop=[];
                for ibin=1:length(pidx)-1
                    idx = pidx(ibin):pidx(ibin+1);
                    
                    prop(ibin) = sum(nansum(use1cor(:,idx)))/ (  sum(nansum(use1cor(:,idx))) + sum(nansum(use1err(:,idx))));
                end
                %store across ppants.
                if nGait==1
                    GFX_allbinned_Accuracy(iTarg,ippant).gc = prop;
                else
                    GFX_allbinned_Accuracy(iTarg,ippant).doubgc = prop;
                end
                
            
        end % nGait
        end % iTarg
%   
        
        
    end % ppant
    dimsare = {'1correct', '2correct', '1err', '2err', 'Noresp'};
    GFX_data= dataIN;
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    save('GFX_targClassification_inGaits', 'GFX_data', 'GFX_allbinned', 'GFX_headY', 'subjIDs', '-append');
else
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    load('GFX_targClassification_inGaits');
end
% job
%%


%% perform (and save, perm data for comparison in GFX plots?
if job.basicPermtest
    %% quick one for now. calculate the proportion per bin (double GC), if sampling from a random subset of samples each time.
    %concat d across ppnts.
    shuffData=[];
    shuffData_toplot=[];
    
    for nGait=1:2
        permDataOUT=[];
        permDataOUT_norm=[];
        if nGait==1 % set bin indexing.
            pidx = pidx1;
        else
            pidx = pidx2;
            
        end
        
        for iTarg=1:3
            for iperm=1:1000
            tmpProp=[];
             tmpProp_n=[];
            for ippant=1:nsubs
                
                if nGait==1
                    if iTarg==1
                        tmpC= GFX_data(1,ippant).gc; % 1 corr.
                        tmpErr= GFX_data(3,ippant).gc; % 1 err.
                    elseif iTarg==2
                        tmpC= GFX_data(2,ippant).gc; % 2 corr.
                        tmpErr= GFX_data(4,ippant).gc; % 2 err.
                    elseif iTarg==3% combined
                        tmpC= [GFX_data(1,ippant).gc; GFX_data(2,ippant).gc];
                        
                        tmpE= [GFX_data(3,ippant).gc; GFX_data(4,ippant).gc];
                    end
                        
                else
                    if iTarg==1
                        tmpC= GFX_data(1,ippant).doubgc; % 1 corr.
                        tmpErr= GFX_data(3,ippant).doubgc; % 1 err.
                    elseif iTarg==2
                        tmpC= GFX_data(2,ippant).doubgc; % 2 corr.
                        tmpErr= GFX_data(4,ippant).doubgc; % 2 err.
                    
                    elseif iTarg==3% combined
                        tmpC= [GFX_data(1,ippant).doubgc; GFX_data(2,ippant).doubgc];
                        
                        tmpE= [GFX_data(3,ippant).doubgc; GFX_data(4,ippant).doubgc];
                    end
                        
                end
                
                prop=[];
                
                for ibin=1:length(pidx)-1
                    % choose points at random!
                    %idx = pidx(ibin):pidx(ibin+1);
                    idx = randi(100*nGait, [1,16]);
                    
                    prop(ibin) = sum(nansum(tmpC(:,idx)))/ ( sum(nansum(tmpC(:,idx))) + sum(nansum(tmpErr(:,idx))));
                end
                tmpProp(ippant,:) = prop;
                tmpProp_n(ippant,:) = prop ./ (mean(prop));
                
            end % ppant
            
            % calc mean prop across ppants, this perm, and save:
            permDataOUT(iperm,iTarg,:) = nanmean(tmpProp,1);            
            permDataOUT_norm(iperm,iTarg,:) = nanmean(tmpProp_n,1);
            
            disp(['Fin perm ' num2str(iperm) ' of 1000']);
        end % perm
        
      end % both targ types
      
      % for each position (bin), calculate the median, and upper and lower
        % bounds of the probability density function (used in next plot).
        
        [shufftoPlot, shufftoPlot_norm]= deal(zeros(3,2,size(permDataOUT,2))); % [lower,med,upper], targs, bins
          
        
        for iTarg=1:3
        %% now save both.
            for ibin = 1:size(permDataOUT,3)
                %
                datadist= squeeze(permDataOUT(:,iTarg,ibin));
                shufftoPlot(:,iTarg,ibin) = quantile(datadist, [.05, .5, .95]);
                %% normd
                datadist= squeeze(permDataOUT_norm(:,iTarg,ibin));
                
                shufftoPlot_norm(:,iTarg,ibin) = quantile(datadist, [.05, .5, .95]);
                
            end
        end % iTarg
        %rename and save:
        if nGait==1
            shuffData.gc= permDataOUT;
            shuffData_toplot.gc = shufftoPlot;
            shuffData_toplot.gc_n = shufftoPlot_norm;
        else
            shuffData.doubgc= permDataOUT;
            shuffData_toplot.doubgc = shufftoPlot;
            shuffData_toplot.doubgc_n = shufftoPlot_norm;
        end
        
    end % NGait
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    save('GFX_targClassification_inGaits','shuffData', 'shuffData_toplot', '-append');
end % basic perm test job
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if job.plot_targDistribution==1
    %% figure:
    for ippant=1
        
    figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
  
       if nGaits_toPlot==1
            corrD= GFX_data(1, ippant).gc; %1 flash cor
            errD = GFX_data(3, ippant).gc; % 1 flash err
            corrD2= GFX_data(2, ippant).gc; %2 flash cor
            errD2 = GFX_data(4, ippant).gc; % 2 flash err               plotHead = GFX_headY(ippant).gc;
        else
           corrD= GFX_data(1, ippant).doubgc; %1 flash cor
            errD = GFX_data(3, ippant).doubgc; % 1 flash err
            corrD2= GFX_data(2, ippant).doubgc; %2 flash cor
            errD2 = GFX_data(4, ippant).doubgc; % 2 flash err                  
            
            plotHead = GFX_headY(ippant).doubgc;
        end
    
    % convert for histogram.
    hleg=[];
    counts=[];
    clf
    for itype=1:4
        switch itype
            case 1
                sampSum = sum(corrD);
                 col='g';
            case 2
                sampSum = sum(errD);
                 col='r';
            case 3
                sampSum= sum(corrD2);
                 col='g';
            case 4
                sampSum= sum(errD2);
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
            if itype<3
%                 subplot(121)
            else
%                 subplot(122)
            end
            % Head height as background:
            hold on;
            yyaxis left
            plot(plotHead, ['k-o']); hold on
             set(gca,'ytick', []);
            
            % now data:
            yyaxis right
            hg= histogram(hist_Data, length(sampSum), 'FaceColor', col );
            %             title(titlesare{itype});
            hleg(itype)= hg;
            counts(itype) = length(hist_Data);
            
            title('Discrimination');
                box off
            set(gca,'ytick', [], 'xtick', [0 25 50 75 100], 'fontsize', 15);
            
            xlabel( '% of gait-cycle')
        end
        legend([hleg(1), hleg(2), hleg(3)], {['Hit (' num2str(counts(1)) ')'],...
            ['Miss (' num2str(counts(2)) ')'], ['False alarms (' num2str(counts(3)) ')'] });
        
   
    %% subjID:
    sgtitle(subjIDs{ippant}, 'interpreter', 'none')
    
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
    
    print([subjIDs{ippant} ' targs within ' gaittypes{nGaits_toPlot} ],'-dpng');
    end % ppant;
end
%%
if job.plot_targBinned
   for ippant= 1:nsubs
        
        
        figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
        
        titles={'Single flash', 'Double flash'};
        for iTarg=1:2
            if nGaits_toPlot==1
                plotProb = GFX_allbinned_Accuracy(iTarg,ippant).gc;
                plotHeadY = GFX_headY(ippant).gc;
                pidx= pidx1;
            else
                plotProb = GFX_allbinned_Accuracy(iTarg,ippant).doubgc;
                plotHeadY = GFX_headY(ippant).doubgc;
                pidx= pidx2;
            end
        
        subplot(1,2,iTarg);
        yyaxis left
        ylim([0 1]);
        plot(plotHeadY); hold on
        yyaxis right
        bar(pidx(1:end-1), plotProb, 'FaceAlpha', 0.2)
        
        ylabel(['Proportion correct'])
        ylim([0 1]);
        set(gca, 'fontsize', 15)
        sgtitle(subjIDs{ippant}, 'interpreter', 'none');
        title(titles{iTarg})
        end
        %%
        shg
        cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
        print([subjIDs{ippant} ' targs within ' gaittypes{nGaits_toPlot} ', proportion binned'], '-dpng');
    end % ppant
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
if job.plotGFX_targBinned==1 % concats and then plots.
    %%
    GFX_allbinned_Accuracy= GFX_allbinned;
    figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
    
 titles={'Single Flash', 'Double Flash', 'Discrimination'};
        %extract data into matrix:
        [pD, pH]= deal([]);
          ylimsU(1,:)= [.76 .95];          
          ylimsU(2,:)= [.55 .75];
          ylimsU(3,:)= [.65 .85];
        for iTarg=3%1:2
            
        if nGaits_toPlot==1
            for ip=1:size(GFX_allbinned_Accuracy,2)
                pD(ip,:) = GFX_allbinned_Accuracy(iTarg, ip).gc;
                pH(ip,:) = GFX_headY(ip).gc;
            end
            pidx= pidx1;
          
            xts= [0:25:100];
            shufftoplot = shuffData_toplot.gc;
        else
            for ip=1:size(GFX_allbinned_Accuracy,2)
                pD(ip,:) = GFX_allbinned_Accuracy(iTarg,ip).doubgc;
                pH(ip,:) = GFX_headY(ip).doubgc;
            end
            pidx= pidx2;
            
            xts= [0:25:200];
            shufftoplot = shuffData_toplot.doubgc;
        end
              % plot mean head pos
% subplot(1,2,iTarg)
yyaxis right
plot(nanmean(pH), ['k-o']); hold on
      set(gca, 'ytick',[])
%         axis off 

    
        % plot mean accuracy.
% subplot(212)
yyaxis left
        bar(xts, mean(pD,1), 'FaceAlpha', 0.2);
        stE= CousineauSEM(pD);
%           set(gca, 'ytick', [0:.02:1], 'xtick', xts, 'xticklabels', {'0', '25', '50', '75', '100'}, 'fontsize', 15)
        hold on;
        
        errorbar(xts, mean(pD,1), stE, 'linestyle', 'none', 'color', 'b', 'linew', 2);
        set(gca, 'fontsize', 25)
%         ylim([.5 1])
        ylabel('Accuracy')
%         title('Target detection')
        ylim([ylimsU(iTarg,:)])
        box off
        
%         % plot shuff likelihood for comp.
%         upB = plot(pidx(1:end-1), squeeze(shufftoplot(1,:))', ['k:']);
%         medB = plot(pidx(1:end-1), squeeze(shufftoplot(2,:)), ['k-']);
%         lowB = plot(pidx(1:end-1), squeeze(shufftoplot(3,:)), ['k:']);
%         rangep = squeeze(shufftoplot(3,:)) - squeeze(shufftoplot(1,:));
%         %%
%         shadedErrorBar(pidx(1:end-1), squeeze(shufftoplot(2,:)), rangep/2,[],1)
        title(titles{iTarg})
        set(gca, 'xtick', [])
        end % iTarg
    %%
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
    print(['GFX targs within ' gaittypes{nGaits_toPlot} ', proportion binned'], '-dpng');
    
end

%% %%

if job.plotGFX_targBinned_norm==1 % concats and then plots.
    %%
    
    figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
    
    
        %extract data into matrix:
        [pD, pH]= deal([]);
        for iTarg=3
        if nGaits_toPlot==1
            for ip=1:size(GFX_allbinned_Accuracy,2)
                pD(ip,:) = GFX_allbinned_Accuracy(iTarg, ip).gc ./ (mean( GFX_allbinned_Accuracy( ip).gc));
                pH(ip,:) = GFX_headY(ip).gc;
            end
            pidx= pidx1;
            
            shufftoplot = shuffData_toplot.gc_n;
        else
            for ip=1:size(GFX_allbinned_Accuracy,2)
                pD(ip,:) =  GFX_allbinned_Accuracy( iTarg,ip).doubgc ./ (mean( GFX_allbinned_Accuracy( ip).doubgc));
                pH(ip,:) = GFX_headY(ip).doubgc;
            end
            pidx= pidx2;
            
            shufftoplot = shuffData_toplot.doubgc_n;
        end
        %% plot mean accuracy.
        clf
%         subplot(211); % headpos        
        plot(nanmean(pH), ['k-o']); hold on
        set(gca, 'ytick', [], 'xtick', [], 'fontsize', 15)
        axis off ; box off
        %
        % normalized per ppant
%         for ip
% subplot(212);
yyaxis right
mPD= mean(pD,1);
        plot(pidx(1:end-1), mean(pD,1), 'bo', 'linew', 4);
       
%         stE= CousineauSEM(pD);
        hold on;
        axis off;
        
        %%
%         errorbar(pidx(1:end-1), mean(pD,1), stE, 'linestyle', 'none');
%         ylim([.5 1])
        ylabel('Accuracy')
%         title('Target detection')
        
%         %%
        % plot shuff likelihood for comp.
%         upB = plot(pidx(1:end-1), squeeze(shufftoplot(1,:))', ['k:']);
%         medB = plot(pidx(1:end-1), squeeze(shufftoplot(2,:)), ['k-']);
%         lowB = plot(pidx(1:end-1), squeeze(shufftoplot(3,:)), ['k:']);
        rangep = squeeze(shufftoplot(3,iTarg,:)) - squeeze(shufftoplot(1,iTarg,:));
        %%
        mShuff= squeeze(shufftoplot(2,iTarg,:))+.02;
        shadedErrorBar(pidx(1:end-1),mShuff , rangep/2,[],1)
        %%
         hold on
        for ip= 1:length(pD)
        plot([pidx(ip) pidx(ip) ], [mShuff(ip) mPD(ip)], ['b:'], 'linew',3)
        end
        %%
        ylim([.94 1.08])
        
        end
    %%
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
%     print(['GFX targs within ' gaittypes{nGaits_toPlot} ', proportion binned'], '-dpng');
%%
figure(2);

clf; histogram(permDataOUT(:,1), 100, 'FaceColor', [.2 .2 .2]);
box off
axis off
axis xy
shg
% hg.FaceColor= [.3 .3 .3];
end
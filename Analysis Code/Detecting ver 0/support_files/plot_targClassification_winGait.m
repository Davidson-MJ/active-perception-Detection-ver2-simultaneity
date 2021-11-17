% plotj2_targClassification_winGait

% loads the ppant data collated in j2_binData_bycycle.

%plots the position of correctly and incorrectly identified targets, per
%pariticpant, as a position of the gait cycle.

cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);

job.plot_targDistribution=0;
job.plot_targDistribution_doubleGC=1;
job.plot_targBinned=0;
allbinned=[];
%%%%
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name); 
    
    
if job.plot_targDistribution==1
    %% figure:
    figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
   yyaxis left
    plot(nanmean(PFX_headY));
    hold on;
    % convert counts per trial, for histogram plots:
    dataIN=[];
    dataIN(1).d = PFX_tHits_1flash;
    dataIN(2).d = PFX_tHits_2flash;
    dataIN(3).d = PFX_tMiss_1flash;
    dataIN(4).d = PFX_tMiss_2flash;
    dataIN(5).d = PFX_tNoresp;
    lspecs = {'g-', 'g-', 'r-' ,'k-', 'm-'};
    %
    hleg=[];
    counts=[];
    titlesare={'overlayed', '1 cor', '2 cor', '1 as 2', '2 as 1', 'miss'};
    for itype=1:5
        
        sampSum = sum(dataIN(itype).d,1);
        %convert to counts for histogram:
        hist_Data=[];
        for id=1:100
            if sampSum(id)>0
                tmp = repmat(id, 1, sampSum(id));
                hist_Data =[ hist_Data, tmp];
            end
        end
        
        subplot(2,3,1); hold on;
        yyaxis left
        plot(nanmean(PFX_headY)); hold on
        yyaxis right
        usespecs= lspecs{itype};        
         hg= histogram(hist_Data, 100, 'FaceColor', usespecs(1) , 'LineStyle', usespecs(2));
       title(titlesare{1});
        hleg(itype)= hg;
        counts(itype) = length(hist_Data);
        
        subplot(2,3, 1+itype); hold on;
        yyaxis left
         plot(nanmean(PFX_headY)); 
          hold on;
        yyaxis right
        hg= histogram(hist_Data, 100, 'FaceColor', usespecs(1) , 'LineStyle', usespecs(2));
            title(titlesare{itype+1})
    end
    legend([hleg(1), hleg(3), hleg(4), hleg(5)],...
        {['corr(' num2str(counts(1)+counts(2)) ')'],...
        ['1p2(' num2str(counts(3)) ')'], ['2p1(' num2str(counts(4)) ')'],...
        ['M(' num2str(counts(5)) ')']});
    
%     title(pfols(ippant).name, 'interpreter', 'none');
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
    print([subjID ' targs within gait'],'-dpng');
end

if job.plot_targDistribution_doubleGC==1
    %% figure:
    figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
   yyaxis left
    plot(nanmean(PFX_headY_doubleGC));
    hold on;
    % convert counts per trial, for histogram plots:
    dataIN=[];
    dataIN(1).d = PFX_tHits_1flash_doubleGC;
    dataIN(2).d = PFX_tHits_2flash_doubleGC;
    dataIN(3).d = PFX_tMiss_1flash_doubleGC;
    dataIN(4).d = PFX_tMiss_2flash_doubleGC;
    dataIN(5).d = PFX_tNoresp_doubleGC;
    lspecs = {'g-', 'g-', 'r-' ,'k-', 'm-'};
    %
    hleg=[];
    counts=[];
    titlesare={'overlayed', '1 cor', '2 cor', '1 as 2', '2 as 1', 'miss'};
    for itype=1:5
        
        sampSum = sum(dataIN(itype).d,1);
        %convert to counts for histogram:
        hist_Data=[];
        for id=1:size(PFX_tHits_1flash_doubleGC,2)
            if sampSum(id)>0
                tmp = repmat(id, 1, sampSum(id));
                hist_Data =[ hist_Data, tmp];
            end
        end
        
        subplot(2,3,1); hold on;
        yyaxis left
        plot(nanmean(PFX_headY_doubleGC)); hold on
        yyaxis right
        usespecs= lspecs{itype};        
         hg= histogram(hist_Data, 100, 'FaceColor', usespecs(1) , 'LineStyle', usespecs(2));
       title(titlesare{1});
        hleg(itype)= hg;
        counts(itype) = length(hist_Data);
        
        subplot(2,3, 1+itype); hold on;
        yyaxis left
         plot(nanmean(PFX_headY_doubleGC)); 
          hold on;
        yyaxis right
        hg= histogram(hist_Data, 100, 'FaceColor', usespecs(1) , 'LineStyle', usespecs(2));
            title(titlesare{itype+1})
    end
    legend([hleg(1), hleg(3), hleg(4), hleg(5)],...
        {['corr(' num2str(counts(1)+counts(2)) ')'],...
        ['1p2(' num2str(counts(3)) ')'], ['2p1(' num2str(counts(4)) ')'],...
        ['M(' num2str(counts(5)) ')']});
    
%     title(pfols(ippant).name, 'interpreter', 'none');
    cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
    print([subjID ' targs within gait'],'-dpng');
end

if job.plot_targBinned
%% calculate proportions per binned section.
bins=[1:25; 26:50; 51:75; 76:100];
pidx= ceil(linspace(1,100,7));
Staircaseresult= num2str(calibAcc(end));
    
figure(2); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
used=[1,3; 2,4];
for itarg=1:2
    if itarg==1
    tmpC= sum(dataIN(1).d,1); % 1 corr.
    tmpErr= sum(dataIN(3).d,1); % 1 err.
    else
         tmpC= sum(dataIN(2).d,1); % 1 corr.
    tmpErr= sum(dataIN(4).d,1); % 1 err.
    end
        
    prob=[];
for ibin=1:length(pidx)-1
    idx = pidx(ibin):pidx(ibin+1);
    
    prop(ibin) = sum(tmpC(idx))/ (sum(tmpC(idx)) + sum(tmpErr(idx)));
end

subplot(2, 1, itarg);
yyaxis left
ylim([0 1]);
plot(nanmean(PFX_headY)); hold on
yyaxis right
bar(pidx(1:end-1), prop, 'FaceAlpha', 0.2)
title([num2str(itarg) ' flashes']) 
ylabel(['Proportion correct'])
ylim([0 1]);

if itarg==2
allbinned= [allbinned;prop];
end
end
shg


end

cd([datadir filesep  'Figures' filesep 'TargClass_withinGait'])
print([subjID ' targs within gait binned'], '-dpng');
end % ppant
%%
figure(3); clf
bar(pidx(1:end-1), mean(allbinned,1), 'FaceAlpha', 0.2);
stE= std(allbinned)/ sqrt(size(allbinned,1)-1);
hold on;
errorbar(pidx(1:end-1), mean(allbinned,1), stE);
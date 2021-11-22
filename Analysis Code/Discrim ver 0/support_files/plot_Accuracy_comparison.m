% plotAccuracy_comparison - simultaneity version

% simple comparison of performance in calibration vs walking.



cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);
%%
job.concatPFX=1;
job.plotPFX=1;
job.plotGFX=0;

if job.concatPFX
   
    GFX_calibAcc=[];    
    GFX_calibGap=[];
    GFX_targAcc_walking=[];
    
   for ippant=1:nsubs
        
       cd([datadir filesep 'ProcessedData'])    %%load data from import job.
        load(pfols(ippant).name, 'calibData', 'calibAcc', 'calibGap', 'rawSummary_table'); 
         GFX_calibAcc(ippant,:)=calibAcc(end);    
         GFX_calibGap(ippant,:) = calibGap(end);
         
         %find performance in walk portion:
         %remaining trials:
         expts = find(rawSummary_table.isPrac==0);
         trialcor = rawSummary_table.targCor(expts);
         
         trialtype = rawSummary_table.targFlash(expts);
         
         % compare 1 and 2 t
         t1dat = trialcor(trialtype<2);
         t2dat = trialcor(trialtype==2);
         barD = [sum(t1dat)/length(t1dat), sum(t2dat)/length(t2dat)];
         
         GFX_targAcc_walking(ippant,:) = barD; 
   end
   cd('GFX')
   save('GFX_calibration&Accuracy_comparison', 'GFX_calibAcc', 'GFX_calibGap',...
       'GFX_targAcc_walking');
end
%%
if job.plotPFX
    %%
    if ~exist('GFX_calibAcc', 'var')
         cd([datadir filesep 'ProcessedData' filesep 'GFX']) 
         load('GFX_calibration&Accuracy_comparison');
    end
    %%
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name, 'calibData', 'calibAcc', 'calibGap','subjID');
    
    figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5 .5]);
%     calib
    subplot(1,2,1) % plot calibration data
    plot(1:length(calibData), calibAcc)
    ylabel('Accuracy');
    ylim([.5 1]);
    yyaxis right
    plot(1:length(calibData), calibGap)
    ylabel('flash gap (sec)');
    xlabel('2flash presented (count)')
    title({['Final acc: ' num2str(calibAcc(end)) ];['t=' num2str(calibGap(end)) 'sec']})
    
    set(gca,'fontsize', 15)
    barD = GFX_targAcc_walking(ippant,:);
    
    subplot(122);
    bar(barD);
    title('Accuracy when walking');
    set(gca, 'xticklabels', {'1 target case', '2 target case'});
    hold on;
    hl=plot(xlim , [calibAcc(end) calibAcc(end)], 'k:');
    ylim([0 1]);
    ylabel('Accuracy')
    legend(hl, 'calibrated acc');
    title(['participant: ' subjID], 'interpreter', 'none')
    
    set(gca,'fontsize', 15)
    cd([datadir filesep 'Figures' filesep 'Calibration'])
    shg
    print([subjID  ' calibration'], '-dpng');
end
end % PFX job.
%%
if job.plotGFX
    if ~exist('GFX_calibAcc', 'var')
         cd([datadir filesep 'ProcessedData' filesep 'GFX']) 
         load('GFX_calibration&Accuracy_comparison');
    end 
    
    figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5 .5]);
 mBar= mean(GFX_targAcc_walking,1);
 stE=CousineauSEM(GFX_targAcc_walking);
 
bar(mBar); hold on; 
errorbar(1:2, mBar, stE, 'Linestyle', 'none');
hold on
ylim([0 1])
    title('Accuracy comparison');
    set(gca, 'xticklabels', {'1 target case', '2 target case'});
  
    set(gca,'fontsize', 15)
    cd([datadir filesep 'Figures' filesep 'Calibration'])
        print([' GFX Accuracy x nTargs (walking)'], '-dpng');

    shg
end

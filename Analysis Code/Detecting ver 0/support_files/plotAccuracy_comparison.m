% plotAccuracy_comparison

% simple comparison of performance in calibration vs walking.



cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);


nPracticetrials= [20,40,40,40];
%% %%
for ippant = 1%:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name, 'calibData', 'calibAcc', 'calibGap'); 
    clf
    subplot(1,2,1) % plot calibration data
    plot(1:length(calibData), calibAcc)
    ylabel('Accuracy');
    ylim([.5 1]);
    yyaxis right
    plot(1:length(calibData), calibGap)
    ylabel('flash gap (sec)');
    xlabel('2flash presented (count)')
    title(['Final acc: ' num2str(calibAcc(end)) ', t=' num2str(calibGap(end)) 'sec'])
    
    set(gca,'fontsize', 15)
    %remaining trials:
    expts = rawSummary_table.trial>nPracticetrials(ippant);
    trialcor = rawSummary_table.targCor(expts);
    
    trialtype = rawSummary_table.targFlash(expts);
    
    % compare 1 and 2 t
    t1dat = trialcor(trialtype<2);
    t2dat = trialcor(trialtype==2);
    barD = [sum(t1dat)/length(t1dat), sum(t2dat)/length(t2dat)];

       subplot(122);
      bar(barD);
      title('Accuracy when walking');
      set(gca, 'xticklabels', {'1 target case', '2 target case'});
      hold on;
      hl=plot(xlim , [calibAcc(end) calibAcc(end)], 'k:');
      ylim([0 1]);
      ylabel('Accuracy')
      legend(hl, 'calibrated acc');
      title(['participant: ' pfols(ippant).name], 'interpreter', 'none')
      
    set(gca,'fontsize', 15)
    cd([datadir filesep 'Figures' filesep 'Calibration'])
    print([pfols(ippant).name  ' calibration']);
end
%%
shg
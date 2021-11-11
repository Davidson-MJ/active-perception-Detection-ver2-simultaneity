%plot calibration (using trial summary)

cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);


nPracticetrials= [20,40,40,40];
%% %%
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name, 'calibData', 'calibAcc', 'calibGap'); 
    
    subplot(1,3,ippant)
    plot(1:length(calibData), calibAcc)
    
end
%%
shg
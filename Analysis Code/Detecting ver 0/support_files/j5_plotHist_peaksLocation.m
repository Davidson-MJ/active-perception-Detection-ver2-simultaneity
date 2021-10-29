%j5_plotHist_peaksLocation

% plot density function of peak times per trial, to see if we can window
% target presentation around specific regions in time, reliably per ppant.




clear all; close all;
datadir = 'C:\Users\vrlab\Documents\Matt\Projects\Output\walking_Ver0';
cd([datadir filesep 'ProcessedData'])

pfols= dir([pwd  filesep '*raw.mat']);
nsubs= length(pfols);
%%

load(pfols(1).name);
%%
%create a tally of each point in the whole trial vector.
[pks2fill, trs2fill] = deal([]);
% for each trial, extract the peaks.
for itrial = 1:size(HeadPos,2)
    pks2fill = [pks2fill, HeadPos(itrial).Y_gait_peaks];
    trs2fill = [trs2fill, HeadPos(itrial).Y_gait_troughs];
end
%%
% histcounts(pks2fill);
histogram(pks2fill, 50);
hold on
histogram(trs2fill, 50)


% plot_exampleSingletrial



cd([datadir filesep 'ProcessedData'])
Fs=90;
pfols = dir([pwd filesep '*summary_data.mat']);
nsubs= length(pfols);

ippant=4;
itrial= 46;

figure(1); clf;
set(gcf, 'units', 'normalized', 'position', [0,0, .9, .9], 'color', 'w', 'visible', 'off');
%%
cd([datadir filesep 'ProcessedData'])

%
load(pfols(ippant).name);
%% trial data:
itrial=46;
clf
subplot(311);
trialD = squeeze(HeadPos(itrial).Y);
trialTarg = TargState(itrial).state;
trialClick = clickState(itrial).state;
loc_pks = HeadPos(itrial).Y_gait_peaks;

loc_troughs = HeadPos(itrial).Y_gait_troughs;
% clf
Timevec = HeadPos(itrial).times;

plot(Timevec, trialD, 'k', 'linew', 3);
hold on;
ylabel('Head height');
xlabel('Time (s)');
set(gca, 'fontsize', 15);
box off

ylim([1.62 1.75]);
%%
% 
% subplot(312);
% 
% plot(Timevec, trialD, 'k', 'linew', 3);
% hold on;
% ylabel('Head height');
% xlabel('Time (s)');
% set(gca, 'fontsize', 15);
% box off
% plot(Timevec(loc_pks), trialD(loc_pks), ['or'], 'markersize', 20, 'linew', 2);
% plot(Timevec(loc_troughs), trialD(loc_troughs), ['ob'], 'markersize', 20, 'linew', 2)
% % add targ and response info:
% %
% ylim([1.62 1.75]);
%%
subplot(313)

plot(Timevec, trialD, 'k', 'linew', 3);
hold on;
ylabel('Head height');
xlabel('Time (s)');
set(gca, 'fontsize', 15);
box off
% plot(Timevec(loc_pks), trialD(loc_pks), ['or'], 'markersize', 20, 'linew', 2);
% plot(Timevec(loc_troughs), trialD(loc_troughs), ['ob'], 'markersize', 20, 'linew', 2)
% add targ and response info:
%
ylim([1.55 1.72]);
hold on
yyaxis right
tt=plot(Timevec, trialTarg, 'b', 'linew',2);
tr=plot(Timevec, trialClick, 'r', 'linew', 2);
% ylabel('targ-click');
ylabel('')
set(gca,'ytick', [])
shg
% ylim([
% axis tight
legend([tt, tr], {'onset', 'response'})
yyaxis left
ylim([1.62 1.75]);

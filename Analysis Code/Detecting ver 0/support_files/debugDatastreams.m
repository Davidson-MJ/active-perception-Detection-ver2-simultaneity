%data debug check.
clf
for itrial = 11
frame_TC = squeeze(TargClickmatrix(:,itrial,:));
time_ax= avTime(itrial,:);

plot(time_ax, frame_TC(1,:), 'k'); hold on;
plot(time_ax, frame_TC(2,:), 'r'); hold on;

%collect summary info for comparison:
tos= trial_TargetSummary(itrial).targOnsets;
rts = trial_TargetSummary(itrial).clickOnsets;
fas = trial_TargetSummary(itrial).FalseAlarms;
title({['Summary: tons = ' num2str(tos')];[
   'RTs: ' num2str(rts')]} );

hold on;
for irt= 1:length(rts);
    plot([rts(irt) rts(irt)], [0 .5], 'b', 'linew',2)
     plot([tos(irt) tos(irt)], [0 .5], 'm', 'linew',2)
end
legend
end
shg
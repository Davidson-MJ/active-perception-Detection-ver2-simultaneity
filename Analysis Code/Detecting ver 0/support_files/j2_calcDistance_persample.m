%j2_calcDistance_persample

% Here we calculate the 3D distance between hand and target at each time 
% point. Then store  trial level data.

% can calculate distance bw 2 3D points using:
% 1) sqrt(sum((A - B) .^ 2))
% 2) norm(A-B)

cd([datadir filesep 'ProcessedData'])
pfols = dir([pwd filesep '*raw.mat']);

%%
for isub = 1:nsubs
    cd([datadir filesep 'ProcessedData'])
    %%load data from import job.
    load(pfols(isub).name);
    savename = pfols(isub).name;
    disp(['Preparing j2 ' savename]);

   %% 
   Hand_Targ_dist = zeros(size(Hand_posmatrix,2), size(Hand_posmatrix,3));
   Hand_Targ_dist_alt = Hand_Targ_dist;
    for  itrial=1:size(Head_posmatrix,2)
        for isamp = 1:size(Head_posmatrix,3)
            %gather xyz coords.
       A = [Hand_posmatrix(:,itrial,isamp)];
       B=  [Targ_posmatrix(:,itrial,isamp)];
       
%        Hand_Targ_dist(itrial,isamp) = sqrt(sum((A - B) .^ 2)); 
       Hand_Targ_dist(itrial,isamp) =norm(A-B); 
        end
    end % itrial
    
  
    save(savename, 'Hand_Targ_dist', '-append');
    
    
    
    % also plot error per trial in fig dir, for debugging purposes:
    figure(1); set(gcf, 'units', 'normalized', 'position', [0,0, .9, .9], 'color', 'w', 'visible', 'off');
    pcount=1; figcount=1;
    clf
    for itrial = 1:size(Head_posmatrix,2)
        if itrial==16 || pcount ==16
            %print that figure, and reset trial count.
            pcount=1;
              cd([datadir filesep 'Figures'])
              print('-dpng', [subjID ' trialpeaks + Error ' num2str(figcount)]);
              figcount=figcount+1;
              clf;
        
        end
        subplot(5,3,pcount);
        plot(Timevec, squeeze(Head_posmatrix(2,itrial,:)));
        hold on;
%         plot(Timevec(locs_ptr), trialD(locs_ptr), ['or']);
%         plot(Timevec(locs_trtr), trialD(locs_trtr), ['ob']);
        ylabel('Head position');
        xlabel('Time (s)');
        title(['Trial ' num2str(itrial)]);
        axis tight
        yyaxis right
        plot(Timevec, Hand_Targ_dist(itrial,:), 'linew', 2);
        ylabel('raw Error')
        pcount=pcount+1;
    end
    
    cd([datadir filesep 'Figures'])
    print('-dpng', [subjID ' trialpeaks + Error ' num2str(figcount)]);
end % sub
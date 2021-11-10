% plotj2_targClassification_winGait

% loads the ppant data collated in j2_binData_bycycle.

%plots the position of correctly and incorrectly identified targets, per
%pariticpant, as a position of the gait cycle.

cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);


%%%%
for ippant = 1:nsubs
    cd([datadir filesep 'ProcessedData'])    %%load data from import job.
    load(pfols(ippant).name); 
    
    
    %% figure:
    figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .9  .9]);
    plot(mean(PFX_headY));
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
        plot(mean(PFX_headY));
        yyaxis right
        usespecs= lspecs{itype};        
         hg= histogram(hist_Data, 100, 'FaceColor', usespecs(1) , 'LineStyle', usespecs(2));
       title(titlesare{1});
        hleg(itype)= hg;
        counts(itype) = length(hist_Data);
        
        subplot(2,3, 1+itype); hold on;
        yyaxis left
         plot(mean(PFX_headY)); 
          
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
    print([pfols(ippant).name ' targs within gait'],'-dpng');
    
end % ppant
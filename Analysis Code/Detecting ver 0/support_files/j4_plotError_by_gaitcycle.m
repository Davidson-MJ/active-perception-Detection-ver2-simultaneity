%j4_plotError_by_gaitcycle;

% plot per ppant, plot across ppnts

clear all; close all;
datadir = 'C:\Users\vrlab\Documents\Matt\Projects\Output\walking_Ver0';
cd([datadir filesep 'ProcessedData'])

pfols= dir([pwd  filesep '*raw.mat']);
nsubs= length(pfols);

job.concatGFX=1;
job.plotPFX=0; % single and dual gait cycles.
job.plotGFX=1;

%%%%%%%%%%%%%%%%%%%%%%
%% concat across subjs
%%%%%%%%%%%%%%%%%%%%%%
if job.concatGFX
    
    %single cycle
    [GFX_err,GFX_headY] = deal(zeros(nsubs, 100)); % we've resampled to 100 points.
    [GFX_errVar] = zeros(nsubs,9);
    %dual cycle
    [GFX_err_dbGC,GFX_headY_dbGC] = deal(zeros(nsubs, 200)); % we've resampled to 100 points.
    [GFX_errVar_dbGC] = zeros(nsubs,18);
    
    for isub = 1:nsubs
        cd([datadir filesep 'ProcessedData'])
        %%load data from import job.
        load(pfols(isub).name);
        
        %*1000 to compute all in mms (not metres)?
        GFX_err(isub,:) = nanmean(PFX_allsteps_Err,1);
        GFX_headY(isub,:) = nanmean(PFX_headY,1);
        GFX_errVar(isub,:) = PFX_binnedVar_allsteps;
        
        
        %double gait cycle:
        GFX_err_dbGC(isub,:) = nanmean(PFX_err_doubleGC,1);
        GFX_headY_dbGC(isub,:) = nanmean(PFX_headY_doubleGC,1);
        GFX_errVar_dbGC(isub,:) = PFX_binnedVar_allsteps_doubleGC;
        
        
    end %ppant
    save('GFX_gaitcycle_error', 'GFX_err', 'GFX_headY', 'GFX_errVar',...
        'GFX_errVar_dbGC', 'GFX_err_dbGC', 'GFX_headY_dbGC');
    
else
    load('GFX_gaitcycle_error');
end % job concat

%%%%%%%%%%%%%%%%%%%%%%
%% print PFX
%%%%%%%%%%%%%%%%%%%%%%
if job.plotPFX
    for isub = 1:nsubs
        cd([datadir filesep 'ProcessedData'])
        %% load data from import job.
        load(pfols(isub).name);
        %%
        ntrials = size(HandPos,2);
        
        figure(1); clf;
        for iGC=1:2 % plot both gait cycle analyses (single and dual).
            if iGC==1
                headData = PFX_headY;
                errData = PFX_allsteps_Err;
                %                 errData = PFX_err;
                varData = PFX_binnedVar_allsteps;
            else
                headData = PFX_headY_doubleGC;
                %                 errData = PFX_err_doubleGC;
                errData= PFX_allsteps_Err_doubleGC;
                varData = PFX_binnedVar_allsteps_doubleGC;
            end
            nsteps = size(errData,1);
            
            %% plot head pos and mean Error
            plotpos= 1+(iGC-1)*2;
            subplot(2,2,plotpos)
            yyaxis left; % activate left Y axis for head pos.
            plot(1:length(headData), nanmean(headData,1), ['ko']);
            ylabel('norm Head height');
            hold on;
            yyaxis right;
            plot(1:length(headData), nanmean(errData,1)*1000, 'linew', 2);
            mp = squeeze(nanmean(errData,1)) *1000;
            stp = std(errData.*1000,1);
            %         shadedErrorBar(1:length(headData), mp,stp, [],1);
            ylabel('Hand-Targ Error (mm)');
            set(gca, 'xtick',[]);
            title([subjID ', nsteps = ' num2str(nsteps)])
           
            %% plot head pos and binned err Variance.
            plotpos= 2+(iGC-1)*2;
            subplot(2,2,plotpos);
            yyaxis left; % activate left Y axis for head pos.
            plot(1:length(headData), nanmean(headData,1), ['ko']);
            ylabel('norm Head height');
            hold on;
            yyaxis right;
            
            xvec= linspace(1,length(headData),9*iGC);
            bh=bar(xvec, varData*1000);
            bh.FaceAlpha = .2;
            ylabel('Hand-Targ Var (mm)');
            %         set(gca, 'xtick',[]);
            title([subjID ', nsteps = ' num2str(nsteps)])
            
        end % GC
        set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 .1 .6 .8]);
        
        cd([datadir filesep 'Figures']);
        
        print('-dpng', ['PFX_gaiterror_' subjID]);
    end %ppant
end


%%%%%%%%%%%%%%%%%%%%%%
%% print GroupFX
%%%%%%%%%%%%%%%%%%%%%%
if job.plotGFX
    
    figure(1); clf; 
    
    for iGC=1:2 % plot both gait cycle analyses (single and dual).
        if iGC==1
            headData = GFX_headY;
            errData = GFX_err;
            %
            varData = GFX_errVar;
        else
            headData = GFX_headY_dbGC;%
            errData= GFX_err_dbGC;
            varData = GFX_errVar_dbGC;
        end
        nsubs = size(headData,1);
        %% head pos and error
        plotpos= 1+(iGC-1)*2;
        subplot(2,2,plotpos)
        yyaxis left; % activate left Y axis for head pos.
        plot(1:length(headData), mean(headData,1), ['ko']);
        ylabel('norm Head height');
        hold on;
        yyaxis right;
        mP = squeeze(mean(errData,1));
        stE= CousineauSEM(errData);
        sh= shadedErrorBar(1:length(headData), mP, stE, 'r');
        %     plot(1:100, mean(GFX_err,1), 'linew', 2);
        ylabel('Hand-Targ Error (mm)');
        set(gca, 'xtick',[]);
        title(['GFX  nsubs = ' num2str(nsubs)])
        %% head pos and variance
         plotpos= 2+(iGC-1)*2;
            subplot(2,2,plotpos)
        yyaxis left;
        plot(1:length(headData), mean(headData,1), ['ko']);
        ylabel('norm Head height');
        hold on;
        
        yyaxis right;
       
        xvec = linspace(1,length(headData),9*iGC);
        bh=bar(xvec, mean(varData,1));
        stE = CousineauSEM(varData);
        hold on;
        errorbar(xvec, mean(varData,1), stE);
        bh.FaceAlpha= .2;
        ylabel('Hand-Targ Error Var (mm)');
        set(gca, 'xtick',[]);
        title(['GFX  nsubs = ' num2str(nsubs)])
        %%
        %print
        cd([datadir filesep 'Figures']);
        set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 .1 .6 .8]);
    end % both Gait cycles
        print('-dpng', ['GFX_gaiterror']);
    end
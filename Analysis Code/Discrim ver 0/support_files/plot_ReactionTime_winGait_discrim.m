% plot RT discrim version

% plot_ReactionTime_winGait - %detection (contrast ver)
% flashes)

% loads the ppant data collated in j2_binData_bycycle./
% j3_binDatabylinkedcycles.

%plots the average RT, relative to target position in gait cycle.
%pariticpant, as a position of the gait cycle.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Discrimination (1 or 2 flash)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%mac:
% datadir='/Users/matthewdavidson/Documents/GitHub/active-perception-Detection_v1/Analysis Code/Detecting ver 0/Raw_data';
%PC
datadir= 'C:\Users\User\Documents\matt\GitHub\active-perception-Detection-ver2-simultaneity\Analysis Code\Discrim ver 0\Raw_data';

cd([datadir filesep 'ProcessedData']);
pfols= dir([pwd  filesep '*summary_data.mat']);
nsubs= length(pfols);
%%
% how many gaits to plot?
nGaits_toPlot=2; % 1 or 2.

job.concat_GFX=0;

job.basicPermtest =0; %create null distribution for quick plot:

% plot PFX:
job.plot_RT_perTargpos=1; % plot PFX data 3 ways (raw, binned, sliding window).

job.plot_RT_perResppos=1; % as above, but using response in gait as index.

%%%%
%plot GFX:
job.plotGFX_RTcount_perResppos=1; % specify type (1,2,3,4,5 to plot)
job.plotGFX_RTsec_perResppos_binned=1; % binned
% job.plotGFX_RTsec_perResppos_sliding=0; % sliding

%1= single flash correct response 
%2= double flash correct response 
%3= single flash incorrect response 
%4= double flash incorrect response 
%5= all responses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%data wrangling first: Concat, and create null distribution.
pidx1=ceil(linspace(1,100,8));
pidx2=ceil(linspace(1,200,16));
gaittypes = {'single gait' , 'double gait'};
%data categories we wil calculate and plot:
titlesare= {'1flash correct', '2flash correct', '1flash error', '2flash error', 'all combined'};
colsare= [.4, .6, .4;... %greenish
          .4, .6, .4; ...
          1, .2, .2; % reddish
          1, .2, .2; % reddish
          .5 .5 .5]; % grey (combined data)
%%
if job.concat_GFX
    dataIN=[];
    GFX_RT_RespPosData=[];
    GFX_RT_TargPosData=[];
    sliding_cntrpoints=[]; % x vec for sliding window.
    GFX_headY=[];
  
    subjIDs={};
    for ippant = 1:nsubs
        cd([datadir filesep 'ProcessedData'])    %%load data from import job.
        load(pfols(ippant).name, ...
           'gaitRTs', 'gaitRTs_doubGC','PFX_headY', 'PFX_headY_doubleGC', 'subjID');
        
        subjIDs{ippant} = subjID;
        
        
        
        
        % shrink for easier readbility:
        % we will perform a split based on target classification
        for itargclass=1:5
            if itargclass<5% 3rd col is target class.
                 userows = find(gaitRTs(:,3)==itargclass);
                userowsdb = find(gaitRTs_doubGC(:,3)==itargclass);
            else % combined all             
                userows = 1:size(gaitRTs,1);
                userowsdb = 1:size(gaitRTs_doubGC,1);
            end
            dataIN(ippant,itargclass).gc = gaitRTs(userows,:);
            dataIN(ippant, itargclass).doubgc= gaitRTs_doubGC(userowsdb,:);
        end
        % mean head pos:
        
        GFX_headY(ippant).gc = nanmean(PFX_headY);        
        GFX_headY(ippant).doubgc = nanmean(PFX_headY_doubleGC);
       
        
        %% also calculate sliding window of RTs, and binned ver:
        % take mean per gait cycle pos/
       for nGait=1:2
            if nGait==1
                pidx=pidx1;
                ppantData= gaitRTs;
            else
                pidx=pidx2;
                ppantData= gaitRTs_doubGC;
            end
            
            %% this case is special, as we have correct and errors, for 2 trial types
            % single or double flash.
            %so we will separate for easier plotting later.
            %separate by code:
            %1= 1 flash correct, 2= 2 flash correct, 3= 1 flash error;
            %4= 2 flash error.
            % 5 for all together.
            for itargclass=1:5
                
                if itargclass==5
                    userows=1:size(ppantData,1);
                else
                    userows = find(ppantData(:,3) ==itargclass);
                end
                
                datatmp = ppantData(userows,:);
                
                %% mean RT at each targ onset position:
                tOns_RTs = nan(1,pidx(end));
                allpos = datatmp(:,1); % first row gait pcnt for target onset.
                allRTs=  datatmp(:,2); % second row rt for target .
                
                %take mean RT for all recorded positions:
                for ip=1:pidx(end)
                    useb = find(allpos ==ip);
                    tOns_RTs(ip) = nanmean(allRTs(useb));
                end
                %% mean RT per resp onset position.
                tResp_RTs = nan(1,pidx(end));
                allpos = datatmp(:,4); % fourth row, is resp pcnt in gait.
                allRTs=  datatmp(:,2); % second row rt for target .
                
                %take mean RT for all recorded positions:
                for ip=1:pidx(end)
                    useb = find(allpos ==ip);
                    tResp_RTs(ip) = nanmean(allRTs(useb));
                end
                %% for both, also calculate binned versions for nicer plots:
                [resprt_bin, targrt_bin]=deal([]);
                
                for ibin=1:length(pidx)-1
                    idx = pidx(ibin):pidx(ibin+1);
                    
                    targrt_bin(ibin) = nanmean(tOns_RTs(idx));
                    resprt_bin(ibin) = nanmean(tResp_RTs(idx));
                end
                
                %% and sliding window :
                
                movingwin= [5,1]; % average over (1), step in (2).
                
                nsamps=pidx(end);
                Nwin=movingwin(1); % number of samples in window
                Nstep=round(movingwin(2)); % number of samples to step through
                
                winstart=1:Nstep:nsamps-Nwin+1;
                nw=length(winstart);
                %%
                [targrt_slid, resprt_slid]= deal([]);
                
                for n=1:nw
                    indx=winstart(n):winstart(n)+Nwin-1;
                    
                    % compute RT over this window.
                    targrt_slid(n) = nanmean(tOns_RTs(indx));
                    
                    resprt_slid(n) = nanmean(tResp_RTs(indx));
                end
                
                
                if nGait==1
                    GFX_RT_TargPosData(ippant,itargclass).gc= tOns_RTs;
                    GFX_RT_TargPosData(ippant,itargclass).gc_binned = targrt_bin;
                    GFX_RT_TargPosData(ippant,itargclass).gc_slid = targrt_slid;
                    
                    GFX_RT_RespPosData(ippant,itargclass).gc = tResp_RTs;
                    GFX_RT_RespPosData(ippant,itargclass).gc_binned = resprt_bin;
                    GFX_RT_RespPosData(ippant,itargclass).gc_slid = resprt_slid;
                    sliding_cntrpoints.gc=winstart;
                else
                    GFX_RT_TargPosData(ippant,itargclass).doubgc= tOns_RTs;
                    GFX_RT_TargPosData(ippant,itargclass).doubgc_binned = targrt_bin;
                    GFX_RT_TargPosData(ippant,itargclass).doubgc_slid= targrt_slid;
                    
                    GFX_RT_RespPosData(ippant,itargclass).doubgc = tResp_RTs;
                    GFX_RT_RespPosData(ippant,itargclass).doubgc_binned = resprt_bin;
                    GFX_RT_RespPosData(ippant,itargclass).doubgc_slid = resprt_slid;
                    sliding_cntrpoints.doubgc=winstart;
                end
            end % targ class (1,2,3,4)
            
       end % nGait
       
        
    end % ppant
    
    %% after all participants, append the Group Average.
    
    
    
    
    
    dimsare = {'correct', 'miss'};
    GFX_data= dataIN;
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    
    save('GFX_RT_inGaits', 'GFX_data','GFX_headY',...
        'GFX_RT_TargPosData','GFX_RT_RespPosData',...
    'sliding_cntrpoints','subjIDs', '-append');
else
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    load('GFX_RT_inGaits');
end
% job
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% plots at Participant level:

if job.plot_RT_perTargpos==1
    %%
    if ~exist('GFX_data', 'var')
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    load('GFX_RT_inGaits')
    end
    %%    
    for ippant = 1:nsubs
        
        for itargclass=1:5
        
        %% figure:
        figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5  1]);
        
        ppantData=[];
        
        %in this version, we don't split by type.
        if nGaits_toPlot==1
            ppantData(1).d= GFX_RT_TargPosData(ippant,itargclass).gc;            
            ppantData(2).d= GFX_RT_TargPosData(ippant,itargclass).gc_binned;            
            ppantData(3).d= GFX_RT_TargPosData(ippant,itargclass).gc_slid;
            
            plotHead = GFX_headY(ippant).gc;
            pidx= pidx1;
            slidtime = sliding_cntrpoints.gc;
        else
             ppantData(1).d= GFX_RT_TargPosData(ippant,itargclass).doubgc;            
            ppantData(2).d= GFX_RT_TargPosData(ippant,itargclass).doubgc_binned;            
            ppantData(3).d= GFX_RT_TargPosData(ippant,itargclass).doubgc_slid;
            
            plotHead = GFX_headY(ippant).doubgc;
            pidx= pidx2;
            slidtime = sliding_cntrpoints.doubgc;
        end
        
        %% plot each data type:
        for idata=1:3
        
        
        if idata==1% raw pos, no average or binning:
            timevec = 1:pidx(end);
        elseif idata==2
            timevec = pidx(1:end-1);
        elseif idata==3
            timevec = slidtime;
        end
        %%
        subplot(3,1,idata)
        if idata<3
        bh=bar(timevec, ppantData(idata).d, 'FaceColor', colsare(itargclass,:));
        else
            plot(timevec, ppantData(idata).d, 'color',  colsare(itargclass,:), 'linew', 4);
        end
        ylabel('mean RT [sec]');

        yyaxis right
        ph=plot(plotHead, ['k-o']); hold on
        set(gca,'ytick', []);
        
        title({[subjIDs{ippant} ' Detection'];[titlesare{itargclass}]}, 'interpreter', 'none');
         midp=timevec(ceil(length(timevec)/2));
        set(gca,'fontsize', 15, 'xtick', [1, midp, timevec(end)], 'XTickLabels', {'0', '50', '100%'})
         
        xlabel( '% of gait-cycle')
        
        
        end
        
        
        legend([bh, ph],{'targ onset in GC', 'headheight'})
 
    cd([datadir filesep  'Figures' filesep 'RT_withinGait'])
    
    print([subjIDs{ippant} ' RT per targ position within ' gaittypes{nGaits_toPlot} '-' titlesare{targclass}],'-dpng');
    end%targclass
    end % ppant
end % job.

%% 
%% job

if job.plot_RT_perResppos==1
   %%
    if ~exist('GFX_data', 'var')
    cd([datadir filesep 'ProcessedData' filesep 'GFX']);
    load('GFX_RT_inGaits')
    end
    %%
   %each plotted as itargclass below: 

    for ippant = 1:nsubs
        
        for itargclass=1:5
        %% figure:
        figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5  1]);
        
        ppantData=[];
        subtitlesare={'RT', 'RT (binned)', 'RT (mov.Avg)'};
        if nGaits_toPlot==1
            ppantData(1).d= GFX_RT_RespPosData(ippant,itargclass).gc;            
            ppantData(2).d= GFX_RT_RespPosData(ippant,itargclass).gc_binned;            
            ppantData(3).d= GFX_RT_RespPosData(ippant,itargclass).gc_slid;
            
            countsResp = GFX_data(ippant,itargclass).gc(:,4); % 4th column is resp loc as gait pcnt.
             
            plotHead = GFX_headY(ippant).gc;
            pidx= pidx1;
            slidtime = sliding_cntrpoints.gc;
        else
             ppantData(1).d= GFX_RT_RespPosData(ippant,itargclass).doubgc;            
            ppantData(2).d= GFX_RT_RespPosData(ippant,itargclass).doubgc_binned;            
            ppantData(3).d= GFX_RT_RespPosData(ippant,itargclass).doubgc_slid;
            
            countsResp = GFX_data(ippant,itargclass).doubgc(:,4); % 4th column is resp loc as gait pcnt.
           
            plotHead = GFX_headY(ippant).doubgc;
            pidx= pidx2;
            slidtime = sliding_cntrpoints.doubgc;
        end
        
        %% plot each data type:
        
        % first just plot the counts per point:
        %use nbins to match the binned analysis:
        nbins = length(ppantData(2).d);
        subplot(2,2,1);
        hs=histogram(countsResp, nbins);
        hs.FaceColor= 'b';
        ylabel('Response [counts]')
        midp=pidx(end)/2;
        set(gca,'fontsize', 15, 'xtick', [1, midp, timevec(end)], 'XTickLabels', {'0', '50', '100%'})
         xlabel('Gait %')
        yyaxis right
        ph=plot(plotHead, ['k-o']); hold on
        set(gca,'ytick', []);
        title({[subjIDs{ippant}];[titlesare{itargclass}]}, 'interpreter', 'none') 
        %%
        for idata=1:3
        
        
        if idata==1% raw pos, no average or binning:
            timevec = 1:pidx(end);
        elseif idata==2
            timevec = pidx(1:end-1);
        elseif idata==3
            timevec = slidtime;
        end
        %%
        subplot(2,2,idata+1)
        if idata<3
        bh=bar(timevec, ppantData(idata).d, 'FaceColor', colsare(itargclass,:));
        else
          bh=  plot(timevec, ppantData(idata).d,'color',colsare(itargclass,:), 'linew', 2);
        end
        ylabel('mean RT [sec]');
        title(subtitlesare{idata});
        % 
        mP = nanmean(bh.YData);
        sP= nanstd(bh.YData);
        ylim([mP-4*sP mP+4*sP])
%         if idata==3
%              ylim([mP-5*sP mP+5*sP])
%         end
        %%
        yyaxis right
        ph=plot(plotHead, ['k-o']); hold on
        set(gca,'ytick', []);
        
%         title([subjIDs{ippant} ' Detection'], 'interpreter', 'none');
         midp=timevec(ceil(length(timevec)/2));
        set(gca,'fontsize', 15, 'xtick', [1, midp, timevec(end)], 'XTickLabels', {'0', '50', '100%'})
         
        xlabel( '% of gait-cycle')
        
        
        end
        
        
%         legend([bh, ph],{'response onset in GC', 'headheight'})
 
    cd([datadir filesep  'Figures' filesep 'RT_withinGait'])
    
    print([subjIDs{ippant} ' RT per response position within ' gaittypes{nGaits_toPlot} '-' titlesare{itargclass}],'-dpng');
        end
    end % ppant
end % job.

%% GFX

if job.plotGFX_RTcount_perResppos==1
   %%
   if ~exist('GFX_data', 'var')
       cd([datadir filesep 'ProcessedData' filesep 'GFX']);
       load('GFX_RT_inGaits')
   end
%%
   for itargclass=1:5
   
   %% figure:
   figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5  .5]);
   
   plotData=[];
   countsResp=[];
   plotHead=[];
%    titlesare={'RT', 'RT (binned)', 'RT (mov.Avg)'};
   %%
   if nGaits_toPlot==1
       for ip=1:size(GFX_RT_RespPosData,2)
           
           nbins = length(GFX_RT_RespPosData(ip,itargclass).gc_binned);
           
           countsResp(ip,:)=histcounts(GFX_data(ip,itargclass).gc(:,4), nbins);
           plotHead(ip,:) = GFX_headY(ip).gc;
       end
       
       pidx= pidx1;
       slidtime = sliding_cntrpoints.gc;
   else
       for ip=1:size(GFX_RT_RespPosData,2)
           
           nbins = length(GFX_RT_RespPosData(ip,itargclass).doubgc_binned);
           
           countsResp(ip,:)=histcounts(GFX_data(ip,itargclass).doubgc(:,4), nbins);
           plotHead(ip,:) = GFX_headY(ip).doubgc;
       end
       pidx= pidx2;
       slidtime = sliding_cntrpoints.doubgc;
   end
   
   %% plot each data type:
   
   % first just plot the counts per point:
   %use nbins to match the binned analysis:
   
   hs=bar(pidx(1:end-1), nanmean(countsResp,1), 'FaceColor', colsare(itargclass,:));
   hold on;
   stE= CousineauSEM(countsResp);
   errorbar(pidx(1:end-1), nanmean(countsResp,1), stE,...
       'linestyle', 'none', 'color', 'k', 'linew', 3)
   %%
   ylabel('Response [counts]')
   %
   midp=pidx(end)/2;
   set(gca,'fontsize', 15, 'xtick', [1, midp, pidx(end)], 'XTickLabels', {'0', '50', '100%'})
   xlabel('Gait %')
   yyaxis right
   ph=plot(nanmean(plotHead,1), ['k-o']); hold on
   set(gca,'ytick', []);
   title(['GFX - ' titlesare{itargclass}], 'interpreter', 'none')
   
   cd([datadir filesep  'Figures' filesep 'RT_withinGait'])
   %%
   print(['GFX RT counts per position within ' gaittypes{nGaits_toPlot} '-' titlesare{itargclass}],'-dpng');
   end
end % job.
%%
if job.plotGFX_RTsec_perResppos_binned==1
    %%
    if ~exist('GFX_data', 'var')
        cd([datadir filesep 'ProcessedData' filesep 'GFX']);
        load('GFX_RT_inGaits')
    end
    
    %%
    
    for itargclass=1:5
        %% figure:
        
        figure(1); clf; set(gcf, 'color', 'w', 'units', 'normalized', 'position', [0 0 .5  .5]);
        
        plotData=[];
        countsResp=[];
        plotHead=[];
        
        if nGaits_toPlot==1
            for ip=1:size(GFX_RT_RespPosData,2)
                plotData(ip,:)= GFX_RT_RespPosData(ip,itargclass).gc_binned;
                plotHead(ip,:) = GFX_headY(ip).gc;
            end
            pidx= pidx1;
        else
            for ip=1:size(GFX_RT_RespPosData,2)
                plotData(ip,:)= GFX_RT_RespPosData(ip,itargclass).doubgc_binned;
                plotHead(ip,:) = GFX_headY(ip).doubgc;
            end
            pidx= pidx2;
        end
        
        timevec = pidx(1:end-1);
        
        
        bh=bar(timevec, nanmean(plotData,1), 'FaceColor', colsare(itargclass,:));
        ylabel('mean RT [sec]'); hold on;
        stE= CousineauSEM(plotData);
        errorbar(timevec, nanmean(plotData,1), stE,...
            'linestyle', 'none', 'color', 'k', 'linew', 3)
        %%
        mP = nanmean(bh.YData);
        sP= nanstd(bh.YData);
        ylim([mP-5*sP mP+5*sP])
        %%
        yyaxis right
        ph=plot(nanmean(plotHead,1), ['k-o']); hold on
        set(gca,'ytick', []);
        %%
        midp=timevec(ceil(length(timevec)/2));
        set(gca,'fontsize', 15, 'xtick', [1, midp, timevec(end)], 'XTickLabels', {'0', '50', '100%'})
        xlabel( '% of gait-cycle')
        %%
        title(['GFX - ' titlesare{itargclass}])
        
        
        
        %         legend([bh, ph],{'response onset in GC', 'headheight'})
        
        cd([datadir filesep  'Figures' filesep 'RT_withinGait'])
        
        print(['GFX RT per response position within ' gaittypes{nGaits_toPlot} '(binned) - ' titlesare{itargclass} ],'-dpng');
    end% targ class
end % job.
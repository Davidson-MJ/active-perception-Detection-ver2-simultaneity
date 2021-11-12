%sim targ onset:
rw=0.8;
trialdur= 11;
targRange=[0.5+rw, trialdur-rw]; %trialDur- rw
minITI = 0.95;

%4,5,6 targets.
% 8s window
t4= repmat(4, 1,100);
t5= repmat(5, 1,100);
t6= repmat(6,1,100);

%11s window
t7 = repmat(7, 1,100);
t8=  repmat(8, 1,100);
t9 = repmat(9, 1,100);
trialtypes =[t7,t8,t9];


shf = randperm(length(trialtypes));
trialtypes=trialtypes(shf);
%% select from random between two numbers:
alltargpres=[];
figure(1); clf;
%
for itrial=1:length(trialtypes)
    
    pretargISI= [];
    switch trialtypes(itrial)
               
        
        case 4
            gapsare =[ 3.75, 2.5, 1.5,.5];
            subpl=1;
        case 5
            gapsare=[4.25,3.25,2.25,1.25,0];
            subpl=2;
        case 6
            gapsare= [5.75, 4.75, 3.75, 2.75, 1.75 ,0];
            subpl=3;
            
        case 7
            gapsare= [8, 6.9, 5.8, 4.7, 3.6, 2.5, 0];
            subpl=1;
        case 8
             gapsare= [ 7.7, 6.6, 5.5, 4.4, 3.3, 2.2, 1.1, 0];
            subpl=2;
        case 9
            gapsare= [ 8.6, 7.5, 6.4, 5.3, 4.2, 3.2, 2.1, 0];
            subpl=3;
            
    end
    
    % randomly subtract between 0 or 0.5.
    subtr=rand(1)/2;
   
    gapsare= gapsare -subtr;
    
    for itpres= 1:length(gapsare)
        if itpres==1
            a= targRange(1);
        else
            a= pretargISI(itpres-1) + minITI;
        end
        b= targRange(2)- gapsare(itpres)*(minITI+.02);
        %first targ
        pretargISI(itpres) = (b-a).*rand(1,1) + a;
    end
    
    figure(1);
    subplot(1,3,subpl)
    hold on;
    for it=1:length(pretargISI)
        plot([pretargISI(it) pretargISI(it)], [0 1], 'k');
        hold on
    end
    title(num2str(trialtypes(itrial)));
    % per trial
    alltargpres=[alltargpres,pretargISI];
    if any(diff(pretargISI)<minITI)
        disp(diff(pretargISI))
        disp(['error type:' num2str(trialtypes(itrial)) ]);
        
    end
end %pertrial
%% plot all
figure(2); clf
subplot(211)
allts= alltargpres(:);
for it=1:length(allts)
    plot([allts(it) allts(it)], [0 1], 'k');
    hold on
end
subplot(212)
% hist of spread
hist= round(allts, 2);
histogram(hist, 8000)
%

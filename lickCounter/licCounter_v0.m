% Author: Kang-Yu Chu (Neurobiology Research Unit/Wickens Unit)
% Last Update: 2021/05/29
% Purpose: for analyzing licking events of mice in the JetBall experiments

%% Initialization
clc;clear all;close all;
t_CS = 6;
t_RW = 3;


%% Load the data file (type: xlsx and csv)
% Select a file
[fileName,filePath] = uigetfile({'*.xlsx;*.csv','Excel files (*.xlsx, *.csv)'},'Select a file');

% Read the file as a format of table
opts = detectImportOptions(fullfile(filePath,fileName));

% Read the yellow labeled columns
VariableNames = {'DateTime','eventDuration','sense1Events','SystemMsg'};
opts.SelectedVariableNames= VariableNames; 
extractedData = readtable(fullfile(filePath,fileName), opts);

%% Devide data into n trails (The n here = 18)
% The loop is used to find the time points which corresponding to "CS
% Onset" and "Reward". Further, I create a matrix called time(start, end) by converting the
% values of "DataTime" column into seconds.

m = 1;
n = 1;
time = [];
CSRWIdx = [];

for i = 1:height(extractedData)
    time(i,1) = ...
    extractedData.(VariableNames{1})(i).Hour*3600 + ...
    extractedData.(VariableNames{1})(i).Minute*60 + ...
    extractedData.(VariableNames{1})(i).Second;

    if strcmp(extractedData.(VariableNames{4})(i),'CS onset')
        CSRWIdx(m,1) = i;
        m = m + 1;
    elseif strcmp(extractedData.(VariableNames{4})(i),'Reward')
        CSRWIdx(n,2) = i;
        n = n + 1;
    end
end
% time(:,1) = time(:,1)*1000;
time(:,2) = time(:,1) + extractedData.(VariableNames{2})*0.001;

% Create matrices for each trail (CS onset & Reward)
CStrailSet = {};
RWtrailSet = {};

lickCounts_CSRW = [];


% fillingRange = 0.4;
for t = 1:n-1
    CStrailSet{t} = [(time(CSRWIdx(t,1)+2:CSRWIdx(t,2)-1,:)-time(CSRWIdx(t,1),1))';...
                     t*ones(2,length(CSRWIdx(t,1)+2:CSRWIdx(t,2)-1))];
    lickCounts_CSRW(t,1) = sum(extractedData.(VariableNames{3})(CSRWIdx(t,1)+2:CSRWIdx(t,2)-1));
    CSTrailTable = extractedData(CSRWIdx(t,1):CSRWIdx(t,2)-1,:);
    
    CSBinnedData = groupsummary(CSTrailTable,'DateTime','second','sum','sense1Events');
    Timestamp = datetime(string(CSBinnedData.second_DateTime));
    LickRates = CSBinnedData.sum_sense1Events;
    Trail = repmat([strcat("Trail ",num2str(t))],length(Timestamp),1);
    resultTemp = table(Timestamp,LickRates,Trail);
    
    if t == 1
        CSRate = resultTemp;
    else
        CSRate = [CSRate;resultTemp];
    end
    
    
    
    if t ~= n-1
        RWtrailSet{t} = [(time(CSRWIdx(t,2)+2:CSRWIdx(t+1,1)-1,:)-time(CSRWIdx(t,2),1))';...
                     t*ones(2,length(CSRWIdx(t,2)+2:CSRWIdx(t+1,1)-1))];
        lickCounts_CSRW(t,2) = sum(extractedData.(VariableNames{3})(CSRWIdx(t,2)+2:CSRWIdx(t+1,1)-1));
        
        RWTempTable = extractedData(CSRWIdx(t,2):CSRWIdx(t+1,1)-1,:);
        RWBinnedData = groupsummary(RWTempTable,'DateTime','second','sum','sense1Events');

        Timestamp = datetime(string(RWBinnedData.second_DateTime));
        LickRates = RWBinnedData.sum_sense1Events;
        Trail = repmat([strcat("Trail ",num2str(t))],length(Timestamp),1);
        resultTemp = table(Timestamp,LickRates,Trail);

        if t == 1
            RWRate = resultTemp;
        else
            RWRate = [RWRate;resultTemp];
        end
        

        
    else
        RWtrailSet{t} = [(time(CSRWIdx(t,2)+2:size(time,1)-1,:)-time(CSRWIdx(t,2),1))';...
                     t*ones(2,length(CSRWIdx(t,2)+2:size(time,1)-1))];
        lickCounts_CSRW(t,2) = sum(extractedData.(VariableNames{3})(CSRWIdx(t,2)+2:size(time,1)-1));
        
        RWTempTable = extractedData(CSRWIdx(t,2)+2:size(time,1),:);
        RWBinnedData = groupsummary(RWTempTable,'DateTime','second','sum','sense1Events');
        RWAVGRate{t} = RWBinnedData;
        
        Timestamp = datetime(string(RWBinnedData.second_DateTime));
        LickRates = RWBinnedData.sum_sense1Events;
        Trail = repmat([strcat("Trail ",num2str(t))],length(Timestamp),1);
        resultTemp = table(Timestamp,LickRates,Trail);
        RWRate = [RWRate;resultTemp];
        
    end

%     CStrailSet{t} = [(time(CSRWIdx(t,1)+2:CSRWIdx(t,2)-1,:)-time(CSRWIdx(t,1),1))';...
%                      (t-fillingRange)*ones(1,length(CSRWIdx(t,1)+2:CSRWIdx(t,2)-1));...
%                      (t+fillingRange)*ones(1,length(CSRWIdx(t,1)+2:CSRWIdx(t,2)-1))];
end

% figure;hold on;grid on;
% for tIdx = 1:n-1
%     if ~isempty(CStrailSet{tIdx})
%         for dotIdx = 1:size(CStrailSet{tIdx},2)
%             x = CStrailSet{tIdx}(1:2,dotIdx)';
%             y1 = CStrailSet{tIdx}(3,dotIdx)*ones(size(x));
%             y2 = CStrailSet{tIdx}(4,dotIdx)*ones(size(x));
%             X = [x,fliplr(x)];
%             Y = [y1,fliplr(y2)];
%             fill(X,Y,'k');
%         end
%     end
% end


%% Plotting figures

figure;
subplot(221)
plot([0,0],[0,n-1],'r--','LineWidth',3);hold on;
for tIdx = 1:n-1
    plot(CStrailSet{tIdx}(1:2,:),CStrailSet{tIdx}(3:4,:),'k','linewidth',8)
end
set(gca,'YGrid','on');ylim([0,n]);yticks(linspace(0,n-1,n));
text(-0.5,n-0.5,'CS onset','Color','red','FontSize',12,'FontWeight','bold');
title({['Licking Events Induced by Cue Stimulation'],['Total: ',num2str(n-1),' Trails']});
xlabel('time (sec)');ylabel('# of Trail');


subplot(223)
plot([0,0],[0,n-1],'r--','LineWidth',3);hold on;
for tIdx = 1:n-1
    plot(RWtrailSet{tIdx}(1:2,:),RWtrailSet{tIdx}(3:4,:),'k','linewidth',8)
end
set(gca,'YGrid','on');ylim([0,n]);yticks(linspace(0,n-1,n));
text(-0.5,n-0.5,'Reward','Color','red','FontSize',12,'FontWeight','bold');
title({['Licking Events Induced by Reward'],['Total: ',num2str(n-1),' Trails']});
xlabel('time (sec)');ylabel('# of Trail');

% subplot(222)
% plot(1:size(lickCounts_CSRW,1),lickCounts_CSRW(:,1)/t_CS,'r-');grid on;
% title({['Change of licking rates (CS onset)'],['Total: ',num2str(n-1),' Trails']});
% xlabel('# of Trail');ylabel('Freq (Hz)');
% xticks(linspace(0,n-1,n));
% 
% subplot(224)
% plot(1:size(lickCounts_CSRW,1),lickCounts_CSRW(:,2)/t_RW,'b-');grid on;
% title({['Change of licking rates (Reward)'],['Total: ',num2str(n-1),' Trails']});
% xlabel('# of Trail');ylabel('Freq (Hz)');
% xticks(linspace(0,n-1,n));

subplot(222)
plot(timeofday(CSRate.Timestamp),CSRate.LickRates,'r-o');grid on;hold on;
% bar(timeofday(CSRate.Timestamp),CSRate.LickRates);
title({['Change of licking rates (CS onset)'],['Total: ',num2str(n-1),' Trails']});
xlabel('# of Trail');ylabel('Licks/s');


subplot(224)
plot(timeofday(RWRate.Timestamp),RWRate.LickRates,'r-o');grid on;hold on;
% bar(timeofday(RWRate.Timestamp),RWRate.LickRates);
title({['Change of licking rates (Reward)'],['Total: ',num2str(n-1),' Trails']});
xlabel('# of Trail');ylabel('Licks/s');



figure;
plot(1:size(lickCounts_CSRW,1),lickCounts_CSRW(:,1)/t_CS,'r-');grid on;hold on;
plot(1:size(lickCounts_CSRW,1),lickCounts_CSRW(:,2)/t_RW,'b-');
title({['Change of licking rates'],['Total: ',num2str(n-1),' Trails']});
xlabel('# of Trail');ylabel('Freq (Hz)');
legend({'CS onset','Reward'})
xticks(linspace(0,n-1,n));


figure;
plot(timeofday(CSRate.Timestamp),CSRate.LickRates,'r-');grid on;hold on;
plot(timeofday(RWRate.Timestamp),RWRate.LickRates,'b-');
title({['Change of licking rates'],['Total: ',num2str(n-1),' Trails']});
xlabel('# of Trail');ylabel('Licks/s');
legend({'CS onset','Reward'})



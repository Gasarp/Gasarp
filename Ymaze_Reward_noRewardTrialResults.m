 function Ymaze_Reward_noRewardTrialResults()
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
 
 % Written by Kavinda Liyanagama, Okinawa Institute of Science and Technology (2025)
 
 % This program analyzes the data and generates the following plots 
 
      % 1) 'Reward' type or 'No Reward' type  
      % 2) Trial Duration for each trial
      % 3) Rewarded trial percentage for each session, 
      % 4) Number of Rewarded trials / Total trials  for each session
      % 5) Lick occurrences during Reward_Time ± lickDuration (3s etc) period 
      % 6) Lick occurrences during No_Reward_Time  ± lickDuration (3s etc) period 
      % 7) Lick occurrences during first 3s of each trial 
      % 8) RewardRate for reward/noReward trials is computed
      % 9 ) Lick Rate for each 100ms during Reward_Time  ± lickDuration (3s) is computed
 
 % Single file or multiple simultaneous files can be analyzed with ths program.
 % All results are saved to output Excel files.

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
 
  close All
  clearAllMemoizedCaches; % This MATLAB function clears caches for all MemoizedFunction objects
  
  rewardDuration =1; % Reward Duration
  lickDuration = 10;  % Reward_Time ± lickDuration (3s etc) is considered to show lick occurrences 
  selectedDuration =20 ;  % This duration is considered to check lickrate 
  blockSize = 2; % Average durations of each 3 trials to compute average lick 
 
  %  Open file and take files' name and path  
  [files,filePath] = uigetfile('*.*','MultiSelect','on'); % Select multiple files 
  if ~iscell(files)
      files = {files}; % Convet to a cell array if only 1 file is selected 
  end
 
  noOfSelectedFiles= length(files); % Find number of selected files
    
  if  noOfSelectedFiles ==0 % Check if no Behavioural file is selected
     return;      % Quit the function 
  end
  
  
  [typeFile1,fileName1,~] = fileparts(files{1}); % Take the first file name without extension 
  [typeFile2,fileName2,~] = fileparts(files{noOfSelectedFiles}); % Take the last file name without extension 
  joinedFileName = strcat(fileName1,'-',fileName2);
    
  if noOfSelectedFiles == 1                
       joinedFileName = fileName1;   % If only one file is selected 
  end 
   
  mkdir(strcat(fullfile(filePath,'Results/',joinedFileName))); % Create a new folder to save results
  outputFileName = strcat(joinedFileName ,'- TrialResults.xls') ;  % Create an output Excel file to save results  
  outputFileName2 = strcat(joinedFileName ,'-TrialResults_Initial.xls') ;  % Create an output Excel file to save results  
  outputFileName3 = strcat(joinedFileName ,'-RewardRate_Block_Results.xls') ;
 
  rewardPercentageArray = zeros(1,noOfSelectedFiles);   % To store percentage of Rewarded Trials in each session
  noOfRewardedTrialsArray = zeros(1,noOfSelectedFiles); % To store number of Rewarded trials in each session
  noOfTotalTrialsArray = zeros(1,noOfSelectedFiles);    % To store total number of trials in each session
  sessionNames = compose('S%d', 1:noOfSelectedFiles);   % Create initial session names
    
  x0=100; y0=10; width=1000;height=400; % Set origin and dimensions of figures
      
  for i=1:noOfSelectedFiles  %  Loop through each selected file
      
      fileName = files{i};
      [type1,fileNameShort,ext1] = fileparts(fileName); % Take file name without extension 
         
      opts = detectImportOptions(fileName); 
      opts.SelectedVariableNames= {'DateTime','SystemMsg','sense1Events'}; % Read data from  selected columns
      eventDataAll = readtable(fileName, opts); 
      eventData = eventDataAll.(2); 
      
      trialStartTimeData = eventDataAll.(1)(strcmp(eventData,'start trial') ==1,:); % Extract time from rows containing 'start trial' string  
      reward_NoRewardTimeData = eventDataAll.(1)( strcmp(eventData,'Reward')| strcmp(eventData,'No Reward')==1,:); % Extract time from rows containing 'Reward' or ' No Reward' string     

      reward_TimeData = eventDataAll.(1)( strcmp(eventData,'Reward')==1,:); % Extract time from rows containing 'Reward'string     
      no_Reward_TimeData = eventDataAll.(1)( strcmp(eventData,'No Reward')==1,:); % Extract time from rows containing 'No Reward'string 
      
      trialDurations = etime(datevec(reward_NoRewardTimeData),datevec(trialStartTimeData(1:length(reward_NoRewardTimeData)))); % Find time from Trial Start to Reward for all Trials 
      trialDurations = trialDurations +rewardDuration ; % Add reward duration
      
      eventNameData = eventData(strcmp(eventData,'Reward')| strcmp(eventData,'No Reward') ==1,:); % Extract info from rows containing 'Reward' or ' No Reward' string 
  
      Index_Reward   = transpose(find(~contains(eventNameData,'No Reward'))); % Find indexes of 'Reward' trials 
      Index_noReward = transpose(find(contains(eventNameData,'No Reward')));  % Find indexes of 'No Reward' trials
      
      rewardPercentage =  (length(Index_Reward)/ (length(Index_Reward) + length(Index_noReward))) *100; % Calculate reward percentage of current trial
      rewardPercentageArray(i) = rewardPercentage;
      noOfRewardedTrialsArray(i)= length(Index_Reward); % Total number of Rewarded trials in current session
      noOfTotalTrialsArray(i) = length(Index_Reward)+ length(Index_noReward) ; % Total number of trials in current session
      
      if contains(fileNameShort,'Reversal')   
          currentSessionName = strcat(sessionNames{i},'(Re)'); % Add a sufix to session name if it's a Reversal file
          sessionNames{i} = currentSessionName;
      end
  
      figureName1 = [fileNameShort,'- Trial Results']; 
      x0 = x0+20;  y0= y0+20;
      h0 = figure('Name',figureName1,'position',[x0,y0,width,height]);
      
      plot(Index_Reward,1,'-p', 'MarkerSize',8 ,'MarkerFaceColor','blue' ,'MarkerEdgeColor','blue'); hold on 
      
      if length(Index_noReward) >=1
         plot(Index_noReward,2, '-p','MarkerSize',8, 'MarkerFaceColor','red','MarkerEdgeColor','red'); hold on
      end
      
      title('Reward/No Reward') ;  
      xlabel('Trial Number') ; 
      set(gca,'YTick',0:1:3,'YTickLabel',{'','Reward','No Reward',''},'fontweight','bold','fontsize',12) ;
      % set(gca,'LooseInset',get(gca,'TightInset')); % Set figure's outerspace 
      ylim([0 3]);
      xlim([0.5 length(eventNameData)+1]);
  
      % Add legends to the above plots
      h = zeros(2,1);
      h(1)=plot(nan,nan,'p' ,'MarkerFaceColor','blue', 'MarkerSize' ,7, 'Color' , 'blue');
      h(2)=plot(nan,nan,'p' ,'MarkerFaceColor','red', 'MarkerSize' ,7, 'Color' , 'red');
         
      legend(h,'Reward','No Reward','FontSize',12,'Position',[0.80, 0.83, 0.08, 0.07])  
      hold off ;     
      
      figureName2 = [fileNameShort,'- Trial Duration']; 
      x0 = x0+20;  y0= y0+20;
      ht = figure('Name',figureName2,'position',[x0,y0,width,height]);
      
      plot(Index_Reward,trialDurations (Index_Reward),'marker' , 'o', 'linestyle' , 'none', 'MarkerSize',7 ,'MarkerFaceColor','blue' ,'MarkerEdgeColor','blue'); hold on 
      
      if length(Index_noReward) >=1
         plot(Index_noReward,trialDurations (Index_noReward), 'marker' , 'o','linestyle' , 'none','MarkerSize',7, 'MarkerFaceColor','red','MarkerEdgeColor','red'); hold on
      end
      
      title('Trial Duration')   
      xlabel('Trial Number')  
      ylabel('Time (s)') 
      set(gca,'XTick',0:1:length(eventNameData),'fontweight','bold','fontsize',12)
      xlim([0.5 length(eventNameData)+1]);
  
      % Add legends to the above plots
      h = zeros(2,1);
      h(1)=plot(nan,nan,'o' ,'MarkerFaceColor','blue', 'MarkerSize' ,7, 'Color' , 'blue');
      h(2)=plot(nan,nan,'o' ,'MarkerFaceColor','red', 'MarkerSize' ,7, 'Color' , 'red');
         
      legend(h,'Reward','No Reward','FontSize',12,'Position',[0.80, 0.83, 0.08, 0.07])  
      hold off ;
      
      % Write results to the output excel file.  
      outputDataTable1 = array2table (transpose(Index_Reward), 'VariableNames' , {'Reward_Trials'});
      writetable(outputDataTable1,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName),'sheet', strcat(sessionNames{i}) ,'Range','A1')     
      outputDataTable2 = array2table (transpose(Index_noReward), 'VariableNames' , {'No_Reward_Trials'});
      writetable(outputDataTable2,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName),'sheet', strcat(sessionNames{i}) ,'Range','B1') 
      saveas(h0,strcat(fullfile(filePath,'Results/',joinedFileName,'/'),figureName1,'.fig'))
      
      outputDataTable3 = array2table (trialDurations (Index_Reward), 'VariableNames' , {'Duration_Reward_Trials'});
      writetable(outputDataTable3,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName),'sheet', strcat(sessionNames{i}) ,'Range','D1') 
      outputDataTable4 = array2table (trialDurations (Index_noReward), 'VariableNames' , {'Duration_No_Reward_Trials'});
      writetable(outputDataTable4,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName),'sheet', strcat(sessionNames{i}) ,'Range','E1') 
      saveas(ht,strcat(fullfile(filePath,'Results/',joinedFileName,'/'),figureName2,'.fig'))

      rewardLickArray = []; % To store licks' time around reward period 
      noRewardLickArray = [] ; % to store licks's time around no_lick period 

      for tempTrialNo=1:length(reward_TimeData) % Loop through each reward trial
          % Find times of licks 
          rewardLick_TimeData = eventDataAll.(1)((etime(datevec(eventDataAll.(1)),datevec(reward_TimeData(tempTrialNo))) > -lickDuration) & (etime(datevec(eventDataAll.(1)),datevec(reward_TimeData(tempTrialNo))) <=lickDuration) &  (eventDataAll.(3) ==1),:);
          % Find dime difference from Reward for each selected lick 
          timeDifferenceReward = etime(datevec(rewardLick_TimeData),datevec( reward_TimeData(tempTrialNo)));
          timeDifferenceReward( timeDifferenceReward==0)=100; % Set the difference to 100 when licks occur at zero. Later 100 is reset to 0   ( max difference is 3s etc)
          rewardLickArray(tempTrialNo,1:length(timeDifferenceReward)) =  transpose(timeDifferenceReward);  % Store time difference data for current trial 
      end 
      
       for tempTrialNo=1:length(no_Reward_TimeData) % Loop through each no_reward trial
          % Find times of licks 
          noRewardLick_TimeData = eventDataAll.(1)((etime(datevec(eventDataAll.(1)),datevec(no_Reward_TimeData(tempTrialNo))) > -lickDuration) & (etime(datevec(eventDataAll.(1)),datevec(no_Reward_TimeData(tempTrialNo))) <=lickDuration) &  (eventDataAll.(3) ==1),:);
          % Find dime difference from No_Reward for each selected lick 
          timeDifferenceNoReward = etime(datevec(noRewardLick_TimeData),datevec( no_Reward_TimeData(tempTrialNo)));
          timeDifferenceNoReward( timeDifferenceNoReward==0)=100; % Set the difference to 100 when licks occur at zero. Later 100 is reset to 0   ( max difference is 3s etc)
          noRewardLickArray(tempTrialNo,1:length(timeDifferenceNoReward)) =  transpose(timeDifferenceNoReward) ; % Store time difference data for current trial 
       end 
       
       rewardLickArray(rewardLickArray==0)=NaN;  % Set zero values to NaN to prevent showing non-existant data 
       rewardLickArray(rewardLickArray==100)=0; % Reset 100 to  to show licks occurring at zero
       
       noRewardLickArray(noRewardLickArray==0)=NaN;  % Set zero values to NaN to prevent showing non-existant data 
       noRewardLickArray(noRewardLickArray==100)=0; % Reset 100 to  to show licks occurring at zero
       
      [aveLickCountRewardArray,rewardLick_SEM]= findAverageLickRate(rewardLickArray,lickDuration,selectedDuration);
      [aveLickCountNoRewardArray,noRewardLick_SEM]= findAverageLickRate(noRewardLickArray,lickDuration,selectedDuration);
          
      figureNameRewardLicks = [fileNameShort,'- Reward Licks']; 
      x0 = x0+10;  
      hr = figure('Name',figureNameRewardLicks,'position',[x0,y0+500,500,400]);
      
      if(size(rewardLickArray,2) ==0) % Check if no licks exist for Reward trials 
        rewardLickArray = zeros (size(rewardLickArray,1), 1);
        rewardLickArray(rewardLickArray==0)=NaN;  
      end 
     
      plot(rewardLickArray,1:length(reward_TimeData),'marker' , 'o', 'linestyle' , 'none', 'MarkerSize',5 ,'MarkerFaceColor','red' ,'MarkerEdgeColor','red'); hold on 
      xline(0  ,'--k','LineWidth',1); hold on % Mark Reward Start
      xline(1  ,'--k','LineWidth',1); hold on % Mark Reward End
      title('Reward Licks')   
      xlabel('Time (s)')  
      ylabel('Trial Number') 
      
      set(gca,'YTick',1:1:length(reward_TimeData),'YTickLabel',Index_Reward ,'fontweight','bold','fontsize',12)
      if length(reward_TimeData)>0
        ylim ([0.5 length(reward_TimeData)+0.5])
      end 
      xlim([-lickDuration lickDuration])
      
      rewardLickArray = rewardLickArray + lickDuration;     % To set timeline's start point as zero 
      noRewardLickArray = noRewardLickArray + lickDuration; % To set timeline's start point as zero 
       
      outputDataTable5 = array2table (transpose(rewardLickArray), 'VariableNames' , strcat('Reward_Trial_NO_',string(Index_Reward(1:length(Index_Reward)))))  ;   % Lick Time Data
      writetable(outputDataTable5,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName),'sheet',  strcat(sessionNames{i}) ,'Range','K1'); 
      saveas(hr,strcat(fullfile(filePath,'Results/',joinedFileName,'/'),figureNameRewardLicks,'.fig'))            
      
      figureNameNoRewardLicks = [fileNameShort,'- No_Reward Licks']; 
      x0 = x0+10; 
      hr = figure('Name', figureNameNoRewardLicks,'position',[x0+600+50,y0+500,500,400]);
      
      if(size(noRewardLickArray,2) ==0) % Check if no licks exist for NoReward trials 
        noRewardLickArray = zeros(size(noRewardLickArray,1), 1);
        noRewardLickArray(noRewardLickArray==0)=NaN;  
      end 
       
      plot(noRewardLickArray,1:length(no_Reward_TimeData),'marker' , 'o', 'linestyle' , 'none', 'MarkerSize',5 ,'MarkerFaceColor','black' ,'MarkerEdgeColor','black'); hold on 
      xline(0  ,'--r','LineWidth',1); hold on % Mark Reward Start
      xline(1  ,'--r','LineWidth',1); hold on % Mark Reward End
      title('No-Reward Licks')   
      xlabel('Time (s)')  
      ylabel('Trial Number') 
      set(gca,'YTick',1:1:length(no_Reward_TimeData),'YTickLabel',Index_noReward,'fontweight','bold','fontsize',12)

      if length(no_Reward_TimeData)>0 
          ylim([0.5 length(no_Reward_TimeData)+0.5])
      end 
      
      xlim([-lickDuration lickDuration])
      
      outputDataTable6 = array2table (transpose(noRewardLickArray), 'VariableNames' , strcat('No_Reward_Trial_NO_',string(Index_noReward(1:length(Index_noReward)))))  ;    % Lick Time Data
      writetable(outputDataTable6,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName),'sheet',  strcat(sessionNames{i}) ,'Range','K100'); 
      saveas(hr,strcat(fullfile(filePath,'Results/',joinedFileName,'/'),figureNameNoRewardLicks,'.fig'))
      
      rewardInitialLickArray = []; % To store licks' time at the start of reward trials
      noRewardInitialLickArray = [] ; % To store licks' time at the start of no-reward trials 
       
      rewardTrialStartTimes = trialStartTimeData(Index_Reward);  % Extract start time of reward trials 
      noRewardTrialStartTimes = trialStartTimeData(Index_noReward); % Extract start time of no-reward trials 
       
      for tempTrialNo=1:length(rewardTrialStartTimes) % Loop through each reward trial
          % Find times of licks 
          rewardLick_TimeData_TrialStart = eventDataAll.(1)((etime(datevec(eventDataAll.(1)),datevec(rewardTrialStartTimes(tempTrialNo))) > 0) & (etime(datevec(eventDataAll.(1)),datevec(rewardTrialStartTimes(tempTrialNo))) <=lickDuration) &  (eventDataAll.(3) ==1),:);
          % Find time difference from trial start for each selected lick 
          timeDifferenceReward = etime(datevec(rewardLick_TimeData_TrialStart),datevec(rewardTrialStartTimes(tempTrialNo)));
          timeDifferenceReward( timeDifferenceReward==0)=100; % Set the difference to 100 when licks occur at zero. Later 100 is reset to 0   ( max difference is 3s etc)
          rewardInitialLickArray(tempTrialNo,1:length(timeDifferenceReward)) =  transpose(timeDifferenceReward);  % Store time difference data for current trial 
      end 
      
      for tempTrialNo=1:length(noRewardTrialStartTimes) % Loop through each no-reward trial
          % Find times of licks 
          noRewardLick_TimeData_TrialStart = eventDataAll.(1)((etime(datevec(eventDataAll.(1)),datevec(noRewardTrialStartTimes(tempTrialNo))) > 0) & (etime(datevec(eventDataAll.(1)),datevec(noRewardTrialStartTimes(tempTrialNo))) <=lickDuration) &  (eventDataAll.(3) ==1),:);
          % Find time difference from trial start for each selected lick 
          timeDifferenceReward = etime(datevec( noRewardLick_TimeData_TrialStart),datevec(noRewardTrialStartTimes(tempTrialNo)));
          timeDifferenceReward( timeDifferenceReward==0)=100; % Set the difference to 100 when licks occur at zero. Later 100 is reset to 0   ( max difference is 3s etc)
          noRewardInitialLickArray(tempTrialNo,1:length(timeDifferenceReward)) =  transpose(timeDifferenceReward);  % Store time difference data for current trial 
      end 
       
      rewardInitialLickArray(rewardInitialLickArray==0)=NaN;  % Set zero values to NaN to prevent showing non-existant data 
      rewardInitialLickArray(rewardInitialLickArray==100)=0; % Reset 100 to  to show licks occurring at zero
       
      noRewardInitialLickArray(noRewardInitialLickArray==0)=NaN;  % Set zero values to NaN to prevent showing non-existant data 
      noRewardInitialLickArray(noRewardInitialLickArray==100)=0; % Reset 100 to  to show licks occurring at zero
      
      
      figureNameRewardLicksInitial = [fileNameShort,'- Reward Licks (Initial)']; 
      x0 = x0+10;  
      hs = figure('Name',figureNameRewardLicksInitial,'position',[x0,y0+550,500,400]);
      
      if(size(rewardInitialLickArray,2) ==0) % Check if no licks exist for Reward trials's initial period 
        rewardInitialLickArray = zeros (size(rewardInitialLickArray,1), 1);
        rewardInitialLickArray(rewardInitialLickArray==0)=NaN;  
      end 
     
      plot(rewardInitialLickArray,1:length(rewardTrialStartTimes),'marker' , 'o', 'linestyle' , 'none', 'MarkerSize',5 ,'MarkerFaceColor','red' ,'MarkerEdgeColor','red'); hold on 
      %  xline(0  ,'--k','LineWidth',1); hold on % Mark Reward Start
      %  xline(1  ,'--k','LineWidth',1); hold on % Mark Reward End
      title('Reward Licks (Initial)')   
      xlabel('Time (s)')  
      ylabel('Trial Number') 
      
      set(gca,'YTick',1:1:length(reward_TimeData),'XTick',0:1:lickDuration, 'YTickLabel',Index_Reward ,'fontweight','bold','fontsize',12)
      
      if length(reward_TimeData) >0 
           ylim ([0.5 length(reward_TimeData)+0.5])
      end 
     
      xlim([0 lickDuration])
       
      outputDataTable7 = array2table (transpose(rewardInitialLickArray), 'VariableNames' , strcat('Reward_Trial_NO_',string(Index_Reward(1:length(Index_Reward)))))  ;   % Lick Time Data
      writetable(outputDataTable7,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName2),'sheet',  strcat(sessionNames{i}) ,'Range','A1'); 
      saveas(hs,strcat(fullfile(filePath,'Results/',joinedFileName,'/'),figureNameRewardLicksInitial,'.fig'))            
      
      figureNameNoRewardLicksInitial = [fileNameShort,'- No_Reward Licks (Initial)']; 
      x0 = x0+10; 
      ht = figure('Name', figureNameNoRewardLicksInitial,'position',[x0+600+50,y0+500,500,400]);
      
      if(size(noRewardInitialLickArray,2) ==0) % Check if no licks exist for NoReward trials 
        noRewardInitialLickArray = zeros (size(noRewardInitialLickArray,1), 1);
        noRewardInitialLickArray(noRewardInitialLickArray==0)=NaN;  
      end 
       
      plot(noRewardInitialLickArray,1:length(no_Reward_TimeData),'marker' , 'o', 'linestyle' , 'none', 'MarkerSize',5 ,'MarkerFaceColor','black' ,'MarkerEdgeColor','black'); hold on 
      %xline(0  ,'--r','LineWidth',1); hold on % Mark Reward Start
      %xline(1  ,'--r','LineWidth',1); hold on % Mark Reward End
      title('No-Reward Licks (Initial)')   
      xlabel('Time (s)')  
      ylabel('Trial Number') 
      set(gca,'YTick',1:1:length(no_Reward_TimeData),'XTick',0:1:lickDuration, 'YTickLabel',Index_noReward,'fontweight','bold','fontsize',12)
     
      if length(no_Reward_TimeData) >0
           ylim([0.5 length(no_Reward_TimeData)+0.5])
      end 
     
      xlim([0 lickDuration])
      
     
      outputDataTable8 = array2table (transpose(noRewardInitialLickArray), 'VariableNames' , strcat('No_Reward_Trial_NO_',string(Index_noReward(1:length(Index_noReward)))))  ;  % Initial Lick Time Data
      writetable(outputDataTable8,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName2),'sheet',  strcat(sessionNames{i}) ,'Range','A100'); 
      saveas(ht,strcat(fullfile(filePath,'Results/',joinedFileName,'/'),figureNameNoRewardLicksInitial,'.fig'))
      
      durationRateReward= length(trialDurations(Index_Reward))/ (sum( trialDurations(Index_Reward))/60); % Find duration rate for Reward licks
      output3DataTable1 = array2table (durationRateReward, 'VariableNames' , {'RewardRate_RewardTrials'});
      writetable(output3DataTable1,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet', strcat(sessionNames{i}) ,'Range','A1') 
            
      rewardTrialDurationDataArray= trialDurations(Index_Reward);
      
      if rem(length(rewardTrialDurationDataArray),blockSize) ~=0
          divisionRounded1 =  fix (length(rewardTrialDurationDataArray) /blockSize);
          newArrayLength1= divisionRounded1 * blockSize;
          rewardTrialDurationDataArray= rewardTrialDurationDataArray(1:newArrayLength1); % Discard last trials if rem(rewardTrialDurationDataArray,blockSize) ~=0
      end
      
      rewardTrialDurationDataArray= transpose(sum(reshape(rewardTrialDurationDataArray , blockSize,[]))); % Compute sum of each 3 durations
      
      for ind=1:length(rewardTrialDurationDataArray)
           rewardTrialDurationDataArray(ind) = blockSize / (rewardTrialDurationDataArray(ind)/60) ; % Divide by 60 to convert to minutes
      end 
      
      output3DataTable2 = array2table (rewardTrialDurationDataArray, 'VariableNames' , {'RewardRate_Each3_RewardTrials'});
      writetable(output3DataTable2,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet', strcat(sessionNames{i}) ,'Range','B1') 
                
      durationRateNoReward= length(trialDurations(Index_noReward))/ (sum( trialDurations(Index_noReward))/60); % Find duration rate for No Reward licks
      output3DataTable3 = array2table (durationRateNoReward, 'VariableNames' , {'RewardRate_NoReward_Trials'});
      writetable(output3DataTable3,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet', strcat(sessionNames{i}) ,'Range','D1') 

      noRewardTrialDurationDataArray= trialDurations(Index_noReward);
      
      if rem(length(noRewardTrialDurationDataArray),blockSize) ~=0
          divisionRounded2 =  fix ( length(noRewardTrialDurationDataArray) /blockSize);
          newArrayLength2= divisionRounded2 * blockSize;
          noRewardTrialDurationDataArray= noRewardTrialDurationDataArray(1:newArrayLength2); % Discard last trials if rem(noRewardTrialDurationDataArray,blockSize) ~=0
      end
      
      noRewardTrialDurationDataArray= transpose(sum(reshape(noRewardTrialDurationDataArray , blockSize,[]))); % Compute sum of each 3 durations
      
      for ind=1:length(noRewardTrialDurationDataArray)
          noRewardTrialDurationDataArray(ind) = blockSize / (noRewardTrialDurationDataArray(ind)/60) ; % Divide by 60 to convert to minutes
      end 
      
      output3DataTable4 = array2table (noRewardTrialDurationDataArray, 'VariableNames' , {'RewardRate_Each3_NoRewardTrials'});
      
      writetable(output3DataTable4,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet', strcat(sessionNames{i}) ,'Range','E1') ;
      
      output3DataTable5 = array2table (transpose(-lickDuration:0.1:(-lickDuration+selectedDuration-0.1)), 'VariableNames' , {'Time(s)'});
      writetable(output3DataTable5,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet', strcat(sessionNames{i}) ,'Range','G1') ;
     
      output3DataTable6 = array2table (transpose(aveLickCountRewardArray));
      writetable(output3DataTable6,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet', strcat(sessionNames{i}) ,'Range','H1') ;
      writematrix('Reward_LickRate', fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet',strcat(sessionNames{i}),'Range','H1');
         
      output3DataTable7 = array2table (transpose(aveLickCountNoRewardArray));
      writetable(output3DataTable7,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet', strcat(sessionNames{i}) ,'Range','I1') ;  
      writematrix('NoReward_LickRate', fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet',strcat(sessionNames{i}),'Range','I1');
     
      output3DataTable8 = array2table (transpose(rewardLick_SEM));
      writetable(output3DataTable8,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet', strcat(sessionNames{i}) ,'Range','K1') ;  
      writematrix('SEM_RewardLick', fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet',strcat(sessionNames{i}),'Range','K1');
     
      output3DataTable9 = array2table (transpose(noRewardLick_SEM));
      writetable(output3DataTable9,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet', strcat(sessionNames{i}) ,'Range','L1') ;  
      writematrix('SEM_NoRewardLick', fullfile(filePath,'Results/',joinedFileName,'/',outputFileName3),'sheet',strcat(sessionNames{i}),'Range','L1');
         
      if i== noOfSelectedFiles % Check if it's the last session to plot results summary 

          figureName1 = ['Summary( Reward Percentage ) -', joinedFileName];
          x0 = x0+20;  y0= y0+20;
          h1 = figure('Name',figureName1,'position',[x0,y0,width,height]);
          
          plot(rewardPercentageArray,'-x','MarkerSize',10,'MarkerEdgeColor','red','LineWidth',2 );
          setPlotAxis('Reward Percentage','Percentage of Obtaining the Reward',noOfSelectedFiles,sessionNames);
          ylim([0 100]);
          
          figureName2 = ['Summary( Trials ) -',joinedFileName];
          x0 = x0+20;  y0= y0+20;
          h2 = figure('Name',figureName2,'position',[x0,y0,width,height]);
             
          plot(noOfTotalTrialsArray,'-x','MarkerSize',10,'MarkerEdgeColor','blue','LineWidth',2 ); hold on;
          plot(noOfRewardedTrialsArray,'-x','MarkerSize',10,'MarkerEdgeColor','red','LineWidth',2 ); 
          
          legend('# of Total Trials','# of Rewarded Trials');    
          setPlotAxis('Total Trials/Rewarded Trials','Number of Trials',noOfSelectedFiles,sessionNames);
          
          outputDataSessionNames = array2table (string( transpose(sessionNames)), 'VariableNames' , {'Session_Name'});
          writetable(outputDataSessionNames,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName),'sheet', strcat('Summary - (',sessionNames{1},'-',sessionNames{noOfSelectedFiles},')') ,'Range','A1') % Write results to the output excel file     
 
          outputDataArray3 = [ transpose(rewardPercentageArray) transpose(noOfTotalTrialsArray) transpose(noOfRewardedTrialsArray)];
          outputDataTable3 = array2table (outputDataArray3, 'VariableNames' , {'Reward_Percentage','No_Of_Total_Trials','No_Of_Rewarded_Trials'});
          writetable(outputDataTable3,fullfile(filePath,'Results/',joinedFileName,'/',outputFileName),'sheet', strcat('Summary - (',sessionNames{1},'-',sessionNames{noOfSelectedFiles},')') ,'Range','B1') % Write results to the output excel file     
          
          % Save generated figures

          saveas(h1,strcat(fullfile(filePath,'Results/',joinedFileName,'/'),figureName1,'.fig')) 
          saveas(h2,strcat(fullfile(filePath,'Results/',joinedFileName,'/'),figureName2,'.fig')) 
         
      end        
   end 
 end 
 
 
 function setPlotAxis(plotTitle,yLabel,noOfSelectedFiles,sessionNames)
    % This function adds basic features to a plot 
 
    title(plotTitle);
    xlabel('Session Number') 
    ylabel(yLabel)  
    set(gca,'XTick',1:1:noOfSelectedFiles,'XTickLabel',sessionNames,'fontweight','bold','fontsize',12,'LooseInset',get(gca,'TightInset'));
    xlim([0.75 noOfSelectedFiles]);

 end
 
 
 function [trialDuration,timeDiffTone,timeDiffReward, timeToFirstLick, trialType, currentRowNo]=  findTrialInfo(currentRowNo,data)
    % This function returns each Trial's info

    timeStart = data.(1)(currentRowNo); % Find current Trial's start time
    rewardDuration=1;
    trialType=0;
    ITI =0;
    timeToFirstLick =NaN;
    lickFound=0;
     
    toneRowNo = currentRowNo; % To find Tone Start row number
    while ( ~(contains(data.(3)(toneRowNo),'Tone') || contains(data.(3)(toneRowNo),'end')))  % Continue until 'Tone' is found   
        
        toneRowNo =toneRowNo+1; % Next row
    end
    
    timeTone = data.(1)(toneRowNo); % Start Time of Tone 
    timeDiffTone = etime(datevec(timeTone),datevec(timeStart)); % Find time from Trial Start to Tone Start
        
    rewardRowNo = toneRowNo; % To find Reward's start row number
    while (  ~(contains(data.(3)(rewardRowNo),'Reward') || contains(data.(3)(rewardRowNo),'end')) )   % Continue until 'Reward' is found   
        
        rewardRowNo =rewardRowNo+1; % Next row
    end 

    lickRowNo = rewardRowNo;  % To find First lick's row number    
    while (~(contains(data.(3)(lickRowNo),'start trial')|| contains(data.(3)(lickRowNo),'end')) )   % Continue until 'Reward' is found  

        lickRowNo =lickRowNo+1; % Next row
        
        if data.(2)(lickRowNo)==1
             lickFound=1;
             break;
        end  
    end 
    
    if contains(data.(3)(rewardRowNo),'No Reward')==1
        trialType =1; % No reward trial
        ITI = 4;
    elseif contains(data.(3)(rewardRowNo),'Reward')==1
        trialType =2; % Reward trial 
        ITI =5;
    end
    
    
    timeReward = data.(1)(rewardRowNo); % Start Time of Reward
    timeDiffReward = etime(datevec(timeReward),datevec(timeStart)); % Find time from Trial Start to Reward Start
    
    trialDuration =  timeDiffReward+rewardDuration + ITI; % Reward duration (1s) +  ITI duration (4s)
    
    if lickFound ==1
      timeLick = data.(1)(lickRowNo);   % Find Time of First Lick
      timeToFirstLick = etime(datevec(timeLick),datevec(timeReward)); % Find time from Reward Start to First Lick
    end

    nextTrialRowNo= rewardRowNo; % To set next trial's starting row number
    while ( ~contains(data.(3)(nextTrialRowNo),'start trial') && ~contains(data.(3)(nextTrialRowNo),'end') )  % Continue until 'start trial' or 'end' is found
         nextTrialRowNo=nextTrialRowNo+1; % Next row
    end
    
    currentRowNo = nextTrialRowNo-1; % Set current row number
     
 end 

 
 
 
function [aveLickCountArray,SEM_Array]=  findAverageLickRate(lickTimeArray,lickDuration,selectedDuration)
   % This function returns Average lickRound for each second of the selected period
   
   timeWindow =0.1 ; % Time window is 100 ms to compute lick rate
   noOfTrials = size(lickTimeArray,1); 
   
   lickCountArray = zeros( noOfTrials, selectedDuration/timeWindow);
   
   SEM_Array= zeros(noOfTrials, selectedDuration/timeWindow);
   
   for trialNo =1: noOfTrials   
         
      timeThreshold = -lickDuration;   % Set current Threshold's starting time
      
      for indexTime=1:(selectedDuration/timeWindow) % Loop through to find Lick info for each 100 ms  
            
          lickIndexArray= find((lickTimeArray(trialNo,:)- timeThreshold ) <= timeWindow & (lickTimeArray(trialNo,:)- timeThreshold ) > 0); % Find indexes of Licks during selected period
          noOfLicks=  numel(lickIndexArray); %  Find number of Licks  during selected period
           
          if noOfLicks >0
             lickCountArray(trialNo,indexTime)= noOfLicks; % Store number of Licks for each  100ms in the selected period 
          end 
             
          timeThreshold =timeThreshold+ timeWindow; % Move to next 100ms  of selected period            
      end
   end
  
   aveLickCountArray =zeros (1,selectedDuration/timeWindow);
   
   if noOfTrials >1
       aveLickCountArray = mean(lickCountArray); % Find average number of Licks for each 100 ms in the selected period 
       SEM_Array = std(lickCountArray) /sqrt(noOfTrials); % Find Standard Error of Mean (SEM) 
   else
       aveLickCountArray = lickCountArray; 
   end
  
end   
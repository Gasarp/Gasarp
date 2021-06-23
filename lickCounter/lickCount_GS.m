% Author: Gideon
% Received: 2021/05/27
% Purpose: As a reference for making a MATLAB visualization program
% Developer: Kang-Yu, Chu

function lickCount_GS()
    
%   Open file and take file's name and path 
    [fileName,filePath] = uigetfile({'*.xlsx'});
    
    opts = detectImportOptions(fileName); 
    opts.SelectedVariableNames= {'DateTime','eventDuration','sense1Events','SystemMsg'}; % Read data from these seelcted columns
    filteredData = readtable(fileName, opts);     % Filtered data array
    [noOfRows,noOfColums] = size(filteredData);    
    
    noOfTrials = nnz(strcmp(filteredData.(2),'CS onset')); % Count number of Trials 
    noOfTrials = nnz(strcmp(filteredData.(2),'Reward')); % Count number of Trials 
 
    cueLickArray(1) = 0; % Create an array to store Cue_Lick Info
    rewardLickArray(1) =0; % Create an array to store Reward_Lick Info
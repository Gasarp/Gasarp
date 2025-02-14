Last update: 2025/2/14

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Imaging data Analysis: Hierarchical Clustering

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Program: hierarchical_clustering_algorithm.m

This program enables clustering of subregions (or ROIs) using a Hierarchical Clustering algorithm. In brief, clustering is performed following the steps below:

 % Step 1: Dimensionality reduction is performed using Principal Component Analysis (PCA)
 % Step 2: Hierarchical clustering is applied on dimensionally reduced data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

1. Instructions for the code:

a. Ensure you have MATLAB installed.

b. Download and extract the matlab file to your preferred directory.

c. Open MATLAB and set the current folder to the directory where the files are located.

d. Add the directory to your MATLAB path using:

addpath(genpath('your_directory_path'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

2. Running the Code

a. Open hierarchical_clustering_algorithm.m in MATLAB.

B. Click Run (or press F5).

Follow the prompts in the command window and select your input data.
Note that the input file must contain only the dataset for the desired time window of analysis.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

3. Output

The script generates output in the form of figures saved in an output file in the same folder as the input data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

4. Troubleshooting

If you encounter issues, ensure all dependencies are in the correct path.

Check for missing toolboxes using:

ver

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

5. User-defined parameters:

a. Line 17: retainedVariance = 90; 
Cumulative Variance threshold to decide retained number of Principal components 

b. Line 63: Number of clusters. Either one of these can be used:
i. algorithm-defined number of clusters (using Elbow method)
Ii. user-defined number of clusters

c. Line 216: Computing distance metric using the 'Euclidean' method
          Using 'complete' method to compute linkageTree 

d. Line 246: ColorThreshold for the dendrogram is computed 

e. Line 251: dendrogram (linkageTree,100,'ColorThreshold', 4)
Number of clusters in the dendrogram can be set by user

The following message will appear once the analysis is completed: "Analysis Completed"



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Behavioral Data Analysis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

1. Program: Ymaze_Reward_noRewardTrialResults.m

% This program analyzes Y-maze behavioral data and generates following plots to show:
 
      % 1) 'Reward' type or  'No Reward' type  
      % 2) Trial Duration for each trial
      % 3) Rewarded trial percentage for each session, 
      % 4) Number of Rewarded trials / Total trials  for each session
      % 5) Lick occurrences during Reward_Time ± lickDuration (3s etc) period 
      % 6) Lick occurrences during No_Reward_Time  ± lickDuration (3s etc) period 
      % 7) Lick occurrences during first 5s of each trial (user-defined)
      % 8) RewardRate for reward/noReward trials is computed
      % 9 ) Lick Rate for each 100ms during Reward_Time  ± lickDuration (3s) is found
 
 % A Single file or multiple files can be analyzed simultaneously 

2. Program: findVelocityAndLickRate.m

% This program analyzes behavioral data and generates following plots: 
 
      % 1) Velocity at each position  for 'Reward' type or  'No Reward' type 
      % 2) LickRate at each position for 'Reward' type or  'No Reward' type (LickRate for reward period of 2s shows at the end)
      % 3) Each trial's Velocity/ LickRate results are written in output excel files 

      
 % A Single file or multiple files can be analyzed simultaneously 
 % All results are saved to an Output Excel file 
 

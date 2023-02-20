%% File Description:

% This function will concatenate all .nev files with a selected prefix in 
% a selected folder for the purpose of sorting. It will also unmerge those
% files after sorting and save them as sorted .nev files

%% Define the file location, prefix, & merge choice
clear
clc

% Where are your selected files located? 
file_path = 'C:\Users\rhpow\Documents\Work\Northwestern\Monkey_Data\Pop\20220308\New folder\';

% Define the prefix of the files you wish to sort
file_prefix = '20220308_Pop_PG';

% Do you want to 'Merge' or 'Unmerge'?
merge_choice = 'Merge';

%% Run processSpikesForSorting function

processSpikesForSorting(file_path, file_prefix, merge_choice);


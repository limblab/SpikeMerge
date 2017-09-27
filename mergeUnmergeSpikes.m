% mergeUnmergeSpikes.m
% This is an example file on how to use processSpikesForSorting.
% Fill in the file_path where your data is located and the file_prefix of
% the files which spikes you want to concatenate for sorting (variable
% file_prefix_all in this example.) If you have files from two or 
% more different tasks you can still concatenate the spikes but should make
% sure that you create different bdfs for each task (unless you know
% what you're doing.)

file_prefix_all = 'Chips_20170913_COactpas_area2';
file_path = 'C:\Users\rhc307\Projects\limblab\data-preproc\ForceKin\Chips\20170913\preCDS\merging\';

% Run processSpikesForSorting for the first time to combine spike data from
% all files with a name starting with file_prefix.
mergingStatus = processSpikesForSorting(file_path,file_prefix_all);

%% Check that the spike data has been successfully merged
while strcmp(mergingStatus,'merged spikes')
    % Now go to OfflineSorter and sort your spikes!
    disp(['Sort ''' file_prefix_all '-spikes.nev'' in OfflineSorter and save sorted file as '''...
        file_prefix_all '-spikes-s.ynev'' then press any key to continue.'])
    pause
    % Run processSpiesForSorting again to separate sorted spikes into their
    % original files.
    mergingStatus = processSpikesForSorting(file_path,file_prefix_all);
    if strcmp(mergingStatus,'processed')
        % If everything went well, create bdfs for your files (you might
        % want to split them up by task.)
%         bdf_some = get_nev_mat_data([file_path file_prefix_some],3);
%         bdf_all = get_nev_mat_data([file_path file_prefix_all],3);
    end
end
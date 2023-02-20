function processSpikesForSorting(file_path, file_prefix, merge_choice)
%% File Description:

% This function will concatenate all .nev files with a selected prefix in 
% a selected folder for the purpose of sorting. It will also unmerge those
% files after sorting and save them as sorted .nev files
%
% -- Inputs --
% file_path: the location of the files you want to merge / unmerge
% file_prefix: the prefix for all the files you will merge together
% merge_choice: 'Merge' or 'Unmerge'

%% Merge spike data
if strcmp(merge_choice, 'Merge')

    % Find the desired files
    NEVlist = dir(fullfile(file_path,[file_prefix '*.nev']));
    NEVlist = NEVlist(cellfun('isempty',(regexp({NEVlist(:).name},'-s'))));
    disp(['Merging ' num2str(length(NEVlist)) ' files.'])

    % Put the desired file in a single structure & remove artifacts
    NEVNSx_all = cerebus2NEVNSx(file_path, file_prefix, 'noanalog');
    NEVNSx_all.NEV = artifact_removal(NEVNSx_all.NEV,10,0.0005,1);
    
    % Strip digital data from the .nev file into new variable
    disp('Stripping digital data.')
    NEVdigital.TimeStamp = NEVNSx_all.NEV.Data.SerialDigitalIO.TimeStamp;
    NEVdigital.TimeStampSec = NEVNSx_all.NEV.Data.SerialDigitalIO.TimeStampSec;
    NEVdigital.InsertionReason = NEVNSx_all.NEV.Data.SerialDigitalIO.InsertionReason;
    NEVdigital.UnparsedData = NEVNSx_all.NEV.Data.SerialDigitalIO.UnparsedData;
    NEVNSx_all.NEV.Data.SerialDigitalIO.TimeStamp=[];
    NEVNSx_all.NEV.Data.SerialDigitalIO.TimeStampSec=[];
    NEVNSx_all.NEV.Data.SerialDigitalIO.InsertionReason=[];
    NEVNSx_all.NEV.Data.SerialDigitalIO.UnparsedData=[];
    save(fullfile(file_path, [file_prefix '-digital']), 'NEVdigital');
    
    % Save the stripped spikes-only data
    disp('Saving merged NEV')
    saveNEVSpikesLimblab(NEVNSx_all.NEV, file_path, [file_prefix '-m.nev'])
    
    % Save metatags for unmerging
    disp('Saving metatags')
    MetaTags = NEVNSx_all.MetaTags;
    save(fullfile(file_path,[file_prefix '-metatags']), 'MetaTags')
    
    % Done
    disp('Merged: sort & re-add the .nev file with the -ms suffix')
end

%% Unmerge spike data
if strcmp(merge_choice, 'Unmerge')

    % Load the meta-tag file
    load(fullfile(file_path,[file_prefix '-metatags']),'MetaTags')
    if exist(fullfile(file_path,[file_prefix '-ms.nev']), 'file')
        % Load the now-sorted file
        NEV_sorted = openNEVLimblab('read', fullfile(file_path,[file_prefix '-ms.nev']), 'nosave');
        if exist(fullfile(file_path,[file_prefix '-digital.mat']), 'file')
            disp('Re-integrating digital data.')
            load(fullfile(file_path,[file_prefix '-digital']),'NEVdigital')
            NEV_sorted.Data.SerialDigitalIO.TimeStamp = NEVdigital.TimeStamp;
            NEV_sorted.Data.SerialDigitalIO.TimeStampSec = NEVdigital.TimeStampSec;
            NEV_sorted.Data.SerialDigitalIO.InsertionReason = NEVdigital.InsertionReason;
            NEV_sorted.Data.SerialDigitalIO.UnparsedData = NEVdigital.UnparsedData;
            % Delete the temporary digital data file
            delete(fullfile(file_path,[file_prefix '-digital.mat']))
        end
        
        disp(['Separating ' num2str(length(MetaTags.NEVlist) ) ' files.'])
        for iFile = 1:length(MetaTags.NEVlist)
            % Seperate the meta tags & spikes
            t_offset = (MetaTags.FileStartSec(iFile))*30000;
            NEV_spikes_struct = NEV_sorted.Data.Spikes;
            first_idx = find(NEV_sorted.Data.Spikes.TimeStamp >= MetaTags.FileStartSec(iFile)*30000,1, 'first');
            if iFile < length(MetaTags.NEVlist)
                last_idx = find(NEV_sorted.Data.Spikes.TimeStamp < MetaTags.FileStartSec(iFile+1)*30000,1, 'last');
            else
                last_idx = length(NEV_sorted.Data.Spikes.TimeStamp);
            end
            NEV_spikes_struct.TimeStamp =  NEV_spikes_struct.TimeStamp(first_idx:last_idx) - t_offset;
            NEV_spikes_struct.Electrode =  NEV_spikes_struct.Electrode(first_idx:last_idx);
            NEV_spikes_struct.Unit =  NEV_spikes_struct.Unit(first_idx:last_idx);
            NEV_spikes_struct.Waveform =  NEV_spikes_struct.Waveform(:,first_idx:last_idx);
            NEV = openNEVLimblab('read', fullfile(file_path,MetaTags.NEVlist{iFile}), 'nosave');
            NEV.Data.Spikes = NEV_spikes_struct;
            % Save the now seperated sorted .nev files
            saveNEVSpikesLimblab(NEV, file_path, strcat(MetaTags.NEVlist{iFile}(1:end-4), '-s.nev'))
        end
        % Delete the temporary meta tag file
        delete(fullfile(file_path,[file_prefix '-metatags.mat']))
    end
end



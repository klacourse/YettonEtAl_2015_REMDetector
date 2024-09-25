% Script to convert REMs density per second into 3-sec mini-epoch

% Script definition
detector_run = 'HatzilabrouEtAl';
group_label = 'det_MOR_3s';
name_label = 'MOR_Hatzilabrou';
MINI_EPOCH_LEN_S = 3;
REM_bout_fileName = 'REM_start_end.csv';
filePath = 'C:\Users\klacourse\Documents\NGosselin\data\edf\RBD\10_first_subjects\';

% Ask the user to select the REMs output to analyze.
[Source,path_REMs_out]=uigetfile('*.mat','Select REMs detector output files','MultiSelect', 'on');
if ~iscell(Source)
    Source = {Source};
end

% Extract the edf filename from the Source
% Loop through each element of the cell array
subject_name = {};
psg_name = {};
for i = 1:length(Source)
    % Use regexp to match the pattern between 'remDetectorOutput' and the first '-'
    extractedStr = regexp(Source{i}, 'REMsOut_(.*?) date', 'tokens');
    % Display the extracted string
    if ~isempty(extractedStr)
        fprintf('Extracted string:%s\n', extractedStr{1}{1});
    else
        fprintf('Pattern not found\n');
    end
    subject_name{i} = extractedStr{1}{1};
    psg_name{i} = [subject_name{i} '.edf'];
end

% Read the REMs bouts
remStartAndEnd = readtable([filePath REM_bout_fileName]);

% Find out the start in sec of each REM bout for each subject
for i = 1:length(psg_name)
    startTimes = [0];
    durTimes = [0];
    startTimes = remStartAndEnd.start_sec(strcmp(psg_name{i},remStartAndEnd.Name));
    durTimes = remStartAndEnd.duration_sec(strcmp(psg_name{i},remStartAndEnd.Name));
    if isempty(startTimes)
        warning('No start and end times found for files, using defaults...');
        startTimes = [0];
        durTimes = [0];
    end
    MOR_Yetton_cur_file = [];
    % Load the matlab REMs output file and 
    % construct the real start sec of 3-s MOR
    REMs_out = load([path_REMs_out Source{i}]);
    if length(REMs_out.windowLabels)==length(startTimes)
        for i_REM_out = 1 : length(startTimes)
            MOR_Yetton_cur_bout = [];
            if length(REMs_out.windowLabels{i_REM_out})==durTimes(i_REM_out)
                % REMs density for each second 
                for i_sec = 1 : MINI_EPOCH_LEN_S : length(REMs_out.windowLabels{i_REM_out})
                    if sum(REMs_out.windowLabels{i_REM_out}(i_sec:i_sec+MINI_EPOCH_LEN_S-1))>0
                        MOR_Yetton_cur_bout=[MOR_Yetton_cur_bout,startTimes(i_REM_out)+i_sec-1]; % python index
                    end
                end
                MOR_Yetton_cur_file = [MOR_Yetton_cur_file, MOR_Yetton_cur_bout];
            else
                disp('Problem with the REMs bouts for %s', psg_name{i});
            end
        end
    else 
        fprintf('Problem with the REMs bouts for %s\n', psg_name{i});
    end

    % Create a table for the MOR_Yetton
    group = cell(length(MOR_Yetton_cur_file),1);
    name = cell(length(MOR_Yetton_cur_file),1);
    start_sec = cell(length(MOR_Yetton_cur_file),1);
    duration_sec = cell(length(MOR_Yetton_cur_file),1);
    channels = cell(length(MOR_Yetton_cur_file),1);
    for i_MOR = 1: length(MOR_Yetton_cur_file)
        group{i_MOR} = group_label;
        name{i_MOR} = name_label;
        start_sec{i_MOR} = MOR_Yetton_cur_file(i_MOR);
        duration_sec{i_MOR} = MINI_EPOCH_LEN_S;

        channels{i_MOR} = sprintf("['%s']",string(REMs_out.LOC_label{1}));
    end
    % Create a table
    MOR_yetton_table_cur_file = table(group, name, start_sec, duration_sec, channels);
    % Save the table 
    file_2_save = [filePath subject_name{i} '.txt'];
    writetable(MOR_yetton_table_cur_file,file_2_save);
    fprintf('%s file created and saved\n', file_2_save);
end

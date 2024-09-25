function [fileNames,path_EEG] = edf2matMultiSelect()
[Source,path_EEG]=uigetfile('*.edf','Select EEG .edf files','MultiSelect', 'on');
%Source = 'R6_2004.edf';
%path_EEG = 'C:\Users\klacourse\Documents\NGosselin\data\edf\RBD\10_first_subjects\';
if iscell(Source) 
    fileNames = cell(size(Source));
    names = cell(size(Source));
    for ii=1:numel(Source)
        names{ii}=strrep(Source{ii},'.edf','');
        if ~exist([path_EEG names{ii} '.mat'],'file')
            input_EEG=fullfile(path_EEG,Source{ii});            
            [hdr, record] = edfread(input_EEG); 
            save([path_EEG '/' names{ii}],'record','hdr')
        end
        fileNames{ii} = [path_EEG names{ii} '.mat'];
    end
else
    fileNames = cell(1);
    names = cell(1);    
    names{1}=strrep(Source,'.edf','');
    if ~exist([path_EEG names{1} '.mat'],'file')        
        input_EEG=fullfile(path_EEG,Source);
        names{1}=strrep(Source,'.edf','');
        [hdr, record] = edfread(input_EEG);
        if mean(mean(record,2)) < 0
            record = record*1000;
            warning('Data apears to be recorded in Volts, but should be in milliVolts. Converting V->mV. This warning will only appear once.')
        end
        save([path_EEG '/' names{1}],'record','hdr')
    end
    fileNames{1} = [path_EEG names{1} '.mat'];
end
end
    

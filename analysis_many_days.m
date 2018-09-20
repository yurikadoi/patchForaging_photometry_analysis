%%
% Get a list of all files and folders in this folder.
files = dir('E:\27')
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir]
% Extract only those that are directories.
subFolders = files(dirFlags)
% Print folder names to command window.
for k = 44: length(subFolders)
    fprintf('Sub folder #%d = %s\n', k, subFolders(k).name);
    date=subFolders(k).name
    cd E:\27\
    cd(date)
    drive_dir = pwd;
    DAQextraction_forPhotometry
    save([date '_daqData'])
    disp('Hooray!')
    cd C:\Users\kuros\Documents\MATLAB\photometry_analysis\27
    mkdir(date)
    cd(date)
    save([date '_daqData'])
    lick_preceded_or_not([date '_daqData','.mat'])
    
    clear all
    disp('Yay!')
    files = dir('E:\27');
    % Get a logical vector that tells which is a directory.
    dirFlags = [files.isdir];
    % Extract only those that are directories.
    subFolders = files(dirFlags);
end
%error on 0604
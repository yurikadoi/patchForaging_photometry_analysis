%%
% Get a list of all files and folders in this folder.
files = dir('C:\Users\kuros\Documents\MATLAB\photometry_analysis\27');
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);
%
%VS=['20180423','20180427','20180429','20180502','20180503','20180506','20180509','20180510','20180513','20180517','20180522','20180530','20180531','20180602','20180604','20180606','20180609','20180610','20180613'];
VS=['20180423','20180427','20180429','20180502','20180503','20180506','20180509','20180510','20180513','20180517','20180522','20180530','20180531','20180602','20180606','20180609','20180610','20180613'];

DLS=['20180424','20180430','20180504','20180508','20180511','20180516','20180518','20180523','20180527','20180529','20180601','20180603','20180605','20180608','20180612'];
%%

VS_all_target_time_licking_preceded=[];
VS_all_target_interval_licking_preceded=[];
VS_all_target_time_licking_not_preceded = [];
VS_all_target_interval_licking_not_preceded=[];
DLS_all_target_time_licking_preceded=[];
DLS_all_target_interval_licking_preceded=[];
DLS_all_target_time_licking_not_preceded=[];
DLS_all_target_interval_licking_not_preceded=[];
%%
for i = 44: length(subFolders)
    files = dir('C:\Users\kuros\Documents\MATLAB\photometry_analysis\27');
    % Get a logical vector that tells which is a directory.
    dirFlags = [files.isdir];
    % Extract only those that are directories.
    subFolders = files(dirFlags);
    fprintf('Sub folder #%d = %s\n', i, subFolders(i).name);
    date=subFolders(i).name
    
    cd(date)
    load([date '_lickPrecedeData.mat'])
    target_time_licking_preceded=[];
    target_interval_licking_preceded=[];
    target_time_licking_not_preceded=[];
    target_interval_licking_not_preceded=[];
    for j=1:length(good_trials)
        temp_index=find(diff(find(patchesStop_rewvalve{good_trials(j)} > 0.5)) > 2);
        temp_vec=diff(find(patchesStop_rewvalve{good_trials(j)} > 0.5));
        all_rew_intervals=temp_vec(temp_index);
        for k=1:length(target_rew_time{good_trials(j)})
            target_time=target_rew_time{good_trials(j)}(k);
            target_index=all_rew_intervals(target_rew_index{good_trials(j)}(k)-1);
            if isempty(find(patchesStop_licks{good_trials(j)}(target_time-msLickPrior:target_time)< 0.8))
                %licking did not precede
                if ~isempty(strfind(VS,date))
                    VS_all_target_time_licking_not_preceded = [VS_all_target_time_licking_not_preceded target_time];
                    VS_all_target_interval_licking_not_preceded = [VS_all_target_interval_licking_not_preceded target_index];
                    
                elseif ~isempty(strfind(DLS,date))
                    DLS_all_target_time_licking_not_preceded = [DLS_all_target_time_licking_not_preceded target_time];
                    DLS_all_target_interval_licking_not_preceded = [DLS_all_target_interval_licking_not_preceded target_index];
                    
                end
                %                 target_time_licking_preceded = [target_time_licking_preceded target_time];
                %                 target_interval_licking_preceded = [target_interval_licking_preceded target_index];
                
            else
                %licking preceded
                if ~isempty(strfind(VS,date))
                    VS_all_target_time_licking_preceded = [VS_all_target_time_licking_preceded target_time];
                    VS_all_target_interval_licking_preceded = [VS_all_target_interval_licking_preceded target_index];
                    
                elseif ~isempty(strfind(DLS,date))
                    DLS_all_target_time_licking_preceded = [DLS_all_target_time_licking_preceded target_time];
                    DLS_all_target_interval_licking_preceded = [DLS_all_target_interval_licking_preceded target_index];
                    
                end
                %                 target_time_licking_not_preceded = [target_time_licking_not_preceded target_time];
                %                 target_interval_licking_not_preceded = [target_interval_licking_not_preceded target_index]; 
            end 
        end        
    end
    cd ..
    
end
%%
figure;
%minus 3000 because msPrior was set to 3000 msec
histogram(VS_all_target_time_licking_preceded -3000,10,'BinWidth',1000)
%xticks=([4000 2000 22000]);
%xticklabels=({'4000','6000','8000','10000','12000','14000','16000','18000','20000','22000'});
hold on
histogram(VS_all_target_time_licking_not_preceded - 3000,10,'BinWidth',1000)
legend('licking preceeded','licking not preceeded')
title('VS reward timing in the patch')



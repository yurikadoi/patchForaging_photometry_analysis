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

VS_all_lick_no_precede_trial_gcamp_matrix=[];
VS_all_lick_precede_trial_gcamp_matrix=[];
DLS_all_lick_no_precede_trial_gcamp_matrix=[];
DLS_all_lick_precede_trial_gcamp_matrix=[];
%%
for i = 3: length(subFolders)
    files = dir('C:\Users\kuros\Documents\MATLAB\photometry_analysis\27');
    % Get a logical vector that tells which is a directory.
    dirFlags = [files.isdir];
    % Extract only those that are directories.
    subFolders = files(dirFlags);
    fprintf('Sub folder #%d = %s\n', i, subFolders(i).name);
    date=subFolders(i).name
    
    cd(date)
    load([date '_lickPrecedeData.mat'])
    if ~isempty(strfind(VS,date))
        VS_all_lick_no_precede_trial_gcamp_matrix = [VS_all_lick_no_precede_trial_gcamp_matrix; lick_no_precede_trial_gcamp_matrix];
        
        VS_all_lick_precede_trial_gcamp_matrix = [VS_all_lick_precede_trial_gcamp_matrix; lick_precede_trial_gcamp_matrix];
    elseif ~isempty(strfind(DLS,date))
        DLS_all_lick_no_precede_trial_gcamp_matrix = [DLS_all_lick_no_precede_trial_gcamp_matrix; lick_no_precede_trial_gcamp_matrix];
        
        DLS_all_lick_precede_trial_gcamp_matrix = [DLS_all_lick_precede_trial_gcamp_matrix; lick_precede_trial_gcamp_matrix];
    end
    cd ..
    
end

%%
%plotting
x=1:size(VS_all_lick_precede_trial_gcamp_matrix,2);
figure;
plot(x,mean(lick_no_precede_trial_rewvalve_matrix,1),'k')
hold on
%shadedErrorBar(x,mean(lick_precede_trial_lick_matrix,1),std(lick_precede_trial_lick_matrix))
shadedErrorBar(x,mean(DLS_all_lick_precede_trial_gcamp_matrix,1),std(VS_all_lick_precede_trial_gcamp_matrix),'r',1)
shadedErrorBar(x,mean(DLS_all_lick_no_precede_trial_gcamp_matrix,1),std(DLS_all_lick_no_precede_trial_gcamp_matrix),'b',1)

title(['DLS licking preceded before 0.2s or not, ' dateStr ', n=',num2str(size(DLS_all_lick_no_precede_trial_gcamp_matrix,1)),',',num2str(size(DLS_all_lick_precede_trial_gcamp_matrix,1))])
xlabel('time [msec]')
ylabel('photometry')
legend('rewvalve','','','lick precede','','','','lick not precede','','Location','southeast')
%%
temp_index=find(diff(find(patchesStop_rewvalve{good_trials(j)} > 0.5)) > 2);
temp_vec=diff(find(patchesStop_rewvalve{good_trials(j)} > 0.5));
all_rew_intervals=temp_vec(temp_index)


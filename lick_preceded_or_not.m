function lick_preceded_or_not(matfile)
load(matfile)
currentDirectory = pwd;
[upperPath, dateStr, ~] = fileparts(currentDirectory);

good_trials = [];
%target_rew_index=zeros{length(patchesStop_rewvalve),1};
%target_rew_time=zeros{length(patchesStop_rewvalve),1};
target_rew_index=[repmat({0},1,length(patchesStop_rewvalve))];
target_rew_time=[repmat({0},1,length(patchesStop_rewvalve))];
target_rew_time_all_trials=[repmat({0},1,length(patchesStop_rewvalve))];


for i = 1:length(patchesStop_rewvalve)
    if ~isempty(find(patchesStop_rewvalve{i} > 0.5))
        length(find(diff(find(patchesStop_rewvalve{i} > 0.5)) > 2))+1;
        if ~isempty(find(diff(find(patchesStop_rewvalve{i} > 0.5)) > 1900))
            temp1=find(diff(find(patchesStop_rewvalve{i} > 0.5)) > 2);
            temp2=find(diff(find(patchesStop_rewvalve{i} > 0.5)) > 1900);
            temp4=intersect(temp1,temp2);
            
            
            
            for k=1:length(temp4)
                target_rew_index{i}(k)=find(temp1==temp4(k))+1;
            end
            
            %target_rew_index(i)=find(temp1==temp2)+1;
            good_trials=[good_trials i];
            
            %get the time for the target reward
            temp3=diff(find(patchesStop_rewvalve{i} > 0.5));
            for k=1:length(temp4)
                target_rew_time{i}(k)=find(patchesStop_rewvalve{i} > 0.5,1)+sum(temp3(1:temp4(k)));
                
            end
            for k=1:length(temp1)
                target_rew_time_all_trials{i}(k)=find(patchesStop_rewvalve{i} > 0.5,1)+sum(temp3(1:temp1(k)));
                
            end
        end
    end
end

%%
%target_rew_index=[repmat({0},1,length(patchesStop_rewvalve))];
%lick_precede_trial_IndexNum=[]
msLickPrior = 200;
msPrior=2000;
msAfter=2000;
lick_no_precede_trialNum=[];
lick_precede_trialNum=[];
lick_no_precede_trial_rewvalve_matrix=[];
lick_no_precede_trial_lick_matrix=[];
lick_no_precede_trial_gcamp_matrix=[];
lick_precede_trial_rewvalve_matrix=[];
lick_precede_trial_lick_matrix=[];
lick_precede_trial_gcamp_matrix=[];
%lick_precede_trialNum=[repmat({0},1,length(good_trials))];
for j=1:length(good_trials)
    for k=1:length(target_rew_time{good_trials(j)})
        target_time=target_rew_time{good_trials(j)}(k);
        
        %         figure;
        %         plot(patchesStop_rewvalve{good_trials(j)}((target_time-msPrior):target_time+msAfter))
        %         hold on
        %         plot(patchesStop_licks{good_trials(j)}((target_time-msPrior):target_time+msAfter))
        %         plot(patchesStop_gcamp{good_trials(j)}((target_time-msPrior):target_time+msAfter)-patchesApp_baseline(good_trials(j)))
        %whether licking preceded or not
        if isempty(find(patchesStop_licks{good_trials(j)}(target_time-msLickPrior:target_time)< 0.8))
            %licking did not precede
            lick_no_precede_trialNum= [lick_no_precede_trialNum [good_trials(j) k]];
            lick_no_precede_trial_rewvalve_matrix=[lick_no_precede_trial_rewvalve_matrix; (patchesStop_rewvalve{good_trials(j)}((target_time-msPrior):target_time+msAfter)-patchesApp_baseline(good_trials(j)))'];
            lick_no_precede_trial_lick_matrix=[lick_no_precede_trial_lick_matrix; (patchesStop_licks{good_trials(j)}((target_time-msPrior):target_time+msAfter)-patchesApp_baseline(good_trials(j)))'];
            lick_no_precede_trial_gcamp_matrix=[lick_no_precede_trial_gcamp_matrix; (patchesStop_gcamp{good_trials(j)}((target_time-msPrior):target_time+msAfter)-patchesApp_baseline(good_trials(j)))'];
            
        else
            %licking preceded
            lick_precede_trialNum= [lick_precede_trialNum [good_trials(j) k]];
            %lick_precede_trial_IndexNum=[lick_precede_trial_IndexNum k]
            %             disp('!!!!')
            %             figure;
            %             plot(patchesStop_rewvalve{good_trials(j)}((target_time-msPrior):target_time+msAfter))
            %             hold on
            %             plot(patchesStop_licks{good_trials(j)}((target_time-msPrior):target_time+msAfter))
            %             plot(patchesStop_gcamp{good_trials(j)}((target_time-msPrior):target_time+msAfter)-patchesApp_baseline(good_trials(j)))
            lick_precede_trial_rewvalve_matrix=[lick_precede_trial_rewvalve_matrix; (patchesStop_rewvalve{good_trials(j)}((target_time-msPrior):target_time+msAfter)-patchesApp_baseline(good_trials(j)))'];
            lick_precede_trial_lick_matrix=[lick_precede_trial_lick_matrix; (patchesStop_licks{good_trials(j)}((target_time-msPrior):target_time+msAfter)-patchesApp_baseline(good_trials(j)))'];
            lick_precede_trial_gcamp_matrix=[lick_precede_trial_gcamp_matrix; (patchesStop_gcamp{good_trials(j)}((target_time-msPrior):target_time+msAfter)-patchesApp_baseline(good_trials(j)))'];
            
        end
    end
    
end
x=1:size(lick_no_precede_trial_gcamp_matrix,2);
figure;
plot(x,mean(lick_no_precede_trial_rewvalve_matrix,1),'k')
hold on
%shadedErrorBar(x,mean(lick_precede_trial_lick_matrix,1),std(lick_precede_trial_lick_matrix))
if size(lick_no_precede_trial_gcamp_matrix,1)==1
    plot(x,mean(lick_precede_trial_gcamp_matrix,1),'r')
else
    shadedErrorBar(x,mean(lick_precede_trial_gcamp_matrix,1),std(lick_precede_trial_gcamp_matrix),'r',1)
end

if size(lick_no_precede_trial_gcamp_matrix,1)==1
    plot(x,mean(lick_no_precede_trial_gcamp_matrix,1),'b')
else
    
    shadedErrorBar(x,mean(lick_no_precede_trial_gcamp_matrix,1),std(lick_no_precede_trial_gcamp_matrix),'b',1)
end
title(['licking preceded before 0.2s or not, ' dateStr ', n=',num2str(size(lick_no_precede_trial_gcamp_matrix,1)),',',num2str(size(lick_precede_trial_gcamp_matrix,1))])
xlabel('time [msec]')
ylabel('photometry')
if size(lick_no_precede_trial_gcamp_matrix,1)==1
    legend('rewvalve','','','lick precede','','lick not precede','','Location','northeast')
else
    legend('rewvalve','','','lick precede','','','','lick not precede','','Location','northeast')
    
end
save([dateStr '_lickPrecedeData','.mat'])
savefig(['licking_preceded_or_not',dateStr])
saveas(gcf,['licking_preceded_or_not',dateStr],'png')
% figure;
% plot(x,mean(lick_no_precede_trial_rewvalve_matrix,1))
% hold on
% %shadedErrorBar(x,mean(lick_no_precede_trial_lick_matrix,1),std(lick_no_precede_trial_lick_matrix))
% shadedErrorBar(x,mean(lick_no_precede_trial_gcamp_matrix,1),std(lick_no_precede_trial_gcamp_matrix),'r')
% title('licking did not preceded before 0.2s')
% xlabel('time [msec]')
% ylabel('photometry')

%% sampleDAQextraction_forYurika.m - example of extracting trial data from DAQ signal in main foraging task

% last edit: 9-18-18 MB

%% DAQ channels listing:
% 1 = speed x axis (non-existant in this task)
% 2 = speed y axis (actual treadmill speed)
% 3 = lick sensor
% 4 = water spout open
% 5 = trial events   if positive mV, track appeared, mV = (A.B) / 2; if
% negative mV, trial aborted

% get date
currentDirectory = pwd;
[upperPath, dateStr, ~] = fileparts(currentDirectory);
sessionDate = str2num(dateStr(end-2:end));
mouseNum = str2num(upperPath(end-1:end));
display(sessionDate)

%load daq file
%daqdat = dir('DaqData*.daq');
daqdat = dir('*.daq');

[daq_data, daq_time, abstime, daq_events] = daqread(daqdat.name);

%use trial events (channel 5) to identify trials
trialIDs = []; %store all trial ID

iBin = 1; % keeps track of location in trial events array (column 5 in daq_data)
numPatch = 1; % keeps track of patch number
daq_end = length(daq_data(:,5)); % last index for daq_data time points

patchStop = []; % record 1 for yes patchStop, 0 for no patchStop
msPrior = 3000; % ms prior to patch stop to save per trial (also used for TT)
msAfter = 2000; % ms after included

patchOn_curr = []; % current patchOn index
patchOn_indx = []; % array of all patchOn indices
patchOn_max = []; % maximum trial event value for patchOn

patchOff_curr = 1; % current patchOff index
patchOff_indx = 1; % initialize to 1 so that first 'traveltime' will record from time zero to the first patch stop

patches_type = []; % patch type (i.e. rew size)
nextRew = []; nextOff = []; %use to look forward after patch stop to see
%if reward or patchleave signal comes sooner to determine if mouse stopped on patch
% 
% switch sessionDate
%     case 0529
%         striatum = 2; % DLS
%         msPrior = 1000;
%         B_A = [9 4;7 4; 5 4];
%         
%         BA_group_Trials{1} = [1 2]; trialLength{1} = 5000+msPrior; sameSize{1} = 1;
%         BA_group_Trials{2} = [3 4]; trialLength{2} = 5000+msPrior; sameSize{2} = 1;
%     case 606
%         striatum = 1; % ventral striatum
%         msPrior = 1000;
%         B_A = [9 4;7 4; 5 4];
%         
%         BA_group_Trials{1} = [1 2]; trialLength{1} = 5000+msPrior; sameSize{1} = 1;
%         BA_group_Trials{2} = [3 4]; trialLength{2} = 5000+msPrior; sameSize{2} = 1;
%     case 604
%         striatum = 1; % ventral striatum
%         msPrior = 1000;
%         B_A = [9 4; 8 4; 7 4; 6 4];
%         
%         BA_group_Trials{1} = [1 2]; trialLength{1} = 5000+msPrior; sameSize{1} = 1;
%         BA_group_Trials{2} = [3 4]; trialLength{2} = 5000+msPrior; sameSize{2} = 1;
% end

%% extract trial data from DAQ analog input signals
while iBin < daq_end
    % find next time w 'patchOn' signal
    patchOn_curr = iBin + find(daq_data(iBin:daq_end,5)>.8,1);
    
    if isempty(patchOn_curr) %no more patches appear
        %display('patchOn_curr empty: break')
        break
    end
    patchOn_indx(end+1) = patchOn_curr; %save index if there was a patchOn
    patchOn_max(end+1)= max(daq_data(patchOn_curr:patchOn_curr+12,5)); %max signal during patchOn to determine trial type
    
    % divide by .1 so you can use round to get whole numbers for patchIDs
    % (because if using probe trials, not all IDs approximate integars)
    patches_type(end+1) = round(patchOn_max(end)*10);
    
    % must account for patch stops and patch skips-
    thisBin_patchOn(numPatch,:) = daq_data(patchOn_curr:patchOn_curr+12,5);
    iBin = patchOn_curr + 13;
    
    % see if next reward or next patchOff happens sooner to determine if
    % mouse stopped and save 1 or 0 for patchStop
    nextRew = iBin + find(daq_data(iBin:daq_end,4)>3,1);
    nextOff = iBin + find(daq_data(iBin:daq_end,5)<-.8,1);
    
    if nextRew < nextOff
        patchStop(end+1) = 1;
        numPatch_iBin_nextRew_nextOff_patchStop = [numPatch iBin nextRew nextOff patchStop(end)];
    else
        patchStop(end+1) = 0;
        numPatch_iBin_nextRew_nextOff_patchStop = [numPatch iBin nextRew nextOff patchStop(end)];
        
    end
    % find next time w patchOff signal
    patchOff_curr = iBin + find(daq_data(iBin:daq_end,5)<-.8,1);
    
    if isempty(patchOff_curr) %no more patches appear
        break
    end
    patchOff_indx(end+1) = patchOff_curr; %save index if there was a patchOff
    
    %save patch data aligned t=0 at time patch appears
    if patchOff_curr+msAfter <= length(daq_data(:,2)) % break if +msAfter exceeds last timepoint for daq data
        patchesApp_speed{numPatch} = daq_data(patchOn_curr-msPrior:patchOff_curr+msAfter,2);
        patchesApp_licks{numPatch} = daq_data(patchOn_curr-msPrior:patchOff_curr+msAfter,3);
        patchesApp_rewvalve{numPatch} = .5*daq_data(patchOn_curr-msPrior:patchOff_curr+msAfter,4); %1/2 voltage so it fits plots nicer
        patchesApp_trialevents{numPatch} = .5*daq_data(patchOn_curr-msPrior:patchOff_curr+msAfter,5); % 1/2 so it fits nicer on plots
        patchesApp_gcamp{numPatch} = daq_data(patchOn_curr-msPrior:patchOff_curr+msAfter,6);
        
        %patchesApp_tdTom{numPatch} = daq_data(patchOn_curr-msPrior:patchOff_curr+msAfter,7);
        %added by Yurika
        photometry_baseline = get_photometry_baseline(daq_data(:,6), 1000);
        %
        patchesApp_baseline(numPatch) = photometry_baseline(patchOn_curr-msPrior);
        
    else
        break
    end
    
    if patchStop(end)==1
        patchesStop_speed{numPatch} = daq_data(nextRew-msPrior:patchOff_curr+msAfter,2);
        patchesStop_licks{numPatch} = daq_data(nextRew-msPrior:patchOff_curr+msAfter,3);
        patchesStop_rewvalve{numPatch} = .5* daq_data(nextRew-msPrior:patchOff_curr+msAfter,4); %1/2 voltage so it fits plots nicer
        patchesStop_trialevents{numPatch} = .5*daq_data(nextRew-msPrior:patchOff_curr+msAfter,5); %same
        patchesStop_gcamp{numPatch} = daq_data(nextRew-msPrior:patchOff_curr+msAfter,6);
        photometry_baseline = get_photometry_baseline(daq_data(:,6), 1000);
        patchesStop_baseline(numPatch) = photometry_baseline(nextRew-msPrior);
        
    end
    numPatch=numPatch+1;
end

% %make arrays for all the probe patches
% for iA = 1:4
%     for iB = 1:9
%         if sum(patches_type==iA*10+iB)>0
%             Probes_boolean{iB}{iA} = patches_type==(iA*10+iB)*patchStop; %only count patches mouse stopped on
%             Probes_tNums{iB}{iA} = find(Probes_boolean{iB}{iA});
%         end
%     end
% end

% %% plot individual trials that will be used for mean later, and compile data for means
% for iGroup = 1:length(BA_group_Trials)
%     BA_IDs = BA_group_Trials{iGroup};
%     figure;
%     
%     % make cell arrays for all mean gcamp data for trials that are long
%     % enough, transfer from cell arrays into regular arrays later
%     all_gcamp{iGroup}{1} = [];
%     all_gcamp{iGroup}{2} = [];
%     all_speed{iGroup}{1} = [];
%     all_speed{iGroup}{2} = [];
%     all_licks{iGroup}{1} = [];
%     all_licks{iGroup}{2} = [];
%     
%     for iProbeType = 1:length(BA_IDs)
%         %BA_IDs
%         numTrials = length(Probes_tNums{B_A(BA_IDs(iProbeType),1)}{B_A(BA_IDs(iProbeType),2)});
%         
%         % reward time does not need to be replotted each trial per trial type
%         iTrial_temp = 1; %plot reward same color as first trial
%         tNum_temp = Probes_tNums{B_A(BA_IDs(iProbeType),1)}{B_A(BA_IDs(iProbeType),2)}(iTrial_temp);
%         
%         %switch striatum
%         %case 1
%         if sameSize{iGroup}==1
%             RGB = [(-iProbeType+2)*0 + (iProbeType-1)*(1-.5*(iTrial_temp-1)/(numTrials-1)),(-iProbeType+2)*(1-(iTrial_temp-1)/(numTrials-1)) + (iProbeType-1)*0, ...
%                 (-iProbeType+2)*1 + (iProbeType-1)*1];
%         else
%             RGB = [(-iProbeType+2)*0 + (iProbeType-1)*((iTrial_temp-1)/(numTrials-1)),(-iProbeType+2)*(1-(iTrial_temp-1)/(numTrials-1)) + (iProbeType-1)*0, ...
%                 (-iProbeType+2)*1 + (iProbeType-1)*0];
%         end
%         
%         trial_xticks = 0:1000:trialLength{iGroup};
%         trial_xlabels = -msPrior/1000:2:(trialLength{iGroup}-msPrior)/1000;
%         
%         subplot(2,1,1)
%         
%         
%         if length(patchesStop_rewvalve{tNum_temp}) >= trialLength{iGroup}
%             
%             if iProbeType == 1
%                 disp('aaaa')
%                 tNum_temp
%                 plot(patchesStop_rewvalve{tNum_temp}(1:trialLength{iGroup}),'-','color',RGB,'linewidth',2); hold on;
%                 time = 1:trialLength{iGroup};
%                 set(gca,'xtick',trial_xticks,'xticklabel',trial_xlabels);
%             else
%                 disp('bbbb')
%                 tNum_temp
%                 plot(patchesStop_rewvalve{tNum_temp}(1:trialLength{iGroup}),'-','color',RGB,'linewidth',2); hold on;
%                 set(gca,'xtick',trial_xticks,'xticklabel',trial_xlabels);
%             end
%         else
%             for iAttempt=2:numTrials
%                 iTrial_temp = iAttempt; %plot reward same color as first trial
%                 tNum_temp = Probes_tNums{B_A(BA_IDs(iProbeType),1)}{B_A(BA_IDs(iProbeType),2)}(iTrial_temp);
%                 
%                 if length(patchesStop_rewvalve{tNum_temp}) >= trialLength{iGroup}
%                     if iProbeType == 1
%                         plot(patchesStop_rewvalve{tNum_temp}(1:trialLength{iGroup}),'-','color',RGB,'linewidth',2); hold on;
%                     else
%                         plot(patchesStop_rewvalve{tNum_temp}(1:trialLength{iGroup}),'-','color',RGB,'linewidth',2); hold on;
%                     end
%                     
%                     break
%                 end
%             end
%             set(gca,'xtick',trial_xticks,'xticklabel',trial_xlabels);
%         end
%         
%         for iTrial = 1:numTrials
%             tNum = Probes_tNums{B_A(BA_IDs(iProbeType),1)}{B_A(BA_IDs(iProbeType),2)}(iTrial);
%             
%             %add Trial to pool for the mean trace, if trial PRT is long enough
%             if length(patchesStop_gcamp{tNum}) > trialLength{iGroup}
%                 all_gcamp{iGroup}{iProbeType}(end+1,:) = patchesStop_gcamp{tNum}(1:trialLength{iGroup})-patchesApp_baseline(tNum);
%                 all_speed{iGroup}{iProbeType}(end+1,:) = patchesStop_speed{tNum}(1:trialLength{iGroup});
%                 all_licks{iGroup}{iProbeType}(end+1,:) = patchesStop_licks{tNum}(1:trialLength{iGroup});
%                 all_rewvalve{iGroup}{iProbeType} = patchesStop_rewvalve{tNum}(1:trialLength{iGroup});
%             else
%                 display('TRIAL NOT LONG ENOUGH DURATION TO POOL FOR MEAN GCAMP')
%             end
%             
%             
%             if sameSize{iGroup}==1
%                 
%                 RGB = [(-iProbeType+2)*0 + (iProbeType-1)*(1-.5*(iTrial-1)/(numTrials-1)),(-iProbeType+2)*(1-(iTrial-1)/(numTrials-1)) + (iProbeType-1)*0, ...
%                     (-iProbeType+2)*1 + (iProbeType-1)*1];
% 
%             else
%                 RGB = [(-iProbeType+2)*0 + (iProbeType-1)*(1-(iTrial-1)/(numTrials-1)),(-iProbeType+2)*(1-(iTrial-1)/(numTrials-1)) + (iProbeType-1)*0, ...
%                     (-iProbeType+2)*1 + (iProbeType-1)*0];
%                 
%             end
%             
%             plotLength = min([length(patchesStop_gcamp{tNum}) trialLength{iGroup}]);
%             
%             subplot(2,1,1)
%             plot(patchesStop_gcamp{tNum}(1:plotLength)-patchesApp_baseline(tNum),'color',RGB); hold on;
%             plot(patchesStop_trialevents{tNum}(1:plotLength),'color',RGB);
%             
%             subplot(2,1,2)
%             
%             sp2 = subplot(2,1,2);
%             plot(patchesStop_speed{tNum}(1:plotLength),'color',RGB); hold on;
%             set(gca,'xtick',trial_xticks,'xticklabel',trial_xlabels);
%             
%             
%         end
%     end
% end
% %%
% for iGroup = 1:length(all_gcamp)
%     
%     combined.rewvalve1{iGroup} = all_rewvalve{iGroup}{1};
%     combined.rewvalve2{iGroup} = all_rewvalve{iGroup}{2};
%     
%     mean_gcamp1 = mean(all_gcamp{iGroup}{1});
%     mean_gcamp2 = mean(all_gcamp{iGroup}{2});
%     
%     %only run if there is more than one trial to take mean of
%     if length(mean_gcamp1) > 1 && length(mean_gcamp2) > 1
%         
%         combined.mean_gcamp1{iGroup}(:) = mean(all_gcamp{iGroup}{1});
%         combined.mean_gcamp2{iGroup}(:) = mean(all_gcamp{iGroup}{2});
%         
%         combined.mean_speed1{iGroup}(:) = mean(all_speed{iGroup}{1});
%         combined.mean_speed2{iGroup}(:) = mean(all_speed{iGroup}{2});
%         combined.mean_licks1{iGroup}(:) = mean(all_licks{iGroup}{1});
%         combined.mean_licks2{iGroup}(:) = mean(all_licks{iGroup}{2});
%         
%         combined.std_gcamp1{iGroup}(:) = std(all_gcamp{iGroup}{1});
%         combined.std_gcamp2{iGroup}(:) = std(all_gcamp{iGroup}{2});
%         combined.std_speed1{iGroup}(:) = std(all_speed{iGroup}{1});
%         combined.std_speed2{iGroup}(:) = std(all_speed{iGroup}{2});
%         combined.std_licks1{iGroup}(:) = std(all_speed{iGroup}{1});
%         combined.std_licks2{iGroup}(:) = std(all_speed{iGroup}{2});
%         
%         combined.sem_gcamp1{iGroup}(:) = combined.std_gcamp1{iGroup}(:)/sqrt(length(all_gcamp{iGroup}{1}(:,1)));
%         combined.sem_gcamp2{iGroup}(:) = combined.std_gcamp2{iGroup}(:)/sqrt(length(all_gcamp{iGroup}{2}(:,1)));
%         
%         trial_xticks = 0:2000:trialLength{iGroup};
%         trial_xlabels = -msPrior/1000:2:(trialLength{iGroup}-msPrior)/1000;
%         
%         
%         iTrial_temp = 1; numTrials = 2;
% 
%         switch striatum
%             case 1
%                 if sameSize{iGroup}==1
%                     
%                     
%                     RGB_new{1} = [(-1+2)*0 + (1-1)*(1-.5*(iTrial_temp-1)/(numTrials-1)),(-1+2)*(1-(iTrial_temp-1)/(numTrials-1)) + (1-1)*0, ...
%                         (-1+2)*1 + (1-1)*1];
%                     RGB_new{2} = [(-2+2)*0 + (2-1)*(1-.5*(iTrial_temp-1)/(numTrials-1)),(-2+2)*(1-(iTrial_temp-1)/(numTrials-1)) + (2-1)*0, ...
%                         (-2+2)*1 + (2-1)*1];
%                     
%                     RGB_eBar{1} = [.8 1 1];
%                     RGB_eBar{2} = [1 .8 1];
%                     
%                 else
%                     
%                     rSize_new{1} = B_A(BA_group_Trials{iGroup}(1),2); % reward size determines plot color
%                     rSize_new{2} = B_A(BA_group_Trials{iGroup}(2),2);
%                     rSizes_new = [rSize_new{1} rSize_new{2}]; display(rSizes_new)
%                     
%                     rSize_new{1} = B_A(BA_group_Trials{iGroup}(1),2); % reward size determines plot color
%                     rSize_new{2} = B_A(BA_group_Trials{iGroup}(2),2);
%                     rSizes_new = [rSize_new{1} rSize_new{2}]; display(rSizes_new)
%                     
%                     RGB_new{1} = [(-((rSize_new{1}-1)/3+1)+2)*0 + (((rSize_new{1}-1)/3+1)-1)*((iTrial_temp-1)/(numTrials-1)), ...
%                         (-((rSize_new{1}-1)/3+1)+2)*(1-(iTrial_temp-1)/(numTrials-1)) + (((rSize_new{1}-1)/3+1)-1)*0, ...
%                         (-((rSize_new{1}-1)/3+1)+2)*1 + (((rSize_new{1}-1)/3+1)-1)*1];
%                     RGB_new{2} = [(-((rSize_new{2}-1)/3+1)+2)*0 + (((rSize_new{2}-1)/3+1)-1)*((iTrial_temp-1)/(numTrials-1)), ...
%                         (-((rSize_new{2}-1)/3+1)+2)*(1-(iTrial_temp-1)/(numTrials-1)) + (((rSize_new{2}-1)/3+1)-1)*0, ...
%                         (-((rSize_new{2}-1)/3+1)+2)*1 + (((rSize_new{2}-1)/3+1)-1)*1];
%                     
%                     RGB_eBar{1} = RGB_new{1}+((1-RGB_new{1})/2);
%                     RGB_eBar{2} = RGB_new{2}+((1-RGB_new{2})/2);
%                 end
%             case 3
%                 
%                 if sameSize{iGroup}==1
%                     
%                     RGB_new{1} = [0 1 1];
%                     RGB_new{2} = [1 .5 0];
%                     
%                     RGB_eBar{1} = [.8 .8 1];
%                     RGB_eBar{2} = [1 .8 .8];
%                     
%                 else
%                     
%                     rSize_new{1} = B_A(BA_group_Trials{iGroup}(1),2); % reward size determines plot color
%                     rSize_new{2} = B_A(BA_group_Trials{iGroup}(2),2);
%                     rSizes_new = [rSize_new{1} rSize_new{2}]; display(rSizes_new)
%                     
%                     rSize_new{1} = B_A(BA_group_Trials{iGroup}(1),2); % reward size determines plot color
%                     rSize_new{2} = B_A(BA_group_Trials{iGroup}(2),2);
%                     rSizes_new = [rSize_new{1} rSize_new{2}]; display(rSizes_new)
%                     
%                     RGB_new{1} = [(-((rSize_new{1}-1)/3+1)+2)*0 + (((rSize_new{1}-1)/3+1)-1)*((iTrial_temp-1)/(numTrials-1)), ...
%                         (-((rSize_new{1}-1)/3+1)+2)*(1-(iTrial_temp-1)/(numTrials-1)) + (((rSize_new{1}-1)/3+1)-1)*0, ...
%                         (-((rSize_new{1}-1)/3+1)+2)*1 + (((rSize_new{1}-1)/3+1)-1)*1];
%                     RGB_new{2} = [(-((rSize_new{2}-1)/3+1)+2)*0 + (((rSize_new{2}-1)/3+1)-1)*((iTrial_temp-1)/(numTrials-1)), ...
%                         (-((rSize_new{2}-1)/3+1)+2)*(1-(iTrial_temp-1)/(numTrials-1)) + (((rSize_new{2}-1)/3+1)-1)*0, ...
%                         (-((rSize_new{2}-1)/3+1)+2)*1 + (((rSize_new{2}-1)/3+1)-1)*1];
%                     
%                     RGB_eBar{1} = RGB_new{1}+((1-RGB_new{1})/2);
%                     RGB_eBar{2} = RGB_new{2}+((1-RGB_new{2})/2);
%                 end
%                 
%         end
%         
%         figure;
%         subplot(2,1,1)
%         errorbar(1:length(combined.mean_gcamp1{iGroup}(:)),combined.mean_gcamp1{iGroup}(:),combined.sem_gcamp1{iGroup}(:),'color',RGB_eBar{1}); hold on;
%         errorbar(1:length(combined.mean_gcamp2{iGroup}(:)),combined.mean_gcamp2{iGroup}(:),combined.sem_gcamp2{iGroup}(:),'color',RGB_eBar{2}); hold on;
%         plot(combined.mean_gcamp1{iGroup}(:),'color',RGB_new{1},'linewidth',2);
%         plot(combined.mean_gcamp2{iGroup}(:),'color',RGB_new{2},'linewidth',2);
%         plot(combined.rewvalve1{iGroup}(:)/5,'color',RGB_new{1},'linewidth',3);
%         plot(combined.rewvalve2{iGroup}(:)/4,'color',RGB_new{2},'linewidth',1);
%         y=zeros(length(combined.mean_gcamp1{iGroup}(:)),1);
%         plot(y,'k--');
%         
%         set(gca,'xtick',trial_xticks,'xticklabel',trial_xlabels);
%         
%         subplot(2,1,2)
%         plot(combined.mean_speed1{iGroup}(:),'color',RGB_new{1}); hold on;
%         plot(combined.mean_speed2{iGroup}(:),'color',RGB_new{2});
%         plot(combined.mean_licks1{iGroup}(:),'color',RGB_new{1});
%         plot(combined.mean_licks2{iGroup}(:),'color',RGB_new{2});
%         set(gca,'xtick',trial_xticks,'xticklabel',trial_xlabels);
%         
%     end
%     
% end
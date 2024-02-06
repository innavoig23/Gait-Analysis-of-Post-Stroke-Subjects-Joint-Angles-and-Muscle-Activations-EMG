%% SBJ05
%close all

gaitcyclevector_emg = 0:0.1:100;

% RF, VL, ST, BF
figure
sgtitle("SBJ05 - Muscles Activation Intervals - RF, VL, ST, BF", FontSize=35, fontweight='bold')
for m = 1:numMusc-1 % TA excluded
    % Data selection
    actMeanMA = 0.5*(numMusc-m)*Data.SBJ05.MeanMuscleActivation.(MuscleCode{m});
    actMeanMA(actMeanMA==0) = NaN;
    OnOffEventsMean = cat(1, Data.SBJ05.VariabilityParameters.MeanOnMuscles.(MuscleCode{m}), Data.SBJ05.VariabilityParameters.MeanOffMuscles.(MuscleCode{m}));
    OnOffEventsStd = cat(1, Data.SBJ05.VariabilityParameters.StdOnMuscles.(MuscleCode{m}), Data.SBJ05.VariabilityParameters.StdOffMuscles.(MuscleCode{m}));

    % Plot of Mean
    plot(gaitcyclevector_emg,actMeanMA, LineWidth=15, Color='k'), hold on
    % Plot of Standard Deviation bands
    for e = 1:length(OnOffEventsMean)
        stdArea = (OnOffEventsMean(e)-OnOffEventsStd(e):OnOffEventsMean(e)+OnOffEventsStd(e))/10;
        fill([stdArea, fliplr(stdArea)], [0.1*ones(1,length(stdArea))+0.5*(numMusc-m), fliplr(-0.1+0.5*(numMusc-m)+zeros(1,length(stdArea)))],'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold on
    end
    xlabel("% of Gait Cycle")
    legend("Activation Intervals", "Standard Deviation")
    xlim([gaitcyclevector_emg(1) gaitcyclevector_emg(end)])
    ylim([0 2.5])
    set(gca, 'ytick', 0.5:0.5:(numMusc-1)/2, 'yticklabel', flip(MuscleCode(1:end-1,1)), 'FontSize', 30);
    set(gca, 'XMinorGrid', 'on', 'MinorGridLineWidth', 0.8)
    set(gca,'fontsize', 20, fontweight='bold') 
end


% TA
TAMusAct = Data.SBJ05.MuscleActivationInt_allsessions.RTA;
actNumGC = 12;

figure
sgtitle("SBJ05 - Muscles Activation Intervals - TA", FontSize=35, fontweight='bold')
for gc = 1:actNumGC
    actCycle = mod(gc-1,4)+1;
    actSess = fix((gc-1)/4)+1;
    actTh = Data.SBJ05.EnvThreshold(actSess).RTA;
    actEnv = Data.SBJ05.CatResampledEnv(actSess).RTA(:,actCycle);
    subplot(3,4,gc)
    % Plot of the Resampled Envelope
    plot(gaitcyclevector_emg, actEnv, LineWidth=2), hold on
    % Plot of the Threshold
    yline(actTh, LineStyle='--', LineWidth=1.5), hold on
    % Plot of the Muscle Activation Intervals
    plot(gaitcyclevector_emg, max(actEnv)*TAMusAct(:,gc), LineWidth=2.5), hold off

    % Plot Settings
    if ismember(gc,[1 5 9])
        ylabel("Session "+num2str(actSess))
    end
    if ismember(gc,9:12)
        xlabel("% of Gait Cycle")
    end
    set(gca,'fontsize', 20, fontweight='bold')

    ylim([0 max(actEnv)])

end

clear m e gc actMeanMA OnOffEventsMean OnOffEventsStd stdArea TAMusAct
clear actNumGC actCycle actSess actTh actEnv

%% TVC13
%close all

% VL, ST
figure
sgtitle("TVC13 - Muscles Activation Intervals - VL, ST", FontSize=35, fontweight='bold')
for m = 2:3 % TA excluded
    % Data selection
    actMeanMA = 0.5*(4-m)*Data.TVC13.MeanMuscleActivation.(MuscleCode{m});
    actMeanMA(actMeanMA==0) = NaN;
    OnOffEventsMean = cat(1, Data.TVC13.VariabilityParameters.MeanOnMuscles.(MuscleCode{m}), Data.TVC13.VariabilityParameters.MeanOffMuscles.(MuscleCode{m}));
    OnOffEventsStd = cat(1, Data.TVC13.VariabilityParameters.StdOnMuscles.(MuscleCode{m}), Data.TVC13.VariabilityParameters.StdOffMuscles.(MuscleCode{m}));

    % Plot of Mean
    plot(gaitcyclevector_emg,actMeanMA, LineWidth=15, Color='k'), hold on
    % Plot of Standard Deviation bands
    for e = 1:length(OnOffEventsMean)
        stdArea = (OnOffEventsMean(e)-OnOffEventsStd(e):OnOffEventsMean(e)+OnOffEventsStd(e))/10;
        fill([stdArea, fliplr(stdArea)], [0.05*ones(1,length(stdArea))+0.5*(4-m), fliplr(-0.05+0.5*(4-m)+zeros(1,length(stdArea)))],'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold on
    end
    xlabel("% of Gait Cycle")
    legend("Activation Intervals", "Standard Deviation")
    xlim([gaitcyclevector_emg(1) gaitcyclevector_emg(end)])
    ylim([0.25 1.25])
    set(gca, 'ytick', 0.5:0.5:(3-1)/2, 'yticklabel', flip(MuscleCode(2:3,1)), 'FontSize', 30);
    set(gca, 'XMinorGrid', 'on', 'MinorGridLineWidth', 0.8)
    set(gca,'fontsize', 20, fontweight='bold') 
end

% RF, BF, TA
for m = [1 4 5]
MusAct = Data.TVC13.MuscleActivationInt_allsessions.(MuscleCode{m});
actNumGC = 11;
        
figure
sgtitle("TVC13 - Muscles Activation Intervals - "+MuscleCode{m}, FontSize=35, fontweight='bold')      
numCycle = [1:2 1:4 1:5];
numSessp = [ones(1,2) 2*ones(1,4) 3*ones(1,5)];
numSubplot = [1:3:4, 2:3:11, 3:3:15];
for gc = 1:actNumGC
    actCycle = numCycle(gc);
    actSess = numSessp(gc);
    actTh = Data.TVC13.EnvThreshold(actSess).(MuscleCode{m});
    actEnv = Data.TVC13.CatResampledEnv(actSess).(MuscleCode{m})(:,actCycle);
    subplot(5,3,numSubplot(gc))
    % Plot of the Resampled Envelope
    plot(gaitcyclevector_emg, actEnv, LineWidth=2), hold on
    % Plot of the Threshold
    yline(actTh, LineStyle='--', LineWidth=1.5), hold on
    % Plot of the Muscle Activation Intervals
    plot(gaitcyclevector_emg, max(actEnv)*MusAct(:,gc), LineWidth=2.5), hold off

    % Plot Settings
    if ismember(numSubplot(gc),[1 2 3])
        title("Session "+num2str(actSess))
    end
    if ismember(numSubplot(gc),[4 11 15])
        xlabel("% of Gait Cycle")
    end
    set(gca,'fontsize', 20, fontweight='bold')

    ylim([0 max(actEnv)])

end

end

clear m e gc actMeanMA OnOffEventsMean OnOffEventsStd stdArea numSessp
clear actNumGC actCycle actSess actTh actEnv numCycle numSubplot MusAct

%% TVC03
%close all

gaitcyclevector_emg = 0:0.1:100;

for m = 1:numMusc
MusAct = Data.TVC03.MuscleActivationInt_allsessions.(MuscleCode{m});
if m==1
    actNumGC = 6;
else
    actNumGC = 8;
end
        
figure
sgtitle("TVC03 - Muscles Activation Intervals - "+MuscleCode{m}, FontSize=35, fontweight='bold')      
numCycle = [1:2 1:2 1:4];
if m==1
    numSessp = [ones(1,2) 3*ones(1,4)];
    numSubplot = [1:2, 5:8];
else
    numSessp = [ones(1,2) 2*ones(1,2) 3*ones(1,4)];
    numSubplot = [1:2, 3:4, 5:8];
end

for gc = 1:actNumGC
    % Data selection
    actCycle = numCycle(gc);
    actSess = numSessp(gc);
    actTh = Data.TVC03.EnvThreshold(actSess).(MuscleCode{m});
    actEnv = Data.TVC03.CatResampledEnv(actSess).(MuscleCode{m})(:,actCycle);
    subplot(2,4,numSubplot(gc))
    % Plot of the Resampled Envelope
    plot(gaitcyclevector_emg, actEnv, LineWidth=2), hold on
    % Plot of the Threshold
    yline(actTh, LineStyle='--', LineWidth=1.5), hold on
    % Plot of the Muscle Activation Intervals
    plot(gaitcyclevector_emg, max(actEnv)*MusAct(:,gc), LineWidth=2.5), hold off

    % Plot Settings
    title("Session "+num2str(actSess))
    % if ismember(numSubplot(gc),1:4)
    %     title("Session "+num2str(actSess))
    % end
    % if ismember(numSubplot(gc),1:5)
    %     ylabel("Session "+num2str(actSess))
    % end
    if ismember(numSubplot(gc),5:8)
        xlabel("% of Gait Cycle")
    end
    set(gca,'fontsize', 20, fontweight='bold')

    ylim([0 max(actEnv)])


end

end
 
clear m MusAct numSessp numSubplot gc actNumGC actCycle actSess actTh
clear actEnv gaitcyclevector_emg numCycle
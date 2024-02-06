%% Manual Selection of the Threshold to apply on the Envelope
% Change sub and sess to analyze the wanted signals.

close all

ColorMeanNE = {"#0072BD"; "#D95319"; "#77AC30"; "#4DBEEE"; 	"#7E2F8E"};
ColorStdBarNE = {"b"; "r"; "g"; "c"; "m"};

sub = 2;
sess = 3;

actNoiseSamplesVect = {1121:1338;
1086:1683;
4195:4420;
2612:2998;
2198:2426};

Nvect = [4 4 4 3.5 3];


for m=1:5

try % used because RF of sub=2 and sess=2 is empty
actNoiseSamples = actNoiseSamplesVect{m,1};
N = Nvect(m);

% Data selection
actEnv = Data.(SubjectID{sub}).EnvelopeRLP(sess).(MuscleCode{m});
actEMG = Data.(SubjectID{sub}).sd_sig(sess).(MuscleCode{m});
actRHEEMin = cell2mat(Data.(SubjectID{sub}).HeelStrikesSamplesR_man(sess));
actEnvResampled = Data.(SubjectID{sub}).CatResampledEnv(sess).(MuscleCode{m});
gaitcyclevector_emg = 0:0.1:100;
actNumGC = size(actEnvResampled,2);

% Noise interval visual selection and visualization
figure, plot(actEMG), hold on, xline(actRHEEMin*10)
actNoiseSamples = 2198:2426; % to make change manual
%actNoiseSamples = Data.(SubjectID{sub}).NoiseIntervals.(MuscleCode{m}){:,sess}; % to get the ones saved
hold on, plot(actNoiseSamples, actEMG(actNoiseSamples))
xlabel("Sample"), ylabel("Signal (V)")
xlim([1 length(actEMG)])
title(MuscleCode{m}), legend("Filtered EMG", "Noise Intervals")
% Noise Envelope Computation
noiseEnv = actEnv(actNoiseSamples);
mu = mean(noiseEnv); sigma = std(noiseEnv);
% Parameters set
actEnvThresh = mu + N*sigma;

actMuscleActivations = actEnvResampled > actEnvThresh;

% Plot of overlayed envelopes
% figure
% for gc = 1:actNumGC
%     plot(gaitcyclevector_emg, actEnvResampled(:,gc), LineWidth=2); hold on
%     xlabel("% of Gait Cycle"), ylabel("Signals"), title(MuscleCode{m})
% end

% Plot of the Envelope
figure
for gc = 1:actNumGC
    subplot(actNumGC,1,gc)
    % Plot of the Resampled Envelope
    plot(gaitcyclevector_emg, actEnvResampled(:,gc), LineWidth=2, Color=ColorMeanNE{m}); hold on
    xlabel("% of Gait Cycle"), ylabel("Signals"), title(MuscleCode{m})
    % Plot of the Threshold
    yline(actEnvThresh, '--k', LineWidth=1.5), hold on
    % Plot of the Muscle Activation Intervals
    plot(gaitcyclevector_emg, max(actEnvResampled(:,gc))*actMuscleActivations(:,gc), LineWidth=1.8, Color="#77AC30"), hold off

    % xlim([gaitcyclevector_kin(1) gaitcyclevector_kin(end)])
end
% legend("Resampled and Concatenated Envelope", "Threshold", "Muscle Activation Intervals", "RHEE Min") 


% clear ColorMeanNE ColorStdBarNE sgTitlePlot hNE ubound lbound actMeanNE actStdNE


% figure
% plot(gaitcyclevector_emg,mean(actEnvResampled,2)), hold on
% muscact = mean(actEnvResampled,2) > actEnvThresh;
% plot(gaitcyclevector_emg,max(mean(actEnvResampled,2),[],1)*muscact), hold on
% yline(actEnvThresh, '--k', LineWidth=1.5), hold off



end

end

clear actEMG actEnv actEnvResampled actEnvThresh actMuscleActivations actNoiseSamples  Nvect sub sess ColorStdBarNE ColorMeanNE 
clear m mu N noiseEnv sigma actNumGC actRHEEMin gc actNoiseSamplesVect

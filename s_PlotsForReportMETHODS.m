%% RHEE Min Plot
%close all

% Plot of the RHEE marker z position with heel strikes indications
for sub = [1 3]
    for sess = 2:3
        if sub == 1 && sess == 2
            continue
        elseif sub == 3 && sess == 3
            continue
        end
        % Data selection
        actRHEE = Data.(SubjectID{sub}).traj(sess,1).RHEE;
        actLastFrame = size(Data.(SubjectID{sub}).traj(sess,1).RHEE, 1);
        timevector_kin = linspace(0,(actLastFrame-1)/kin_fsamp,actLastFrame); % time vector
        actMinAuto = Data.(SubjectID{sub}).HeelStrikesSamplesR_auto{sess,1};
        actMinMan = Data.(SubjectID{sub}).HeelStrikesSamplesR_man{sess,1};

        % Plot of the RHEE marker ...
        figure
        plot(timevector_kin, actRHEE(:,3), LineWidth=2.5), hold on
        if sub == 3
        % ... with the manual heel strike indications ...
        scatter((actMinMan-1)/kin_fsamp, actRHEE(actMinMan,3), 100, 'filled', 'o'), hold on
        end
        % ... and with the automatic heel strike indications
        scatter((actMinAuto-1)/kin_fsamp, actRHEE(actMinAuto,3), 50, 'filled', 'o'), hold off
        % Plot settings
        sgTitleTotal = sprintf(SubjectID{sub} + " - " + sgTitlePlot_sess{sess} + "\nPosition of RHEE marker along the vertical direction (z) with Heel Strikes indications");
        title(sgTitleTotal, FontSize=60, fontweight='bold')
        xlabel("Time (s)"), ylabel("Z (mm)")
        if sub == 3
            legend("RHEE trajectory (z)", "Manual Heel Strike", "Automatic Heel Strike")
        else
            legend("RHEE trajectory (z)", "Automatic Heel Strike")
        end

        set(gca, FontSize=20, fontweight='bold')

    end
end

clear actMinMan actMinAuto actRHEE actLastFrame timevector_kin sgTitleTotal LocMinRHEE MinPeakHeightStored MinPeakDistanceStored HeelStrikesSamplesR_man sub sess

%% Raw-Filtered EMG Signal - RRF of TVC13 (Session 3)
%close all

sub = 3; sess = 3;

% Data selection
SignalPath = sprintf("signals"+filesep+filesep+"%s"+filesep+filesep+"%s_%d.mat", SubjectID{sub}, SubjectID{sub}, sess);
load(SignalPath,"sd_sig");
sig = sd_sig.RRF;
sigFilt = Data.(SubjectID{sub}).sd_sig(sess,1).RRF;

% Periodogram Computation
NFFT = length(sig); w = rectwin(length(sig)); overlap = 0;
[Pr,fr]=pwelch(sig-mean(sig),w,overlap,NFFT,emg_fsamp);
[Pf,ff]=pwelch(sigFilt-mean(sigFilt),w,overlap,NFFT,emg_fsamp);

% 1st type
figure
sgtitle("TVC13 - Session 3 - Raw and Filtered sEMG signal of RRF Muscle", FontSize=30, fontweight='bold')
% Signal Plot
subplot(2,1,1)
plot(0:1/emg_fsamp:(length(sig)-1)/emg_fsamp, sig)
axis([0 (length(sig)-1)/emg_fsamp min(sig) max(sig)])
xlabel("Time (s)"), ylabel("Signal (V)"), title("Raw Signal")
set(gca, FontSize=20, fontweight='bold')

subplot(2,1,2)
plot(0:1/emg_fsamp:(length(sigFilt)-1)/emg_fsamp, sigFilt)
axis([0 (length(sigFilt)-1)/emg_fsamp min(sigFilt) max(sigFilt)])
xlabel("Time (s)"), ylabel("Signal (V)"), title("Filtered Signal")
set(gca, FontSize=20, fontweight='bold')

% Periodogram Plot
figure
sgtitle("TVC13 - Session 3 - Raw and Filtered Periodogram of RRF Muscle Signal", FontSize=30, fontweight='bold')
subplot(2,1,1)
plot(fr,Pr)
axis([0 ff(end) min(Pr) max(Pr)])
xlabel("Frequency (Hz)"), ylabel("Periodogram (V^2/Hz)"), title("Periodogram of the Raw Signal")
set(gca, FontSize=20, fontweight='bold')

subplot(2,1,2)
plot(ff,Pf)
axis([0 ff(end) min(Pf) max(Pf)])
xlabel("Frequency (Hz)"), ylabel("Periodogram (V^2/Hz)"), title("Periodogram of the Filtered Signal")
set(gca, FontSize=20, fontweight='bold')

clear sub sess SignalPath sig sigFilt NFFT w overlap  Pr fr Pf ff sd_sig
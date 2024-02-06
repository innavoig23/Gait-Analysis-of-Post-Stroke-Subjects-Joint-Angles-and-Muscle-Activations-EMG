%% Header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bioingegneria della Riabilitazione - Tesina valida per l'esame
% A.A. 2023-2024
% 
% Title: Analisi del Cammino di Soggetti Post-Stroke
%
% Authors: - Lolli Alice
%          - Reviglio Luca
%          - Toska Robjona
%          - Traetta Giovanni
%
% Version of MATLAB used: 2023b
% MATLAB Toolbox needed: - Signal Processing Toolbox
%                        - One between: Navigation Toolbox, Robotics System
%                                       Toolbox, UAV Toolbox (for rotm2eul)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%% Kinematics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clearing, defining variables and loading data
clear all, close all, clc

disp("Start: Kinematics")
fprintf("\n")


% Global varial definition to reduce functions' parameters
global Data MuscleCode mDiameter MarkerCode seg_for_angle JC_len joint_centers joints

% Data loading and inizialization of some elements needed for the script
mDiameter = 10; % diameter of the markers (10 mm)
SubjectID = {"SBJ05"; "TVC03"; "TVC13"}; % needed to load data and to create Data struct fields (healthy, post-stroke 1 and post-stroke 2)
numSub = length(SubjectID);
for sub = 1:numSub
    Data.(SubjectID{sub}) = struct([]); % Data struct inizialization
end
numSess = 3;
kin_fsamp = 100;  % sample frequency of markers position (frame/s)
emg_fsamp = 1000; % sample frequency of EMG signals (sample/s)
segments = {'pelvis'; 'femurL'; 'femurR'; 'shankL'; 'shankR'; 'footL'; 'footR'}; % analyzed lower-limb segments
joints = {'Hip'; 'Knee'; 'Ankle'}; % joints of which to find coordinates of the rotation center (through chordPiG() function)
joint_centers = {'LHJC'; 'RHJC'; 'LKJC'; 'RKJC'; 'LAJC'; 'RAJC'}; % computated joint centers
coords = {'x'; 'y'; 'z'};

for sub = 1:numSub
    % Antropometric measurements loading
    AntroPath = sprintf("signals"+filesep+filesep+"%s"+filesep+filesep+"Antro_%s.mat", SubjectID{sub}, lower(SubjectID{sub}));
    Data.(SubjectID{sub}) = load(AntroPath,"Antro");

    % Signals loading (3 sessions)
    for sess = 1:numSess
   
        SignalPath = sprintf("signals"+filesep+filesep+"%s"+filesep+filesep+"%s_%d.mat", SubjectID{sub}, SubjectID{sub}, sess);
        
        % sd_sig
        load(SignalPath,"sd_sig"); sd_sigNames = fieldnames(sd_sig);
        for fn = 1:length(sd_sigNames)
            Data.(SubjectID{sub}).sd_sig(sess,1).(sd_sigNames{fn}) = sd_sig.(sd_sigNames{fn});
        end

        % traj
        load(SignalPath,"traj"); trajNames = fieldnames(traj);
        for fn = 1:length(trajNames)
            Data.(SubjectID{sub}).traj(sess,1).(trajNames{fn}) = traj.(trajNames{fn});
        end
    end
end

% Muscle and Marker codes cells
MuscleCode = fieldnames(Data.SBJ05.sd_sig(1,1)); % {"RRF"; "RVL"; "RST"; "RBF"; "RTA"};
numMusc = length(MuscleCode);
for sub = 1:numSub
    MarkerCode{sub,1} = fieldnames(Data.(SubjectID{sub}).traj(1,:));
end

% Defining other elements needed in the scripts
sgTitlePlot_sub = {"Healthy Subject (SBJ05) - ";
                   "Post-Stroke Subject (TVC03) - ";
                   "Post-Stroke Subject (TVC13) - "};
sgTitlePlot_sess = {"Session 1";
                    "Session 2";
                    "Session 3";
                    "Averaged Sessions"}; % averaged sessions needed in some plots

% Elements needed for the plot
AnglesSymb = {'\alpha', '\beta', '\gamma'}; % respectively around x, z and y axis (stored properly in AxisSymb)
AnglesName = {'Flexion-Extension', 'Abduction-Adduction', 'Internal-External Rotation'; ... % Hip
              'Flexion-Extension', 'Abduction-Adduction', 'Internal-External Rotation'; ... % Knee
              'Plantar-Dorsal Flexion', 'Inversion-Eversion', 'Abduction-Adduction'};       % Ankle
AnglesColors = ["#D95319"; "#0072BD"; "#77AC30"]; % default red, blue and green of matlab to plot angles

AxisSymb = {'x'; 'y'; 'z'};
AxisName = {'posterior-anterior', 'medial-lateral', 'inferior-superior'; ... Hip L
            'posterior-anterior', 'lateral-medial', 'inferior-superior'; ... Hip R
            'posterior-anterior', 'medial-lateral', 'inferior-superior'; ... Knee L
            'posterior-anterior', 'lateral-medial', 'inferior-superior'; ... Knee R
            'posterior-anterior', 'medial-lateral', 'longitudinal'; ...      Ankle L
            'posterior-anterior', 'lateral-medial', 'longitudinal'};  %      Ankle R
            % maybe needed in plots

clear AntroPath SignalPath sd_sig traj sd_sigNames trajNames sub sess fn

disp("0: Data loading --> DONE")
fprintf("\n")

%% Gait Cycles Identification - Right Leg
% MinPeakHeight and MinPeakDistance parameters to use in "findpeaks"
% were chosen observing each plot individually for every subject and
% every session and then stored in these two 3x3 matrixes (row=subject;
% column=session). Finally, parameters were equal across the sessions.

MinPeakHeightStored = [-43; -50; -50];
MinPeakDistanceStored = [80; 120; 110];

% Automatic computation
for sub = 1:numSub
    for sess = 1:numSess
        % Data selection
        actRHEE = Data.(SubjectID{sub}).traj(sess,1).RHEE;
        
        % Heel Strike finding and storing
        [~, LocMinRHEE] = findpeaks(-actRHEE(:,3), MinPeakHeight=MinPeakHeightStored(sub), MinPeakDistance=MinPeakDistanceStored(sub));
        Data.(SubjectID{sub}).HeelStrikesSamplesR_auto{sess,1} = LocMinRHEE;

    end
end

% At the end, RHEE Minimums samples were chosen manually for the
% Post-Stroke Subjects (why is explained in the report).

% Manually selected RHEE Minimums for the Post-Stroke Subjects
% HeelStrikesSamplesR_man{1,:} is equal to the one found automatically --> copied above
HeelStrikesSamplesR_man{2,1} = [38 219 394]'; HeelStrikesSamplesR_man{2,2} = [192 376 553]'; HeelStrikesSamplesR_man{2,3} = [7 188 363 563 758]';
HeelStrikesSamplesR_man{3,1} = [98 252 444]'; HeelStrikesSamplesR_man{3,2} = [63 222 389 548 716]'; HeelStrikesSamplesR_man{3,3} = [44 225 387 546 719 879]';

% Storing data
for sess = 1:numSess
    Data.(SubjectID{1}).HeelStrikesSamplesR_man{sess,1} = Data.(SubjectID{1}).HeelStrikesSamplesR_auto{sess,1};
    Data.(SubjectID{2}).HeelStrikesSamplesR_man{sess,1} = HeelStrikesSamplesR_man{2,sess};
    Data.(SubjectID{3}).HeelStrikesSamplesR_man{sess,1} = HeelStrikesSamplesR_man{3,sess};
end

% Plot of the RHEE marker z position with heel strikes indications
for sub = 1:numSub
    for sess = 1:numSess
        % Data selection
        actRHEE = Data.(SubjectID{sub}).traj(sess,1).RHEE;
        actLastFrame = size(Data.(SubjectID{sub}).traj(sess,1).RHEE, 1);
        timevector_kin = linspace(0,(actLastFrame-1)/kin_fsamp,actLastFrame); % time vector
        actMinAuto = Data.(SubjectID{sub}).HeelStrikesSamplesR_auto{sess,1};
        actMinMan = Data.(SubjectID{sub}).HeelStrikesSamplesR_man{sess,1};

        % Plot of the RHEE marker ...
        figure
        plot(timevector_kin, actRHEE(:,3), LineWidth=2), hold on
        % ... with the manual heel strike indications ...
        scatter((actMinMan-1)/kin_fsamp, actRHEE(actMinMan,3), 100, 'filled', 'o'), hold on 
        % ... and with the automatic heel strike indications
        scatter((actMinAuto-1)/kin_fsamp, actRHEE(actMinAuto,3), 50, 'filled', 'o'), hold off
        % Plot settings
        sgTitleTotal = sprintf(sgTitlePlot_sub{sub} + sgTitlePlot_sess{sess} + "\nPosition of RHEE marker along the vertical direction with Heel Strikes indications");
        title(sgTitleTotal)
        xlabel("Time (s)"), ylabel("Z (mm)")
        legend("RHEE z trajectory", "Manual Heel Strike", "Automatic Heel Strike")

    end
end

clear actMinMan actMinAuto actRHEE actLastFrame timevector_kin sgTitleTotal LocMinRHEE MinPeakHeightStored MinPeakDistanceStored HeelStrikesSamplesR_man sub sess

%% Gait Cycles Identification - Left Leg
close all

% MinPeakHeight and MinPeakDistance parameters to use in "findpeaks"
% were chosen observing each plot individually for every subject and
% every session and then stored in these two 3x3 matrixes (row=subject;
% column=session). Finally, parameters were equal across the sessions.

MinPeakHeightStored = [-50; -50; -50];
MinPeakDistanceStored = [80; 120; 110];

% Automatic computation
for sub = 1:numSub
    for sess = 1:numSess
        % Data selection
        actLHEE = Data.(SubjectID{sub}).traj(sess,1).LHEE;
        
        % Heel Strike finding and storing
        [~, LocMinLHEE] = findpeaks(-actLHEE(:,3), MinPeakHeight=MinPeakHeightStored(sub), MinPeakDistance=MinPeakDistanceStored(sub));
        Data.(SubjectID{sub}).HeelStrikesSamplesL_auto{sess,1} = LocMinLHEE;
    end
end

% At the end, LHEE Minimums samples were chosen manually for the
% Post-Stroke Subjects (why is explained in the report).

% Manually selected LHEE Minimums for the Post-Stroke Subjects
% HeelStrikesSamples_man{1,:} is equal to the one found automatically --> copied above
HeelStrikesSamplesL_man{2,1} = [93 280 449 619]'; HeelStrikesSamplesL_man{2,2} = [46 253 442 617]'; HeelStrikesSamplesL_man{2,3} = [63 250 438 639]';
HeelStrikesSamplesL_man{3,1} = [18 169 360]'; HeelStrikesSamplesL_man{3,2} = [139 300 467 632]'; HeelStrikesSamplesL_man{3,3} = [140 303 464 634 788]';

% Storing data
for sess = 1:numSess
    Data.(SubjectID{1}).HeelStrikesSamplesL_man{sess,1} = Data.(SubjectID{1}).HeelStrikesSamplesL_auto{sess,1};
    Data.(SubjectID{2}).HeelStrikesSamplesL_man{sess,1} = HeelStrikesSamplesL_man{2,sess};
    Data.(SubjectID{3}).HeelStrikesSamplesL_man{sess,1} = HeelStrikesSamplesL_man{3,sess};
end

clear sub sess MinPeakHeightStored MinPeakDistanceStored actLHEE LocMinLHEE HeelStrikesSamplesL_man

disp("1: Gait Cycles Identification --> DONE")
fprintf("\n")

%% Stride Parameters Computation
% Stride Duration: s
% Stride Length: m
% Gait Velocity: m/s (for each gait cycle and as an average value for each session)

for sub = 1:numSub
    for sess = 1:numSess
        % Data selection
        % Right leg
        actRHEE = Data.(SubjectID{sub}).traj(sess,1).RHEE;
        actLocMinRHEE = Data.(SubjectID{sub}).HeelStrikesSamplesR_man{sess,1};
        diffLocMinRHEE = diff(actLocMinRHEE);
        % Left leg
        actLHEE = Data.(SubjectID{sub}).traj(sess,1).LHEE;
        actLocMinLHEE = Data.(SubjectID{sub}).HeelStrikesSamplesL_man{sess,1};
        diffLocMinLHEE = diff(actLocMinLHEE); 

        % Computation
        % Right leg
        Data.(SubjectID{sub}).GaitParameters.StrideDurationR{sess,1} = diffLocMinRHEE/kin_fsamp;
        Data.(SubjectID{sub}).GaitParameters.StrideLenghtR{sess,1} = abs(diff(actRHEE(actLocMinRHEE,1)))/1000; % /1000 to transform  mm in m
        Data.(SubjectID{sub}).GaitParameters.GaitVelocityR{sess,1} = Data.(SubjectID{sub}).GaitParameters.StrideLenghtR{sess,1}./Data.(SubjectID{sub}).GaitParameters.StrideDurationR{sess,1};
        Data.(SubjectID{sub}).GaitParameters.GaitVelocityAveragedR(sess,1) = mean(Data.(SubjectID{sub}).GaitParameters.GaitVelocityR{sess,1});
        % Left leg
        Data.(SubjectID{sub}).GaitParameters.StrideDurationL{sess,1} = diffLocMinLHEE/kin_fsamp;
        Data.(SubjectID{sub}).GaitParameters.StrideLenghtL{sess,1} = abs(diff(actLHEE(actLocMinLHEE,1)))/1000; % /1000 to transform  mm in m
        Data.(SubjectID{sub}).GaitParameters.GaitVelocityL{sess,1} = Data.(SubjectID{sub}).GaitParameters.StrideLenghtL{sess,1}./Data.(SubjectID{sub}).GaitParameters.StrideDurationL{sess,1};
        Data.(SubjectID{sub}).GaitParameters.GaitVelocityAveragedL(sess,1) = mean(Data.(SubjectID{sub}).GaitParameters.GaitVelocityL{sess,1});

    end
end

clear sub sess actRHEE actLocMinRHEE diffLocMinRHEE actLHEE actLocMinLHEE diffLocMinLHEE

disp("2: Stride Parameters Computation --> DONE")
fprintf("\n")

%% Reference System computation
for sub = 1:numSub
    for sess = 1:numSess
        % Computation
        actTraj = Data.(SubjectID{sub}).traj(sess,1); % selecting data needed to compute
        actAntro = Data.(SubjectID{sub}).Antro; % selecting data needed to compute
        [loc_ref, JC] = calc_references(actTraj, actAntro); % calling function that compute r.s.

        % Storing the result in Data struct
        loc_refNames = fieldnames(loc_ref);
        for fn = 1:length(loc_refNames)
            Data.(SubjectID{sub}).loc_ref(sess,1).(loc_refNames{fn}) = loc_ref.(loc_refNames{fn});
        end

        JCNames = fieldnames(JC);
        for fn = 1:length(JCNames)
            Data.(SubjectID{sub}).JC(sess,1).(JCNames{fn}) = JC.(JCNames{fn});
        end

    end
end

clear actAntro actTraj fn JC JCNames loc_ref loc_refNames sess sub

disp("3: Reference System Computation --> DONE")
fprintf("\n")

%% Joints Angles Estimation 
% Angles are intended as the rotation of the proximal segment over the
% distal segment.

% Elements needed for the computation
seg_for_angle = {'pelvis'; 'pelvis'; 'femurL'; 'femurR'; 'shankL'; 'shankR'; 'footL'; 'footR'};
% pelvis is repeated two times because it's the proximal segment both for L
% and R Hip angle estimation
JC_len = length(joint_centers); % number of joint centers of which to estimate the angle

% Computation
for sub = 1:numSub
    for sess = 1:numSess
        % Computation
        actLoc_ref = Data.(SubjectID{sub}).loc_ref(sess,1);
        joint_angles = joint_angles_estimation(actLoc_ref);
        
        % Storing the result in Data struct
        joint_anglesNames = fieldnames(joint_angles);
        for fn = 1:length(joint_anglesNames)
            Data.(SubjectID{sub}).joint_angles(sess,1).(joint_anglesNames{fn}) = joint_angles.(joint_anglesNames{fn});
        end
    end
end

clear sub sess actLoc_ref fn JC_len joint_anglesNames joint_angles

disp("4: 4.1: Joints Angles Estimation --> DONE")



%% Joints Angles Average Trend and Variability Evaluation (over all the gait cycles)
% Divided by session
for sub = 1:numSub
    for sess = 1:numSess
        actHeelStrikes = Data.(SubjectID{sub}).HeelStrikesSamplesR_man{sess,1};
        % actHeelStrikes = Data.(SubjectID{sub}).HeelStrikesSamplesR_auto{sess,1};
        
        for jc = 1:length(joint_centers)
            jointName = joint_centers{jc} + "_angles";
            jointAngles = Data.(SubjectID{sub}).joint_angles(sess).(jointName);

            JAcat = [];

            % To avoid edge effects, a flip of the angle signals before and
            % after was performed before resampling and removed after
            % resampling.
            for gc = 1:length(actHeelStrikes)-1
                actGaitCycle = jointAngles(actHeelStrikes(gc):actHeelStrikes(gc+1)-1, :); % selecting data
                actGaitCycle = cat(1,flipud(actGaitCycle), actGaitCycle, flipud(actGaitCycle)); % adding flipped angle signals
                actGaitCycle = resample(actGaitCycle,101*3,size(actGaitCycle,1)); % resampling
                actGaitCycle = actGaitCycle(101+1:101*2,:); % keeping the centered angle signal (the right one)
                JAcat = cat(3, JAcat, actGaitCycle);
            end

            % Storing JA data
            Data.(SubjectID{sub}).AllJA(sess).(jointName) = JAcat;
            Data.(SubjectID{sub}).MeanJA(sess).(jointName) = mean(JAcat,3);
            Data.(SubjectID{sub}).StdJA(sess).(jointName) = std(JAcat,0,3);
            Data.(SubjectID{sub}).MinJA(sess).(jointName) = min(JAcat,[],3);
            Data.(SubjectID{sub}).MaxJA(sess).(jointName) = max(JAcat,[],3);

        end
    end

    % Averaged Sessions (stored in row=4)
    for jc = 1:length(joint_centers)
        JAcat_meansess = [];
        jointName = joint_centers{jc} + "_angles";
        for sess = 1:numSess
            JAcat_meansess = cat(3, JAcat_meansess, Data.(SubjectID{sub}).MeanJA(sess).(jointName));
        end
        Data.(SubjectID{sub}).MeanJA(numSess+1).(jointName) = mean(JAcat_meansess,3);
        Data.(SubjectID{sub}).StdJA(numSess+1).(jointName) = std(JAcat_meansess,0,3);
        Data.(SubjectID{sub}).MinJA(numSess+1).(jointName) = min(JAcat_meansess,[],3);
        Data.(SubjectID{sub}).MaxJA(numSess+1).(jointName) = max(JAcat_meansess,[],3);

    end
end

% Merged sessions (all gait cycles in a single variable to plot them
% overlayed)
for sub = 1:numSub
    for jc = 1:length(joint_centers)
        % Computation
        jointName = joint_centers{jc} + "_angles";
        mergedJointAngles = [];
        for sess = 1:numSess
            mergedJointAngles = cat(3, mergedJointAngles, Data.(SubjectID{sub}).AllJA(sess).(jointName));
        end
        % Storing data (all gait cycles in a single variable)
        Data.(SubjectID{sub}).AllJA_allsessions.(jointName) = mergedJointAngles;
        Data.(SubjectID{sub}).MeanAllJA_allsessions.(jointName) = mean(mergedJointAngles,3);
        Data.(SubjectID{sub}).StdAllJA_allsessions.(jointName) = std(mergedJointAngles,0,3);
        Data.(SubjectID{sub}).MinAllJA_allsessions.(jointName) = min(mergedJointAngles,[],3);
        Data.(SubjectID{sub}).MaxAllJA_allsessions.(jointName) = max(mergedJointAngles,[],3);

    end
end

clear actGaitCycleResampled sub sess actHeelStrikes jc jointName mergedJointAngles JAcat gc actGaitCycle JAcat_meansess ang jointAngles

disp("   4.2: Joints Angles Average Trend and Variability Evaluation  --> DONE")

%% Joints Angles Overlaying Plot (All Gait Cycles Overlayed) 

gaitcyclevector_kin = 0:100;

for sub = 1:numSub % loop over subjetcs
    for sess = 1:numSess % loop over sessions
        actAllJA = Data.(SubjectID{sub}).AllJA(sess); % data selection

        for i=1:2:length(fieldnames(actAllJA)) % loop over joint centers (Hip, Knee and Akle) angles
            figure
            sgTitleTotal = sprintf(sgTitlePlot_sub{sub} + sgTitlePlot_sess{sess} + "\n" + joints{(i+1)/2} + " Joint Angles - L and R");
            sgtitle(sgTitleTotal)
            for j=1:length(AnglesSymb) % loop over the three angles
                % LEFT
                % Plot of AllJA (angles over each gait cycles superimposed)
                subplot(3,2,2*j-1)
                for k=1:size(actAllJA.(joint_centers{(i)}+"_angles"), 3) % loop over the gait cycles
                    plot(gaitcyclevector_kin, actAllJA.(joint_centers{(i)}+"_angles")(:,j,k), LineWidth=1), hold on
                end
                hold off
                title(string(AnglesName{(i+1)/2,j}))
                xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")
                % for legGC = 1:N, actLegGC{legGC}=num2str(legGC); end
                % legend(actLegGC)

                % RIGHT
                % Plot of AllJA (angles over each gait cycles superimposed)
                subplot(3,2,2*j)
                for k=1:size(actAllJA.(joint_centers{(i+1)}+"_angles"), 3) % loop over the gait cycles
                    plot(gaitcyclevector_kin, actAllJA.(joint_centers{(i+1)}+"_angles")(:,j,k), LineWidth=1), hold on
                end
                hold off
                title(string(AnglesName{(i+1)/2,j}))
                xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")                
                
            end
        end
    end
end

clear sub sess actAllJA i j k sgTitleTotal uboundL lboundL uboundR lboundR StdAnglesColor

disp("   4.3: Joints Angles Overlaying Plot (All Gait Cycles Overlayed)   --> DONE")

%% Joints Angles Overlaying Plot (All Gait Cycles of each Session Overlayed) 
close all

% blue, red and green to plot angles of each session with the same color
SessionColor = [0.4940 0.1840 0.5560; 0.8500 0.3250 0.0980; 0.4660 0.6740 0.1880];

for sub = 1:numSub % loop over subjetcs
    actAllJA = Data.(SubjectID{sub}).AllJA_allsessions;
    actGCperSession = [1;
                       1 + size(Data.(SubjectID{sub}).AllJA(1).LHJC_angles,3);
                       1 + size(Data.(SubjectID{sub}).AllJA(1).LHJC_angles,3) + size(Data.(SubjectID{sub}).AllJA(2).LHJC_angles,3)];
                      % indices of the starting gait cycles for each session (needed for the color setting)
    
    for i=1:2:length(fieldnames(actAllJA)) % loop over joint centers (Hip, Knee and Akle) angles
        figure
        sgTitleTotal = sprintf(sgTitlePlot_sub{sub} + joints{(i+1)/2} + " Joint Angles - L and R");
        sgtitle(sgTitleTotal)
        for j=1:length(AnglesSymb) % loop over the three angles
            % LEFT
            % Plot of AllJA (angles over each gait cycles superimposed)
            subplot(3,2,2*j-1)
            for k=1:size(actAllJA.(joint_centers{(i)}+"_angles"), 3) % loop over the gait cycles
                actPlot = plot(gaitcyclevector_kin, actAllJA.(joint_centers{(i)}+"_angles")(:,j,k), LineWidth=1); hold on
                % Setting the same color for the angles of the same session
                if k<actGCperSession(2)             % set color of first session
                    actPlot.Color=SessionColor(1,:);
                elseif k>=actGCperSession(3)        % set color of third session
                    actPlot.Color=SessionColor(3,:);
                else                                % set color of second session
                    actPlot.Color=SessionColor(2,:);
                end
            end            
            hold off
            title(string(AnglesName{(i+1)/2,j}))
            xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")
            % for legGC = 1:N, actLegGC{legGC}=num2str(legGC); end
            % legend(actLegGC)

            
            % RIGHT
            % Plot of AllJA (angles over each gait cycles superimposed)
            subplot(3,2,2*j)
            for k=1:size(actAllJA.(joint_centers{(i+1)}+"_angles"), 3)
                actPlot = plot(gaitcyclevector_kin, actAllJA.(joint_centers{(i+1)}+"_angles")(:,j,k), LineWidth=1); hold on
                if k<actGCperSession(2)             % set color of first session
                    actPlot.Color=SessionColor(1,:);
                elseif k>=actGCperSession(3)        % set color of third session
                    actPlot.Color=SessionColor(3,:);
                else                                % set color of second session
                    actPlot.Color=SessionColor(2,:);
                end
            end
            hold off
            title(string(AnglesName{(i+1)/2,j}))
            xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")
            
        end
    end
end

clear actGCperSession SessionColor actPlot sub sess actAllJA i j k sgTitleTotal uboundL lboundL uboundR lboundR StdAnglesColor

disp("   4.5: Joints Angles Overlaying Plot (All Gait Cycles of each Session Overlayed)   --> DONE")

%% Joints Angles Average Trend and Variability Plot (All Gait Cycles)
% Comment and un-comment std/min-max plot lines to use one of them.

close all

StdAnglesColor = {'r'; 'b'; 'g'};
MinMaxAnglesColor =  {'r'; 'b'; 'g'};

for sub = 1:numSub
    for sess = 1:numSess+1 % (session 1, 2, 3 or averaged sessions (4))

        % Data selection
        actMeanJA = Data.(SubjectID{sub}).MeanJA(sess);
        actStdJA = Data.(SubjectID{sub}).StdJA(sess);
        actMinJA = Data.(SubjectID{sub}).MinJA(sess);
        actMaxJA = Data.(SubjectID{sub}).MaxJA(sess);

        % Loop to create plots
        for i=1:2:length(fieldnames(actMeanJA))
            figure
            sgTitleTotal = sprintf(sgTitlePlot_sub{sub} + sgTitlePlot_sess{sess} + "\n" + joints{(i+1)/2} + " Joint Angles - L and R");
            sgtitle(sgTitleTotal)
            for j=1:length(AnglesSymb)
                % LEFT
                % Plot of MeanJA
                subplot(3,2,2*j-1)
                plot(gaitcyclevector_kin, actMeanJA.(joint_centers{(i)}+"_angles")(:,j), Color=AnglesColors(j), LineWidth=1), hold on
                title(string(AnglesName{(i+1)/2,j}))
                xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")
                % % Plot of Standard Deviation Bands
                % uboundL = actMeanJA.(joint_centers{(i)}+"_angles")(:,j)' + actStdJA.(joint_centers{(i)}+"_angles")(:,j)';
                % lboundL = actMeanJA.(joint_centers{(i)}+"_angles")(:,j)' - actStdJA.(joint_centers{(i)}+"_angles")(:,j)';
                % fill([gaitcyclevector_kin, fliplr(gaitcyclevector_kin)], [uboundL, fliplr(lboundL)], StdAnglesColor{j}, 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold off
                % Plot of Min-Max Range Bands
                uboundL = actMaxJA.(joint_centers{(i)}+"_angles")(:,j)';
                lboundL = actMinJA.(joint_centers{(i)}+"_angles")(:,j)';
                fill([gaitcyclevector_kin, fliplr(gaitcyclevector_kin)], [uboundL, fliplr(lboundL)], MinMaxAnglesColor{j}, 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold off

                % RIGHT
                % Plot of MeanJA
                subplot(3,2,2*j)
                plot(gaitcyclevector_kin, actMeanJA.(joint_centers{(i+1)}+"_angles")(:,j), Color=AnglesColors(j), LineWidth=1), hold on
                title(string(AnglesName{(i+1)/2,j}))
                xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")
                % % Plot of Standard Deviation Bands
                % uboundR = actMeanJA.(joint_centers{(i+1)}+"_angles")(:,j)' + actStdJA.(joint_centers{(i+1)}+"_angles")(:,j)';
                % lboundR = actMeanJA.(joint_centers{(i+1)}+"_angles")(:,j)' - actStdJA.(joint_centers{(i+1)}+"_angles")(:,j)';
                % fill([gaitcyclevector_kin, fliplr(gaitcyclevector_kin)], [uboundR, fliplr(lboundR)], StdAnglesColor{j}, 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold off
                % Plot of Min-Max Range Bands
                uboundR = actMaxJA.(joint_centers{(i+1)}+"_angles")(:,j)';
                lboundR = actMinJA.(joint_centers{(i+1)}+"_angles")(:,j)';
                fill([gaitcyclevector_kin, fliplr(gaitcyclevector_kin)], [uboundR, fliplr(lboundR)], MinMaxAnglesColor{j}, 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold off

            end
        end
    end
end

clear sub sess actMeanJA actStdJA actMinJA actMaxJA i j sgTitleTotal uboundL lboundL uboundR lboundR StdAnglesColor MinMaxAnglesColor

disp("   4.6: Joints Angles Average Trend and Variability Plot (All Gait Cycles) --> DONE")

%% Joints Angles Average Trend and Variability Plot (All Gait Cycles of Each Session)
close all

% purple, red and green to plot angles of each session with the same color
SessionColor = [0.4940 0.1840 0.5560; 0.8500 0.3250 0.0980; 0.4660 0.6740 0.1880];

for sub = [1 3] % loop over subjetcs
    actAllJA = Data.(SubjectID{sub}).AllJA_allsessions;
    actGCperSession = [1;
                       1 + size(Data.(SubjectID{sub}).AllJA(1).LHJC_angles,3);
                       1 + size(Data.(SubjectID{sub}).AllJA(1).LHJC_angles,3) + size(Data.(SubjectID{sub}).AllJA(2).LHJC_angles,3)];
                      % indices of the starting gait cycles for each session (needed for the color setting)
    
    for i=1:2:length(fieldnames(actAllJA)) % loop over joint centers (Hip, Knee and Akle) angles
        figure
        sgTitleTotal = sprintf(SubjectID{sub} + " - " + joints{(i+1)/2} + " Joint Angles - L and R");
        sgtitle(sgTitleTotal, fontsize=30, fontweight='bold')
        for j=1:length(AnglesSymb) % loop over the three angles
            % LEFT
            % Plot of AllJA (angles over each gait cycles superimposed)
            subplot(3,2,2*j-1)
            for k=1:size(actAllJA.(joint_centers{(i)}+"_angles"), 3) % loop over the gait cycles
                actPlot = plot(gaitcyclevector_kin, actAllJA.(joint_centers{(i)}+"_angles")(:,j,k), LineWidth=1); hold on
                % Setting the same color for the angles of the same session
                if k<actGCperSession(2)             % set color of first session
                    actPlot.Color=SessionColor(1,:);
                elseif k>=actGCperSession(3)        % set color of third session
                    actPlot.Color=SessionColor(3,:);
                else                                % set color of second session
                    actPlot.Color=SessionColor(2,:);
                end
            end            
            hold off
            title(string(AnglesName{(i+1)/2,j}))
            xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")
            set(gca,'fontsize', 15, fontweight='bold')

            % RIGHT
            % Plot of AllJA (angles over each gait cycles superimposed)
            subplot(3,2,2*j)
            for k=1:size(actAllJA.(joint_centers{(i+1)}+"_angles"), 3)
                actPlot = plot(gaitcyclevector_kin, actAllJA.(joint_centers{(i+1)}+"_angles")(:,j,k), LineWidth=1); hold on
                if k<actGCperSession(2)              % set color of first session
                    actPlot.Color=SessionColor(1,:);
                elseif k>=actGCperSession(3)         % set color of third session
                    actPlot.Color=SessionColor(3,:);
                else                                 % set color of second session
                    actPlot.Color=SessionColor(2,:);
                end
            end
            hold off
            title(string(AnglesName{(i+1)/2,j}))
            xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")
            set(gca,'fontsize', 15, fontweight='bold')

        end
    end
end

clear actGCperSession SessionColor actPlot sub sess actAllJA i j k sgTitleTotal uboundL lboundL uboundR lboundR StdAnglesColor gaitcyclevector_kin

disp("   4.7: Joints Angles Average Trend and Variability Plot (All Gait Cycles of Each Session) --> DONE")



%% %%%%%%%%%%%%%%%%%%%%% Muscle Activations/EMG %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf("\n")
disp("End: Kinematics")
fprintf("\n\n\n")
disp("Start: Muscle Activations/EMG")
fprintf("\n")

%% Raw EMG Signals Plot
close all

for sub = 1:numSub
    for sess = 1:numSess
        actsd_sig = Data.(SubjectID{sub}).sd_sig(sess,1);
        ActLastSample = size(Data.(SubjectID{sub}).sd_sig(sess,1).(MuscleCode{end}), 1);
        timevector_emg = linspace(0,(ActLastSample-1)/emg_fsamp,ActLastSample); % time vector
        figure
        sgTitleTotal = sprintf(sgTitlePlot_sub{sub} + sgTitlePlot_sess{sess} + "\nRaw EMG Signals");
        sgtitle(sgTitleTotal)
        for m = 1:numMusc
            try
            subplot(numMusc,1,m)
            plot(timevector_emg, actsd_sig.(MuscleCode{m}), Color='#0072BD')
            xlabel("Time (s)"), ylabel("Signal (V)"), title(MuscleCode{m})
            end
        end
    
    end
end

clear sub sess actsd_sig ActLastSample timevector_emg sgTitleTotal m

disp("0: 0.1: Raw EMG Signals Plot --> DONE")


%% EMG Signals Quality Evaluation
close all

for sub = 1:numSub
    for sess = 1:numSess
        actsd_sig = Data.(SubjectID{sub}).sd_sig(sess,1);

        figure
        sgTitleTotal = sprintf(sgTitlePlot_sub{sub} + sgTitlePlot_sess{sess} + "\nRaw EMG Signals Periodogram");
        sgtitle(sgTitleTotal)

        for m = 1:numMusc
            try
            % Simple Periodogram Computation
            NFFT = length(actsd_sig.(MuscleCode{m})); %round((emg_fsamp/df));
            w = rectwin(length(actsd_sig.(MuscleCode{m})));
            overlap = 0;
            [P,f]=pwelch(actsd_sig.(MuscleCode{m})-mean(actsd_sig.(MuscleCode{m})),w,overlap,NFFT,emg_fsamp);
        
            % Plot of the Periodogram
            subplot(numMusc,1,m)
            plot(f,P/max(P))
            title(MuscleCode{m})
            xlabel("Frequency (Hz)"), ylabel("Periodogram")
            %axis([0 340 min(P) max(P)])
            xlim([0,250])
            end
        end
    end
end

clear sub sess actsd_sig sgTitleTotal df NFFT w overlap P f m

disp("   0.2: EMG Signals Quality Evaluation --> DONE")
fprintf("\n")


%% EMG Signals Band-Pass Filtering + Notch Filtering
close all

% Band-Pass Filter (Low & High in cascade)
Wn = 20/(emg_fsamp/2);
[bh,ah] = butter(6,Wn,'high');
%figure, freqz(bh,ah,2^12,emg_fsamp)
flagStabH = isstable(bh,ah);

Wn = 250/(emg_fsamp/2);
[bl,al] = butter(6,Wn,'low');
%figure, freqz(bl,al,2^12,emg_fsamp)
flagStabL = isstable(bl,al);

% Notch Filter
z = 0.01; B = 2; T = 1/emg_fsamp;
fPL = [50 100 154];
for i = 1:length(fPL)
    [bN(i,:), aN(i,:)] = SecondOrderNotchFilter(z,B,fPL(i),T);
    %figure, freqz(bN(i,:),aN(i,:),2^12,emg_fsamp)
    flagStabN(i) = isstable(bN(i),aN(i));
end


% Filtering
for sub = 1:numSub
    for sess = 1:numSess
        for m = 1:numMusc
            Data.(SubjectID{sub}).sd_sig(sess,1).(MuscleCode{m}) = filtfilt(bh,ah,Data.(SubjectID{sub}).sd_sig(sess,1).(MuscleCode{m}));
            Data.(SubjectID{sub}).sd_sig(sess,1).(MuscleCode{m}) = filtfilt(bl,al,Data.(SubjectID{sub}).sd_sig(sess,1).(MuscleCode{m}));
            for i = 1:length(fPL)
                Data.(SubjectID{sub}).sd_sig(sess,1).(MuscleCode{m}) = filtfilt(bN(i,:),aN(i,:),Data.(SubjectID{sub}).sd_sig(sess,1).(MuscleCode{m}));
            end
            
        end
    end
end

clear Rp Rs Wp Ws n Wn bh ah bl al flagStabL flagStabH flagStabN sub sess m z B fPL T bN aN i

disp("1: EMG Signals Band-Pass + Notch Filtering --> DONE")
fprintf("\n")


%% EMG Signals Envelope Computation (Rectification + LPF)
% Comment or un-comment the loop to see filters' mask or not.
close all

% Filter parameters for each individual subject
Wn = 2/emg_fsamp*[5; 5; 5];

% Loop to see filter mask
% for sub = 1%:numSub
%     %[n,Wn] = buttord(Wp,Ws,Rp,Rs);
%     %[bEnv,aEnv] = butter(n,Wn,'low');
%     Wn(sub) = Wp(sub);
%     [bEnv,aEnv] = butter(6,Wn(sub),'low');
%     %figure, freqz(bEnv,aEnv,2^12,emg_fsamp)
%     flagStabEnv(sub) = isstable(bEnv,aEnv);
% end


% Filtering
for sub = 1:numSub
    for sess = 1:numSess
        for m = 1:length(MuscleCode)
            [bEnv,aEnv] = butter(6,Wn(sub),'low');
            Data.(SubjectID{sub}).EnvelopeRLP(sess).(MuscleCode{m}) = filtfilt(bEnv,aEnv,abs(Data.(SubjectID{sub}).sd_sig(sess).(MuscleCode{m})));
            Data.(SubjectID{sub}).EnvelopeRLP(sess).(MuscleCode{m}) = movmean(Data.(SubjectID{sub}).EnvelopeRLP(sess).(MuscleCode{m}),50);
        end
    end
end

clear sub sess m flagStabEnv bEnv aEnv Rp Rs Wp Ws WnP f f95 actf95 cumP cumP_normalized m NFFT w overlap totalPower x Wn

disp("2: EMG Signals Envelope Computation --> DONE")
fprintf("\n")

%% Envelope and Normalized Envelope Trend and Variability Evaluation (over all the gait cycles)
close all

for sub = 1:numSub
    for sess = 1:numSess
        actHeelStrikes = Data.(SubjectID{sub}).HeelStrikesSamplesR_man{sess,1};

        for m = 1:numMusc
            try
            % Data selection
            actEnv = Data.(SubjectID{sub}).EnvelopeRLP(sess).(MuscleCode{m});

            % Normalization
            actNormEnvelopeRLP = actEnv/max(actEnv);

            % Averaging between the gait cycles
            NEcat = []; Ecat = []; Ecat_all = [];
            for gc = 1:length(actHeelStrikes)-1
                % Normalized
                actNEGaitCyc = actNormEnvelopeRLP(actHeelStrikes(gc)*10:actHeelStrikes(gc+1)*10-1, :); % *10 because kin_fsamp = 1/10*emg_fsamp
                % actNEGaitCyc = resample(actNEGaitCyc,1001,size(actNEGaitCyc,1));
                % actNEGaitCyc = interp1(0:size(actNEGaitCyc,1)-1,actNEGaitCyc,0:0.1:100);
                actNEGaitCyc = cat(1, flipud(actNEGaitCyc), actNEGaitCyc, flipud(actNEGaitCyc));
                actNEGaitCyc = resample(actNEGaitCyc,1001*3,size(actNEGaitCyc,1));
                actNEGaitCyc = actNEGaitCyc(1001+1:1001*2);
                NEcat = cat(2, NEcat, actNEGaitCyc);

                % Not normalized
                actEGaitCyc = actEnv(actHeelStrikes(gc)*10:actHeelStrikes(gc+1)*10-1, :); % *10 because kin_fsamp = 1/10*emg_fsamp
                actEGaitCyc = cat(1, flipud(actEGaitCyc), actEGaitCyc, flipud(actEGaitCyc));
                actEGaitCyc = resample(actEGaitCyc,1001*3,size(actEGaitCyc,1));
                actEGaitCyc = actEGaitCyc(1001+1:1001*2);
                % actEGaitCyc = actEGaitCyc';

                Ecat = cat(2, Ecat, actEGaitCyc);

                Ecat_all = cat(1, Ecat_all, actEGaitCyc);
                
            end
            actMeanNE = mean(NEcat, 2);
            actStdNE = std(NEcat,0,2);
            actMinNE = min(NEcat,[],2);
            actMaxNE = max(NEcat,[],2);

            actMeanE = mean(Ecat, 2);
            actStdE = std(Ecat,0,2);
            actMinE = min(Ecat,[],2);
            actMaxE = max(Ecat,[],2);

            % Storing
            Data.(SubjectID{sub}).MeanNE(sess).(MuscleCode{m}) = actMeanNE;
            Data.(SubjectID{sub}).StdNE(sess).(MuscleCode{m}) = actStdNE;
            Data.(SubjectID{sub}).MinNE(sess).(MuscleCode{m}) = actMinNE;
            Data.(SubjectID{sub}).MaxNE(sess).(MuscleCode{m}) = actMaxNE;

            Data.(SubjectID{sub}).MeanE(sess).(MuscleCode{m}) = actMeanE;
            Data.(SubjectID{sub}).StdE(sess).(MuscleCode{m}) = actStdE;
            Data.(SubjectID{sub}).MinE(sess).(MuscleCode{m}) = actMinE;
            Data.(SubjectID{sub}).MaxE(sess).(MuscleCode{m}) = actMaxE;

            Data.(SubjectID{sub}).CatResampledEnv(sess).(MuscleCode{m}) = Ecat;
            baseXvector = 0:0.1:100; actXvector = []; for i=1:length(actHeelStrikes)-1, actXvector = [actXvector, baseXvector+100*(i-1)]; end
            % Data.(SubjectID{sub}).TimeVectorCatGC(sess).(MuscleCode{m}) = 0:0.1:100'*(length(actHeelStrikes)-1); % actXvector*3;
            Data.(SubjectID{sub}).TimeVectorCatGC(sess).(MuscleCode{m}) = actXvector;
            end
        end
    end
    % Averaging between the sessions
    NEcat = []; Ecat = [];
    for m = 1:numMusc
        % Computation
        for sess = 1:numSess
            NEcat = cat(2, NEcat, Data.(SubjectID{sub}).MeanNE(sess).(MuscleCode{m}));
            Ecat = cat(2, Ecat, Data.(SubjectID{sub}).MeanE(sess).(MuscleCode{m}));
        end
        actMeanNE = mean(NEcat, 2);
        actStdNE = std(NEcat,0,2);
        actMinNE = min(NEcat, 2);
        actMaxNE = max(NEcat,[],2);

        actMeanE = mean(Ecat, 2);
        actStdE = std(Ecat,0,2);
        actMinE = min(Ecat, 2);
        actMaxE = max(Ecat,[],2);

        % Storing
        Data.(SubjectID{sub}).MeanNE(numSess+1).(MuscleCode{m}) = actMeanNE;
        Data.(SubjectID{sub}).StdNE(numSess+1).(MuscleCode{m}) = actStdNE;
        Data.(SubjectID{sub}).MinNE(numSess+1).(MuscleCode{m}) = actMinNE;
        Data.(SubjectID{sub}).MaxNE(numSess+1).(MuscleCode{m}) = actMaxNE;

        Data.(SubjectID{sub}).MeanE(numSess+1).(MuscleCode{m}) = actMeanE;
        Data.(SubjectID{sub}).StdE(numSess+1).(MuscleCode{m}) = actStdE;
        Data.(SubjectID{sub}).MinE(numSess+1).(MuscleCode{m}) = actMinE;
        Data.(SubjectID{sub}).MaxE(numSess+1).(MuscleCode{m}) = actMaxE;
    end
end

disp("3: Envelope and Normalized Envelope Trend and Variability Evaluation --> DONE")
fprintf("\n")

clear actEGaitCyc actXvector baseXvector Ecat i sub sess m NEcat Ecat_all actMeanNE actStdNE actMinNE actMaxNE actMeanE actStdE actMinE actMaxE actHeelStrikes actEnv actNormEnvelopeRLP actNEGaitCyc gc

%% Muscle Activation Computation
% Calling a script that creates and saves all the needed variables to make 
% the plots with "s_PlotsForReportEMG" script.
% Values written in "MuscleActivationComputation" were found as said in the
% report.

MuscleActivationComputation;

disp("4: Muscle Activation Computation --> DONE")

fprintf("\n")
disp("End: Muscle Activations/EMG")




%% %%%%%%%%%%%%%%%%%%%%%%%%% Plots for Report %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calling the scripts that makes the plot inserted in the report.
% Note: if titles, labels, axis or legends are too big, just change the
% properties in the set() functions or in title/sgtitle inside the scripts. 
close all

s_PlotsForReportMETHODS;
s_PlotsForReportJA;
s_PlotsForReportEMG;

fprintf("\n\n\n")
disp("Plots for Report --> DONE")

%% Introduction - Flexion-Extension of R Hip, Knee and Ankle with overlayed gait cycles of SBJ05
%close all

gaitcyclevector_kin = 0:100;

% purple, red and green to plot angles of each session with the same color
SessionColor = [0.4940 0.1840 0.5560; 0.8500 0.3250 0.0980; 0.4660 0.6740 0.1880];

figure
sgtitle("SBJ05 - Flexion-Extension Angles of the Right Lower Limb", fontsize=30, fontweight='bold')
for i=1:3
    % Data selection
    actAllJA = Data.SBJ05.AllJA_allsessions;
    actGCperSession = [1;
                       1 + size(Data.SBJ05.AllJA(1).RHJC_angles,3);
                       1 + size(Data.SBJ05.AllJA(2).RHJC_angles,3) + size(Data.SBJ05.AllJA(3).RHJC_angles,3)];
                      % indices of the starting gait cycles for each session (needed for the color setting)
    % Plot
    subplot(3,1,i)
    for k=1:size(actAllJA.(joint_centers{(i-1)*2+2}+"_angles"), 3)
        actPlot = plot(gaitcyclevector_kin, actAllJA.(joint_centers{(i-1)*2+2}+"_angles")(:,1,k), LineWidth=1); hold on
        if k<actGCperSession(2)             % set color of first session
            actPlot.Color=SessionColor(1,:);
        elseif k>=actGCperSession(3)        % set color of third session
            actPlot.Color=SessionColor(3,:);
        else                                % set color of second session
            actPlot.Color=SessionColor(2,:);
        end
    end
    title(joints{i}), xlabel("% of Gait Cycle"), ylabel("\alpha (°)")
    
    set(gca,'fontsize', 15, fontweight='bold')

end

clear actAllJA actGCperSession actPlot i k SessionColor


%% SBJ05 + TVC13 - Average Trend of L and R (Hip, Knee and Ankle)
%close all

MeanAnglesColor = ["#77AC30"; "#0072BD"; "#D95319"]; % default green, blue and red of matlab to plot angles
StdAnglesColor = {'g'; 'b'; 'r'};

for sub = [1 3] % loop only on SBJ05 and TVC13


% Data selection
actMeanJA = Data.(SubjectID{sub}).MeanAllJA_allsessions;
actStdJA = Data.(SubjectID{sub}).StdAllJA_allsessions;
actMinJA = Data.(SubjectID{sub}).MinAllJA_allsessions;
actMaxJA = Data.(SubjectID{sub}).MaxAllJA_allsessions;

% Loop to create plots
for i=1:2:length(fieldnames(actMeanJA))
    figure
    sgTitleTotal = sprintf(SubjectID{sub} + " - " + joints{(i+1)/2} + " Joint Angles - L and R");
    sgtitle(sgTitleTotal, fontsize=30, fontweight='bold')
    for j=1:length(AnglesSymb)
        % LEFT
        % Plot of MeanJA
        subplot(3,2,2*j-1)
        plot(gaitcyclevector_kin, actMeanJA.(joint_centers{(i)}+"_angles")(:,j), Color=MeanAnglesColor(j), LineWidth=2), hold on
        title(string(AnglesName{(i+1)/2,j}))
        xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")
        % % Plot of Standard Deviation Bands
        uboundL = actMeanJA.(joint_centers{(i)}+"_angles")(:,j)' + actStdJA.(joint_centers{(i)}+"_angles")(:,j)';
        lboundL = actMeanJA.(joint_centers{(i)}+"_angles")(:,j)' - actStdJA.(joint_centers{(i)}+"_angles")(:,j)';
        fill([gaitcyclevector_kin, fliplr(gaitcyclevector_kin)], [uboundL, fliplr(lboundL)], StdAnglesColor{j}, 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold off
        % % Plot of Min-Max Range Bands
        % uboundL = actMaxJA.(joint_centers{(i)}+"_angles")(:,j)';
        % lboundL = actMinJA.(joint_centers{(i)}+"_angles")(:,j)';
        % fill([gaitcyclevector_kin, fliplr(gaitcyclevector_kin)], [uboundL, fliplr(lboundL)], MinMaxAnglesColor{j}, 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold off
        set(gca,'fontsize', 15, fontweight='bold')

        % RIGHT
        % Plot of MeanJA
        subplot(3,2,2*j)
        plot(gaitcyclevector_kin, actMeanJA.(joint_centers{(i+1)}+"_angles")(:,j), Color=MeanAnglesColor(j), LineWidth=2), hold on
        title(string(AnglesName{(i+1)/2,j}))
        xlabel("% of Gait Cycle"), ylabel(string(AnglesSymb{j})+" (°)")
        % Plot of Standard Deviation Bands
        uboundR = actMeanJA.(joint_centers{(i+1)}+"_angles")(:,j)' + actStdJA.(joint_centers{(i+1)}+"_angles")(:,j)';
        lboundR = actMeanJA.(joint_centers{(i+1)}+"_angles")(:,j)' - actStdJA.(joint_centers{(i+1)}+"_angles")(:,j)';
        fill([gaitcyclevector_kin, fliplr(gaitcyclevector_kin)], [uboundR, fliplr(lboundR)], StdAnglesColor{j}, 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold off
        % % Plot of Min-Max Range Bands
        % uboundR = actMaxJA.(joint_centers{(i+1)}+"_angles")(:,j)';
        % lboundR = actMinJA.(joint_centers{(i+1)}+"_angles")(:,j)';
        % fill([gaitcyclevector_kin, fliplr(gaitcyclevector_kin)], [uboundR, fliplr(lboundR)], MinMaxAnglesColor{j}, 'FaceAlpha', 0.1, 'EdgeColor', 'none'), hold off
        
        set(gca,'fontsize', 15, fontweight='bold')
    end
end


end

clear actMeanJA actStdJA AnglesColors i j lboundL lboundR MeanAnglesColor
clear StdAnglesColor sub uboundR uboundL sgTitleTotal actMaxJA actMinJA


%% TVC03 - Angles of Each Gait Cycles and Each Session Overlayed of L and R (Hip, Knee and Ankle)
%close all

% purple, red and green to plot angles of each session with the same color
SessionColor = [0.4940 0.1840 0.5560; 0.8500 0.3250 0.0980; 0.4660 0.6740 0.1880];

for sub = 2 % loop over subjetcs
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

clear actGCperSession SessionColor actPlot sub sess actAllJA i j k
clear gaitcyclevector_kin sgTitleTotal uboundL lboundL uboundR lboundR StdAnglesColor

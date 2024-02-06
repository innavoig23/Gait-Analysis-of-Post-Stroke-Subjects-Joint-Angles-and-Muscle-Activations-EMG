%% Reference System Animation
% If subject is disappearing from the plot, just make axis limits bigger.

% Change manually sub and sess to plot the wanted animation
sub = 3;
sess = 1;

% Data selection
actTraj = Data.(SubjectID{sub}).traj(sess,1);
actLoc_ref = Data.(SubjectID{sub}).loc_ref(sess,1);
actJC = Data.(SubjectID{sub}).JC;

% Elements needed for the plot
SegmentsColors = [0 0.4470 0.7410;0.9290 0.6940 0.1250;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880;0.4660 0.6740 0.1880]; % colormap: one color for each segment
FirstFrame = 1;
LastFrame = size(actTraj.(MarkerCode{sub,1}{1}),1);
link_segments = [1 2; 1 3; 2 4; 3 5; 4 6; 5 7]; % connected segments
%legendCell = {'Pelvis'; 'Femur'; 'Shank'; 'Foot'};
legendCell = {'Pelvis'; 'Femur'; 'Shank'; 'Foot'; 'LHJC'; 'RHJC'};

% First frame of r.s. and origin of every segment (creating the graphic objects)
figure
for s=1:length(segments)

    % Extraction of origin and axis coordinates of actual segment
    origin = actLoc_ref.(segments{s}){1,1}(FirstFrame,:);
    x = actLoc_ref.(segments{s}){2,1}(FirstFrame,:);
    y = actLoc_ref.(segments{s}){3,1}(FirstFrame,:);clc
    z = actLoc_ref.(segments{s}){4,1}(FirstFrame,:);

    % Plot of origin and axis
    hO(s) = scatter3(origin(1),origin(2),origin(3),23,SegmentsColors(s,:),"filled"); hold on
    %hOT(s) = text(origin(1),origin(2),origin(3)-OffsetText, segments{s}, FontSize=8); hold on
    hX(s) = quiver3(origin(1),origin(2),origin(3),x(1),x(2),x(3),100, Linewidth=1, MaxHeadSize=5, AutoScaleFactor=1.3, Color=SegmentsColors(s,:)); hold on
    hY(s) = quiver3(origin(1),origin(2),origin(3),y(1),y(2),y(3),100, Linewidth=1, MaxHeadSize=5, AutoScaleFactor=1.3, Color=SegmentsColors(s,:)); hold on
    hZ(s) = quiver3(origin(1),origin(2),origin(3),z(1),z(2),z(3),100, Linewidth=1, MaxHeadSize=5, AutoScaleFactor=1.3, Color=SegmentsColors(s,:)); hold on


end
% Plot style
axis([-4000 6000 0 2000 -400 2000]) % spatial limits of the laboratory
xlabel('X (mm)'), ylabel('Y (mm)'), zlabel('Z (mm)')
title(sgTitlePlot_sub{sub} + sgTitlePlot_sess{sess} + " - Animation of orientation and posizion of the skeletal segments' reference system")
grid minor

% Plot of joint centers
JCcolors = [1 0 0; 0 0 1];
for j=1:2%length(fieldnames(JC))
    jc_origin = actJC(sess).(joint_centers{j})(FirstFrame,:);
    hJC(j) = scatter3(jc_origin(1),jc_origin(2),jc_origin(3),23,JCcolors(j,:),"filled"); hold on
end

% Connection of the segments
for i_line=1:size(link_segments,1)
    s_1 = link_segments(i_line,1);
    s_2 = link_segments(i_line,2);

    hLS(i_line) = line([actLoc_ref.(segments{s_1}){1,1}(FirstFrame,1) actLoc_ref.(segments{s_2}){1,1}(FirstFrame,1)], [actLoc_ref.(segments{s_1}){1,1}(FirstFrame,2) actLoc_ref.(segments{s_2}){1,1}(FirstFrame,2)], [actLoc_ref.(segments{s_1}){1,1}(FirstFrame,3) actLoc_ref.(segments{s_2}){1,1}(FirstFrame,3)], LineStyle='--', Color='k');
end
legend([hO(1) hO(2) hO(4) hO(6) hJC(1) hJC(2)],legendCell, FontSize=15)

for times=1:40 % repeat the animation many times

% Animation of r.s. and origin of every segment (updating the graphic objects)
for t=FirstFrame+1:LastFrame %FirstFrame+2 %LastFrame
    for s=1:length(segments)

        % Extraction of origin and axis coordinates of actual segment for the frame t
        origin = actLoc_ref.(segments{s}){1,1}(t,:);
        x = actLoc_ref.(segments{s}){2,1}(t,:);
        y = actLoc_ref.(segments{s}){3,1}(t,:);
        z = actLoc_ref.(segments{s}){4,1}(t,:);
        % Update of the graphic objects
        set(hO(s), 'XData', origin(1), 'YData', origin(2), 'ZData', origin(3));
        %set(hOT(s), 'Position', [origin(1) origin(2) origin(3)-OffsetText]);
        set(hX(s), 'XData', origin(1), 'YData', origin(2), 'ZData', origin(3), 'UData', x(1), 'VData', x(2), 'WData', x(3));
        set(hY(s), 'XData', origin(1), 'YData', origin(2), 'ZData', origin(3), 'UData', y(1), 'VData', y(2), 'WData', y(3));
        set(hZ(s), 'XData', origin(1), 'YData', origin(2), 'ZData', origin(3), 'UData', z(1), 'VData', z(2), 'WData', z(3));

    end

    % Update of the link graphic objects
    for i_line=1:size(link_segments,1)
                s_1 = link_segments(i_line,1);
                s_2 = link_segments(i_line,2);
                set(hLS(i_line), ...
                    'XData', [actLoc_ref.(segments{s_1}){1,1}(t,1) actLoc_ref.(segments{s_2}){1,1}(t,1)], ...
                    'YData', [actLoc_ref.(segments{s_1}){1,1}(t,2) actLoc_ref.(segments{s_2}){1,1}(t,2)], ...
                    'ZData', [actLoc_ref.(segments{s_1}){1,1}(t,3) actLoc_ref.(segments{s_2}){1,1}(t,3)]);
    end

    % Update of the JCs
    for j=1:2%length(fieldnames(JC))
        jc_origin = actJC(sess).(joint_centers{j})(t,:);
        set(hJC(j), 'XData', jc_origin(1), 'YData', jc_origin(2), 'ZData', jc_origin(3))
    end

    % Time step of the animation
    % java.lang.Thread.sleep(1);
    % pause(0.01) % max time resolution on MS Windows is 0.01s
    drawnow limitrate % fastest animation between the three written

    set(gca, fontsize=15, fontweight='bold')

end

end

clear t sub sess actTraj actLoc_ref actJC SegmentsColors FirstFrame LastFrame OffsetText link_segments legendCell origin x y z hO hX hY hZ hJC JCcolors jc_origin jc_origin i j s s_1 s_2 i_line hLS s

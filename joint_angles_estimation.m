function joint_angles = joint_angles_estimation(loc_ref)
%
% Input:
% -   loc_ref: struct containing the coordinates of the origin and the
%              reference system of every segments and for every frame
% - NumFrames: total number of acquired frames)
%
% Output:
% - joint_angles: struct containing the Euler Angles of Hip, Ankle and
%                 Knee, ordered as follows: alpha for flexion-extension
%                 (dorsi-flexion for ankle), beta for intra-extra rotation
%                 (inversion-eversion for ankle) and gamma for
%                 abduction-adduction.
%
% Angles are firstly calculated using R=Rprox'*Rdist as 3D rotation matrix,
% and so are intended as the rotation of the distal segment over the
% proximal segment. Then, corrections are applied to angles to compare them 
% with the literature and to get the signs/verses expected.
% 
% Angles are calculated using the Vicon PiG convention:
% "All lower body angles are calculated in rotation order YXZ except for
% ankle angles, which are calculated in order YZX."
%
% Note: one toolbox between Navigation Toolbox, Robotics System Toolbox and
% UAV Toolbox is needed to compute joint angles through rotm2eul function.
% 
% Note 2: numbers near the correction lines indicates the subplot number in
% the main script.
%
%% Importing global variables
global seg_for_angle joint_centers JC_len joints

%% Computation of the joint angles
HipKneeSeq = 'YXZ';
AnkleSeq = 'YZX';

NumFrames = size(loc_ref.pelvis{1,1}, 1); % number of frames of which to compute joint angle estimation

for i = 1:2:JC_len-1 % for loop to compute all joint angles (in order: Hip, Knee, Ankle
    
    for f = 1:NumFrames % for loop to compute joint angles for each frame

        % COMPUTATION
        % Proximal segment data
        RpL = [loc_ref.(seg_for_angle{i}){2,1}(f,:)', loc_ref.(seg_for_angle{i}){3,1}(f,:)', loc_ref.(seg_for_angle{i}){4,1}(f,:)'];
        RpR = [loc_ref.(seg_for_angle{i+1}){2,1}(f,:)', loc_ref.(seg_for_angle{i+1}){3,1}(f,:)', loc_ref.(seg_for_angle{i+1}){4,1}(f,:)'];
        
        % Distal segment data
        RdL = [loc_ref.(seg_for_angle{i+2}){2,1}(f,:)', loc_ref.(seg_for_angle{i+2}){3,1}(f,:)', loc_ref.(seg_for_angle{i+2}){4,1}(f,:)'];
        RdR = [loc_ref.(seg_for_angle{i+3}){2,1}(f,:)', loc_ref.(seg_for_angle{i+3}){3,1}(f,:)', loc_ref.(seg_for_angle{i+3}){4,1}(f,:)'];
        
        % 3D rotation matrix computation
        RL = RpL'*RdL; RR = RpR'*RdR;

        % Joint Angles Computation and Sign + 90° Corrections
        if strcmp(joints{(i+1)/2}, 'Ankle')
            % Computation
            EulAngL(f,:) = rotm2eul(RL, AnkleSeq);
            EulAngR(f,:) = rotm2eul(RR, AnkleSeq);
            
            % Correction
            EulAngL(f,1) = sign(EulAngL(f,1))*(EulAngL(f,1)-sign(EulAngL(f,1))*pi/2); % 1
            EulAngR(f,1) = sign(EulAngR(f,1))*(EulAngR(f,1)-sign(EulAngR(f,1))*pi/2); % 2
            EulAngR(f,2) = -EulAngR(f,2); % 4
            EulAngL(f,3) = -EulAngL(f,3); % 5

        elseif strcmp(joints{(i+1)/2}, 'Knee')
            % Computation
            EulAngL(f,:) = rotm2eul(RL, HipKneeSeq);
            EulAngR(f,:) = rotm2eul(RR, HipKneeSeq);

            % Correction
            EulAngL(f,2) = -EulAngL(f,2); % 3
            EulAngL(f,3) = -EulAngL(f,3); % 5

        else % Hip
            % Computation
            EulAngL(f,:) = rotm2eul(RL, HipKneeSeq);
            EulAngR(f,:) = rotm2eul(RR, HipKneeSeq);

            % Correction
            EulAngL(f,1) = -EulAngL(f,1); % 1
            EulAngR(f,1) = -EulAngR(f,1); % 2
            EulAngL(f,2) = -EulAngL(f,2); % 3
            EulAngL(f,3) = -EulAngL(f,3); % 5
 
        end

    end
    
    % Joint Angles Storing (converted from radiants to degrees)
    joint_angles.(joint_centers{i}+"_angles")(:,1:3) = rad2deg(EulAngL);
    joint_angles.(joint_centers{i+1}+"_angles")(:,1:3) = rad2deg(EulAngR);

end

end


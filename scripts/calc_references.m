function [loc_ref, JC] = calc_references(traj, Antro)
%
% Input:
% - traj: 3D markers coordinates
%
% Output:
% - loc_ref: struct containing the coordinates of the origin and the
%            reference system of every segments and for every frame
% -      JC: struct containing the Joint Centers coordinates for every
%            frame
%
% Segments of Lower Body:
% - pelvis
% - femur (L+R)
% - shanks (L+R)
% - foot (L+R)
%
%% Importing global variables
global mDiameter

%% Pelvis
% Needed elements for pelvis
if isfield(traj, "SACR"), BackMarker = traj.SACR;
else, BackMarker = (traj.RPSI+traj.LPSI)/2; % if SACR is not available, use MPSI, that is, the middle point between RPSI and LPSI
end
AsisTrocDistance = 0.1288*Antro.leg_length-48.56;
teta = 0.5; beta = 0.314; C = Antro.leg_length*0.115-15.3; aa = Antro.LASI_RASI_dist/2;
% Pelvis technical reference system (with normalized axis)
originT = (traj.RASI+traj.LASI)/2;
y = makeunit((traj.LASI-traj.RASI));
suppVec = BackMarker-originT;
z = makeunit(cross(y,suppVec));
x = makeunit(cross(y,z));
% Hip joint centers calculation
% Notes:
% - originT must be added to the position of hjcs in the technical
%   reference system of pelvis to obtain HJCs position in the global
%   reference system.
% - The formulas of lhjc and rhjc are  valid when the subject is walking
%   along the positive direction of X axis, while if it's walking along the
%   negative direction, the y must be switched between left and right: this
%   is done through the walk_orientation_factor.
% - Additionally, if the subject it's walking along the negative direction
%   of X axis, the x of lhjc and rhjc must be inverted by sign.

% x- and y-correction
walk_orientation_factor = sign(diff(BackMarker(:,1)));
if walk_orientation_factor(1)>0, walk_orientation_factor = [1; walk_orientation_factor];
else, walk_orientation_factor = [-1; walk_orientation_factor];
end
walk_orientation_factor = [walk_orientation_factor, walk_orientation_factor, ones(size(BackMarker,1),1)];
lhjc = [C*cos(teta)*sin(beta)-(AsisTrocDistance+mDiameter/2)*cos(beta), -(C*sin(teta)-aa), -C*cos(teta)*cos(beta)-(AsisTrocDistance+mDiameter/2)*sin(beta)]; % [x,y,z] coords in local r.s.
rhjc = [C*cos(teta)*sin(beta)-(AsisTrocDistance+mDiameter/2)*cos(beta), (C*sin(teta)-aa), -C*cos(teta)*cos(beta)-(AsisTrocDistance+mDiameter/2)*sin(beta)]; % [x,y,z] coords in local r.s.
LHJC = originT + walk_orientation_factor.*repmat(lhjc,size(BackMarker,1),1); % [x,y,z] coords in global r.s.
RHJC = originT + walk_orientation_factor.*repmat(rhjc,size(BackMarker,1),1); % [x,y,z] coords in global r.s.
% Pelvis anatomical reference system (with normalized axis)
originA = (LHJC+RHJC)/2;
% Axis of anatomical r.s. are equal to the ones of the technical r.s.
% Adding reference system and origin coordinates of pelvis to loc_ref output
loc_ref.pelvis = {originA; x; y; z};
% Adding HJCs to JC struct
JC.LHJC = LHJC;
JC.RHJC = RHJC;

%% Thighs
% Knee joint centers calculation
LKJC = chordPiG(traj.LTHI,LHJC,traj.LKNE,Antro.knee_width/2+mDiameter/2);
RKJC = chordPiG(traj.RTHI,RHJC,traj.RKNE,Antro.knee_width/2+mDiameter/2);
% Thigh anatomical reference system (with normalized axis)
originAL = LKJC; originAR = RKJC;
zL = makeunit(LHJC-LKJC); zR = makeunit(RHJC-RKJC);
suppVecL = traj.LTHI-LHJC; suppVecR = traj.RTHI-RHJC;
xL = makeunit(-cross(zL,suppVecL)); xR = makeunit(cross(zR,suppVecR));
yL = makeunit(cross(zL,xL)); yR = makeunit(cross(zR,xR));
% Adding reference system and origin coordinates of thighs to loc_ref output
loc_ref.femurL = {originAL; xL; yL; zL}; % left side
loc_ref.femurR = {originAR; xR; yR; zR}; % right side
% Adding KJCs to JC struct
JC.LKJC = LKJC; % left side
JC.RKJC = RKJC; % right side

%% Shanks
% Knee joint centers calculation
LAJC = chordPiG(traj.LTIB,LKJC,traj.LANK,Antro.ankle_width/2+mDiameter/2);
RAJC = chordPiG(traj.RTIB,RKJC,traj.RANK,Antro.ankle_width/2+mDiameter/2);
% Thigh anatomical reference system (with normalized axis)
originAL = LAJC; originAR = RAJC;
zL = makeunit((LKJC-LAJC)); zR = makeunit((RKJC-RAJC));
suppVecL = LKJC-traj.LTIB; suppVecR = RKJC-traj.RTIB;
suppVecL = -suppVecL; suppVecR= -suppVecR;
xL = makeunit(-cross(zL,suppVecL)); xR = makeunit(cross(zR,suppVecR));
yL = makeunit(cross(zL,xL)); yR = makeunit(cross(zR,xR));
% Adding reference system and origin coordinates of shanks to loc_ref output
loc_ref.shankL = {originAL; xL; yL; zL}; % left side
loc_ref.shankR = {originAR; xR; yR; zR}; % right side
% Adding AJCs to JC struct
JC.LAJC = LAJC; % left side
JC.RAJC = RAJC; % right side

% Note: only "torsioned tibia" (from PiG reference guide) is needed

%% Feet
% Foot uncorrected anatomical reference system (with normalized axis)
originUAL = traj.LTOE; originUAR = traj.RTOE;
zL = makeunit((LAJC-traj.LTOE)); zR = makeunit((RAJC-traj.RTOE));
suppVecL = LKJC-originUAL; suppVecR = RKJC-originUAR;
yL = makeunit(cross(zL,suppVecL)); yR = makeunit(cross(zR,suppVecR));
xL = makeunit(cross(yL,zL)); xR = makeunit(cross(yR,zR));
% Adding reference system and origin coordinates of ankles to loc_ref output
loc_ref.footL = {originUAL; xL; yL; zL}; % left side
loc_ref.footR = {originUAR; xR; yR; zR}; % right side

% Note: only "uncorrected" (from PiG reference guide) is needed

end

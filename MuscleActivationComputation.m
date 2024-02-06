% Script where all the parameters found and the signals obtained are saved
% into Data struct.

%% SBJ05
% Parameters setting
% Session 1
NoiseIntervals.SBJ05.RRF{:,1} = 2696:2868;
NoiseIntervals.SBJ05.RVL{:,1} = 927:1030;
NoiseIntervals.SBJ05.RST{:,1} = 4010:4144;
NoiseIntervals.SBJ05.RBF{:,1} = 4010:4144;
NoiseIntervals.SBJ05.RTA{:,1} = 3677:3823;
Nsigma.SBJ05(1,:) = [2.5 3 3 2.5 3];
CycleExcluded.SBJ05{1} = [];

% Session 2
NoiseIntervals.SBJ05.RRF{:,2} = 3544:3725;
NoiseIntervals.SBJ05.RVL{:,2} = 2657:2766;
NoiseIntervals.SBJ05.RST{:,2} = 808:965;
NoiseIntervals.SBJ05.RBF{:,2} = 3883:3973;
NoiseIntervals.SBJ05.RTA{:,2} = 3554:3663;
Nsigma.SBJ05(2,:) = [2.5 3 3 2.5 3];
CycleExcluded.SBJ05{2} = [1];

% Session 3
NoiseIntervals.SBJ05.RRF{:,3} = 5663:5832;
NoiseIntervals.SBJ05.RVL{:,3} = 2618:2724;
NoiseIntervals.SBJ05.RST{:,3} = 3693:3880;
NoiseIntervals.SBJ05.RBF{:,3} = 1375:1553;
NoiseIntervals.SBJ05.RTA{:,3} = 2345:2409;
Nsigma.SBJ05(3,:) = [3.5 3 3 3.5 3];
CycleExcluded.SBJ05{3} = [1];

% Parameters storing
for sess = 1:numSess
    Data.SBJ05.ActivationParameters.Nfactor(sess,:) = Nsigma.SBJ05(sess,:);
    Data.SBJ05.ActivationParameters.CycleExcluded{sess} = CycleExcluded.SBJ05{sess};
    for m = 1:numMusc
        Data.SBJ05.ActivationParameters.NoiseIntervals.(MuscleCode{m}){:,sess} = NoiseIntervals.SBJ05.(MuscleCode{m}){:,sess};
    end
end

% Muscle Activation
for sess = 1:numSess
    % Data selection
    actNfactor = Data.SBJ05.ActivationParameters.Nfactor(sess,:);
    actCycleExcluded = Data.SBJ05.ActivationParameters.CycleExcluded{sess};
    for m = 1:numMusc
        % Data selection
        actNoiseSamples = Data.SBJ05.ActivationParameters.NoiseIntervals.(MuscleCode{m}){:,sess};
        actEnvResampled = Data.SBJ05.CatResampledEnv(sess).(MuscleCode{m});
        actEnv = Data.SBJ05.EnvelopeRLP(sess).(MuscleCode{m});
        actNumGC = size(actEnvResampled,2);
        actNoiseEnv = actEnv(actNoiseSamples);

        % Muscle Activation Intervals Computation
        actMu = mean(actNoiseEnv);
        actSigma = std(actNoiseEnv);
        actThreshold = actMu + actNfactor(m)*actSigma;
        actMuscleActivations = actEnvResampled > actThreshold;

        if m ~= numMusc % not TA
            actCyclesToInclude = setdiff(1:actNumGC, actCycleExcluded);
            % Data storing
            Data.SBJ05.MuscleActivationInt(1,sess).(MuscleCode{m}) = actMuscleActivations(:,actCyclesToInclude);
            Data.SBJ05.EnvThreshold(1,sess).(MuscleCode{m}) = actThreshold;
        else % TA
            % Data storing
            Data.SBJ05.MuscleActivationInt(1,sess).(MuscleCode{m}) = actMuscleActivations;
            Data.SBJ05.EnvThreshold(1,sess).(MuscleCode{m}) = actThreshold;
        end
    end
end

% All Gait Cycles concatenated storing
for m = 1:numMusc
    tmp = [];
    for sess = 1:numSess
        tmp = cat(2, tmp, Data.SBJ05.MuscleActivationInt(sess).(MuscleCode{m}));
    end
    Data.SBJ05.MuscleActivationInt_allsessions.(MuscleCode{m}) = tmp;
end

% Variability Parameters and Mean Muscle Activation
for m = 1:numMusc-1 % TA excluded
    for gc = 1:size(Data.SBJ05.MuscleActivationInt_allsessions.RRF,2)
        actMuscleActivations = Data.SBJ05.MuscleActivationInt_allsessions.(MuscleCode{m})(:,gc);
        actDiff.(MuscleCode{m})(:,gc) = [0; diff(actMuscleActivations)];
        Data.SBJ05.VariabilityParameters.OnMuscles.(MuscleCode{m})(:,gc) = find(actDiff.(MuscleCode{m})(:,gc) == 1);
        Data.SBJ05.VariabilityParameters.OffMuscles.(MuscleCode{m})(:,gc) = find(actDiff.(MuscleCode{m})(:,gc) == -1);
    end
    Data.SBJ05.VariabilityParameters.MeanOnMuscles.(MuscleCode{m}) = round(mean(Data.SBJ05.VariabilityParameters.OnMuscles.(MuscleCode{m}),2));
    Data.SBJ05.VariabilityParameters.StdOnMuscles.(MuscleCode{m}) = round(std(Data.SBJ05.VariabilityParameters.OnMuscles.(MuscleCode{m}),0,2));
    Data.SBJ05.VariabilityParameters.MeanOffMuscles.(MuscleCode{m}) = round(mean(Data.SBJ05.VariabilityParameters.OffMuscles.(MuscleCode{m}),2));
    Data.SBJ05.VariabilityParameters.StdOffMuscles.(MuscleCode{m}) = round(std(Data.SBJ05.VariabilityParameters.OffMuscles.(MuscleCode{m}),0,2));

    Data.SBJ05.MeanMuscleActivation.(MuscleCode{m}) = BooleanSignalCreator(Data.SBJ05.VariabilityParameters.MeanOnMuscles.(MuscleCode{m}),...
                                                                              Data.SBJ05.VariabilityParameters.MeanOffMuscles.(MuscleCode{m}));

end

clear sub sess m NoiseIntervals Nsigma CycleExcluded actNfactor actCycleExcluded actNoiseSamples
clear actEnvResampled actEnv actNumGC actNoiseEnv actMu actSigma actThreshold
clear actMuscleActivations actCyclesToInclude tmp actDiff gc

%% TVC03
% Parameters setting
% Session 1
NoiseIntervals.TVC03.RRF{:,1} = 1719:1838;
NoiseIntervals.TVC03.RVL{:,1} = 4736:5210;
NoiseIntervals.TVC03.RST{:,1} = 2679:2862;
NoiseIntervals.TVC03.RBF{:,1} = 2679:2862;
NoiseIntervals.TVC03.RTA{:,1} = 2421:2484;
Nsigma.TVC03(1,:) = [2.5 4 3.3 2.5 2.6];

% Session 2
NoiseIntervals.TVC03.RRF{:,2} = []; % sEMG signal missing
NoiseIntervals.TVC03.RVL{:,2} = 4855:5048;
NoiseIntervals.TVC03.RST{:,2} = 861:1111;
NoiseIntervals.TVC03.RBF{:,2} = 4562:4869;
NoiseIntervals.TVC03.RTA{:,2} = 3809:3900;
Nsigma.TVC03(2,:) = [0 4 3 3 2.5];

% Session 3
NoiseIntervals.TVC03.RRF{:,3} = 1121:1338;
NoiseIntervals.TVC03.RVL{:,3} = 1086:1683;
NoiseIntervals.TVC03.RST{:,3} = 4195:4420;
NoiseIntervals.TVC03.RBF{:,3} = 2612:2998;
NoiseIntervals.TVC03.RTA{:,3} = 2198:2426;
Nsigma.TVC03(3,:) = [4 4 4 3.5 3];

% Parameters storing
for sess = 1:numSess
    Data.TVC03.ActivationParameters.Nfactor(sess,:) = Nsigma.TVC03(sess,:);
    for m = 1:numMusc
        Data.TVC03.ActivationParameters.NoiseIntervals.(MuscleCode{m}){:,sess} = NoiseIntervals.TVC03.(MuscleCode{m}){:,sess};
    end
end

% Muscle Activation
for sess = 1:numSess
    % Data selection
    actNfactor = Data.TVC03.ActivationParameters.Nfactor(sess,:);
    for m = 1:numMusc
        % Data selection
        actNoiseSamples = Data.TVC03.ActivationParameters.NoiseIntervals.(MuscleCode{m}){:,sess};
        actEnvResampled = Data.TVC03.CatResampledEnv(sess).(MuscleCode{m});
        actEnv = Data.TVC03.EnvelopeRLP(sess).(MuscleCode{m});
        actNoiseEnv = actEnv(actNoiseSamples);

        % Muscle Activation Intervals Computation
        actMu = mean(actNoiseEnv);
        actSigma = std(actNoiseEnv);
        actThreshold = actMu + actNfactor(m)*actSigma;
        actMuscleActivations = actEnvResampled > actThreshold;

        % Data storing
        Data.TVC03.MuscleActivationInt(1,sess).(MuscleCode{m}) = actMuscleActivations;
        Data.TVC03.EnvThreshold(1,sess).(MuscleCode{m}) = actThreshold;
    end
end

% All Gait Cycles concatenated storing
for m = 1:numMusc
    tmp = [];
    for sess = 1:numSess
        try
        tmp = cat(2, tmp, Data.TVC03.MuscleActivationInt(sess).(MuscleCode{m}));
        end
    end
    Data.TVC03.MuscleActivationInt_allsessions.(MuscleCode{m}) = tmp;
end

% % Variability Parameters and Mean Muscle Activation
% for m = 1:numMusc
%     for gc = 1:size(Data.TVC03.MuscleActivationInt_allsessions.RRF,2)
%         actMuscleActivations = Data.TVC03.MuscleActivationInt_allsessions.(MuscleCode{m})(:,gc);
%         actDiff.(MuscleCode{m})(:,gc) = [0; diff(actMuscleActivations)];
%         Data.TVC03.VariabilityParameters.OnMuscles.(MuscleCode{m})(:,gc) = find(actDiff.(MuscleCode{m})(:,gc) == 1);
%         Data.TVC03.VariabilityParameters.OffMuscles.(MuscleCode{m})(:,gc) = find(actDiff.(MuscleCode{m})(:,gc) == -1);
%     end
%     Data.TVC03.VariabilityParameters.MeanOnMuscles.(MuscleCode{m}) = round(mean(Data.TVC03.VariabilityParameters.OnMuscles.(MuscleCode{m}),2));
%     Data.TVC03.VariabilityParameters.StdOnMuscles.(MuscleCode{m}) = round(std(Data.TVC03.VariabilityParameters.OnMuscles.(MuscleCode{m}),0,2));
%     Data.TVC03.VariabilityParameters.MeanOffMuscles.(MuscleCode{m}) = round(mean(Data.TVC03.VariabilityParameters.OffMuscles.(MuscleCode{m}),2));
%     Data.TVC03.VariabilityParameters.StdOffMuscles.(MuscleCode{m}) = round(std(Data.TVC03.VariabilityParameters.OffMuscles.(MuscleCode{m}),0,2));
% 
%     Data.TVC03.MeanMuscleActivation.(MuscleCode{m}) = BooleanSignalCreator(Data.TVC03.VariabilityParameters.MeanOnMuscles.(MuscleCode{m}),...
%                                                                               Data.TVC03.VariabilityParameters.MeanOffMuscles.(MuscleCode{m}));
% 
% end

clear sub sess m NoiseIntervals Nsigma CycleExcluded actNfactor actCycleExcluded actNoiseSamples
clear actEnvResampled actEnv actNumGC actNoiseEnv actMu actSigma actThreshold
clear actMuscleActivations actCyclesToInclude tmp actDiff gc


%% TVC13
% Session 1
NoiseIntervals.TVC13.RRF{:,1} = 3788:3941;
NoiseIntervals.TVC13.RVL{:,1} = 1860:2161;
NoiseIntervals.TVC13.RST{:,1} = 3183:3318;
NoiseIntervals.TVC13.RBF{:,1} = 2121:2218;
NoiseIntervals.TVC13.RTA{:,1} = 3425:3575;
Nsigma.TVC13(1,:) = [4 3 4 2.6 3.3];
CycleExcluded.TVC13{1} = [];

% Session 2
NoiseIntervals.TVC13.RRF{:,2} = 3626:3755;
NoiseIntervals.TVC13.RVL{:,2} = 3191:3720;
NoiseIntervals.TVC13.RST{:,2} = 2973:3166;
NoiseIntervals.TVC13.RBF{:,2} = 3493:3614;
NoiseIntervals.TVC13.RTA{:,2} = 1340:1600;
Nsigma.TVC13(2,:) = [3.5 2.5 4 3.7 3];
CycleExcluded.TVC13{2} = [];

% Session 3
NoiseIntervals.TVC13.RRF{:,3} = 3395:3688;
NoiseIntervals.TVC13.RVL{:,3} = 4844:5195;
NoiseIntervals.TVC13.RST{:,3} = 5041:5110;
NoiseIntervals.TVC13.RBF{:,3} = 3300:3422;
NoiseIntervals.TVC13.RTA{:,3} = 4509:4827;
Nsigma.TVC13(3,:) = [2.5 3.5 4 2.5 3];
CycleExcluded.TVC13{3} = [1,2];

% Parameters storing
for sess = 1:numSess
    Data.TVC13.ActivationParameters.Nfactor(sess,:) = Nsigma.TVC13(sess,:);
    Data.TVC13.ActivationParameters.CycleExcluded{sess} = CycleExcluded.TVC13{sess};
    for m = 1:numMusc
        Data.TVC13.ActivationParameters.NoiseIntervals.(MuscleCode{m}){:,sess} = NoiseIntervals.TVC13.(MuscleCode{m}){:,sess};
    end
end

% Muscle Activation
for sess = 1:numSess
    % Data selection
    actNfactor = Data.TVC13.ActivationParameters.Nfactor(sess,:);
    actCycleExcluded = Data.TVC13.ActivationParameters.CycleExcluded{sess};
    for m = 1:numMusc
        % Data selection
        actNoiseSamples = Data.TVC13.ActivationParameters.NoiseIntervals.(MuscleCode{m}){:,sess};
        actEnvResampled = Data.TVC13.CatResampledEnv(sess).(MuscleCode{m});
        actEnv = Data.TVC13.EnvelopeRLP(sess).(MuscleCode{m});
        actNumGC = size(actEnvResampled,2);
        actNoiseEnv = actEnv(actNoiseSamples);

        % Muscle Activation Intervals Computation
        actMu = mean(actNoiseEnv);
        actSigma = std(actNoiseEnv);
        actThreshold = actMu + actNfactor(m)*actSigma;
        actMuscleActivations = actEnvResampled > actThreshold;

        if ismember(m,[2 3]) % VL, ST
            actCyclesToInclude = setdiff(1:actNumGC, actCycleExcluded);
            % Data storing
            Data.TVC13.MuscleActivationInt(1,sess).(MuscleCode{m}) = actMuscleActivations(:,actCyclesToInclude);
            Data.TVC13.EnvThreshold(1,sess).(MuscleCode{m}) = actThreshold;
        else % RF, BF, TA
            % Data storing
            Data.TVC13.MuscleActivationInt(1,sess).(MuscleCode{m}) = actMuscleActivations;
            Data.TVC13.EnvThreshold(1,sess).(MuscleCode{m}) = actThreshold;
        end
    end
end

% All Gait Cycles concatenated storing
for m = 1:numMusc
    tmp = [];
    for sess = 1:numSess
        tmp = cat(2, tmp, Data.TVC13.MuscleActivationInt(sess).(MuscleCode{m}));
    end
    Data.TVC13.MuscleActivationInt_allsessions.(MuscleCode{m}) = tmp;
end

% Variability Parameters and Mean Muscle Activation
% RVL
for m=2:3
    for gc = 1:size(Data.TVC13.MuscleActivationInt_allsessions.RVL,2)
        actMuscleActivationsRVL = Data.TVC13.MuscleActivationInt_allsessions.(MuscleCode{m})(:,gc);
        actDiff.(MuscleCode{m})(:,gc) = [0; diff(actMuscleActivationsRVL)];
        Data.TVC13.VariabilityParameters.OnMuscles.(MuscleCode{m})(:,gc) = find(actDiff.(MuscleCode{m})(:,gc) == 1);
        Data.TVC13.VariabilityParameters.OffMuscles.(MuscleCode{m})(:,gc) = find(actDiff.(MuscleCode{m})(:,gc) == -1);
    end

    Data.TVC13.VariabilityParameters.MeanOnMuscles.(MuscleCode{m}) = round(mean(Data.TVC13.VariabilityParameters.OnMuscles.(MuscleCode{m}),2));
    Data.TVC13.VariabilityParameters.StdOnMuscles.(MuscleCode{m}) = round(std(Data.TVC13.VariabilityParameters.OnMuscles.(MuscleCode{m}),0,2));
    Data.TVC13.VariabilityParameters.MeanOffMuscles.(MuscleCode{m}) = round(mean(Data.TVC13.VariabilityParameters.OffMuscles.(MuscleCode{m}),2));
    Data.TVC13.VariabilityParameters.StdOffMuscles.(MuscleCode{m}) = round(std(Data.TVC13.VariabilityParameters.OffMuscles.(MuscleCode{m}),0,2));
    
    Data.TVC13.MeanMuscleActivation.(MuscleCode{m}) = BooleanSignalCreator(Data.TVC13.VariabilityParameters.MeanOnMuscles.(MuscleCode{m}),...
                                                                                  Data.TVC13.VariabilityParameters.MeanOffMuscles.(MuscleCode{m}));
end


clear sub sess m NoiseIntervals Nsigma CycleExcluded actNfactor actCycleExcluded actNoiseSamples
clear actEnvResampled actEnv actNumGC actNoiseEnv actMu actSigma actThreshold
clear actMuscleActivations actCyclesToInclude tmp actDiff gc actMuscleActivations actMuscleActivationsRVL


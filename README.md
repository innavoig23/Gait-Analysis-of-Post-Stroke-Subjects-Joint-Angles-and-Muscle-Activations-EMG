# Gait Analysis of Post-Stroke Subjects: Joint Angles and Muscle Activations (EMG)

This repository contains the work conducted as part of a university course project focusing on the gait analysis of post-stroke subjects.
The research is based on data derived from the paper available at [PubMed](https://pubmed.ncbi.nlm.nih.gov/38040770/).
The analysis includes the examination of joint angles and other kinematic parameters (stride speed, length, and duration) as well as the study of muscle activations/EMG.
The study was computed using MATLAB. The code is provided in the `scripts` folder of this repository. It includes scripts for data processing, analysis, and visualization related to the project's aims.

This repository serves as a comprehensive resource for researchers and students interested in the biomechanics of post-stroke gait rehabilitation, offering insights into the kinematic and kinetic aspects of walking impairments and their potential treatments.


## Project Pipeline

The workflow of this project is outlined as follows:

1. **Identification of Gait Cycle Instances**: Determining the moments of the gait cycle by identifying the minimum of the RHEE marker (located on the right heel) along the vertical axis.
2. **Calculation of Reference Systems**: Establishing the frames of reference necessary for analysis.
3. **Computation of Joint Angles**: Analyzing the angular movements between different joints.
4. **Segmentation of Joint Angles into Gait Cycles and Calculation of Mean and Variability**: Segmenting the angular data into individual gait cycles and computing their mean and variability, using standard deviation and min-max range.
5. **Calculation of Kinematic Parameters (Speed, Step Length, and Duration)**: Computing the kinematic parameters to assess the dynamics of the gait cycle further.
6. **Evaluation of sEMG Signals**: Assessing the muscle activation signals captured through surface electromyography.
7. **Signal Filtering**: Applying filters to clean the sEMG signals from noise.
8. **Computation of Signal Envelope**: Calculating the envelope of the signals to highlight the overall muscle activation trends.
9. **Identification of Noise-Only Zones in sEMG Signals**: Detecting portions of the signal that contain only noise, to refine signal analysis.
10. **Calculation of Threshold for Muscle Activation Instances**: Establishing a threshold on the signal envelope to accurately identify instances of muscle activation.

## Additional Documentation

Alongside the code, the project also involved the creation of a detailed report/thesis. However, due to academic requirements, this document was written in Italian rather than English. This may limit accessibility for non-Italian speakers, but it provides comprehensive insights and findings of the research conducted.

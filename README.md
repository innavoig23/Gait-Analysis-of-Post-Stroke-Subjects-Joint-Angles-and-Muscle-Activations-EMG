# Gait Analysis of Post-Stroke Subjects: Joint Angles and Muscle Activations (EMG)

This repository contains the work conducted as part of a university course project focusing on the gait analysis of post-stroke subjects (and one healthy subject).
The research is based on data derived from the paper available at [PubMed](https://pubmed.ncbi.nlm.nih.gov/38040770/).
The analysis includes the examination of joint angles and other kinematic parameters (stride speed, length, and duration) as well as the study of muscle activations/EMG.
The study was computed using MATLAB. The code is provided in the `scripts` folder of this repository. It includes scripts for data processing, analysis, and visualization related to the project's aims.

This repository serves as a comprehensive resource for people interested in the biomechanics of post-stroke gait rehabilitation, offering insights into the kinematic and kinetic aspects of walking impairments and their potential treatments.


## Project Pipeline

The workflow of this project is outlined as follows:

1. **Identification of Gait Cycles**: Determining the limits of the gait cycles by identifying the minimum of the RHEE marker, located on the right heel, along the vertical axis. A gait cycle starts with an heel strike and ends with the following heel strike.
2. **Calculation of Reference Systems**: Calculating the reference systems of the lower limb segments defined in Vicon protocol.
3. **Computation of Joint Angles**: Calculating the Euler Angles of the lower limb segments.
4. **Segmentation of Joint Angles into Gait Cycles and Calculation of Mean and Variability**: Segmenting the joint angles data into individual gait cycles and computing their mean and variability, using standard deviation and min-max range.
5. **Calculation of Kinematic Parameters (Speed, Step Length, and Duration)**: Computing the kinematic parameters to assess the dynamics of the gait cycle further.
6. **Evaluation of EMG Signals**: Evaluating EMG signals quality observing raw signal and periodogram.
7. **Signal Filtering**: Filtering EMG signal to remove noise and artifacts.
8. **Computation of Signal Envelope**: Calculating the envelope of the signals to highlight the overall muscle activation trends.
9. **Identification of Noise-Only Zones in EMG Signals**: Detecting portions of the signal that contain only noise.
10. **Calculation of Threshold for Muscle Activation Intervals**: Establishing a threshold on the signal envelope to accurately identify intervals of muscle activation.

## Additional Documentation

Alongside the code, the project also involved the creation of a detailed report/thesis. However, due to academic requirements, this document was written in Italian rather than English, limiting accessibility for non-Italian speakers.

## References

This project makes use of `chordPiG.m`, `magnitude.m`, `makecolumn.m`, and `makeunit.m` functions of the biomechZoo toolbox from the following work:
Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. biomechZoo: An open-source toolbox for the processing, analysis, and visualization of biomechanical movement data. Computer Methods and Programs in Biomedicine, Volume 140, 2017, Pages 1-10, [https://doi.org/10.1016/j.cmpb.2016.11.007](https://doi.org/10.1016/j.cmpb.2016.11.007).


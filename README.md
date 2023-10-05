# MatlabDataProcessing
A collection of scripts that import data and generate plots for UVA's Center for Applied Biomechanics Lab RCCADS Lumbar project. RCCADS (Research Consortium for Crashworthiness in Automated Driving Systems) sponsored a project studying lower back (aka Lumbar Spine) injuries for reclined seating positions in a car crash.

Screnshots folder
  3 screenshots demonstrating the type of plots that the code was used to generate. Our code automatically generated several hundred of these types of plots that were used for research analysis. 

Code:
1. RCCADS_Lumbar_Data_Import.m - imports all test data from UVA's Center for Applied Biomechanics test series into a struct called RCCADS_Lumbar.
2. RCCADS_Lumbar_Plotting.m - calls the other three matlab scripts for generating various data plots <br>
   a. RCCADS_SV-MomentPlots.m - Generates a Moment Angle (Nm) vs. flexion angle (deg) plot for all the test conditions and automatically saves a .jpg and matlab .fig. This is using data from SimVitro ("SV") robotics software <br>
   b. RCCADS_SVplots_Combined.m - Generates plots for force, torque, moment, and translation plots in a separate figures for all tests within a test subject. <br>
   c. RCCADS_SVplots_Individual.m - Generates plots for force, torque, moment, translation, pressure transducer, and follower load forces in a 3x2 figure for each specific run within a test subject. 



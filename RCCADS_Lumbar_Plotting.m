%% RCCADS_Lumbar_Plotting
% Handles all SimVitro output plotting

%specimenID = 'THOR50M_2'; %Change this

%Run this if you need to generate Plots for all of them
%specimenIDs = {'940M','945F','992M','1007M','1008M','1040F','1041F','1042F'};
specimenIDs = {'945F','992M','1007M','1008M','1040F','1041F','1042F','THOR50M_1','THOR50M_2'};
%specimenIDs = {'945F','992M','THOR50M_1','THOR50M_2'};

matlab_script_home = '\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1CustomCode';

%% Check if RCCADS Lumbar is loaded
if exist('RCCADS_Lumbar') == 0 %check whether the .mat is already loaded, 0  = not yet loaded, if 1 then this gets bypassed
    disp('starting load')
    load('\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\RCCADS_Lumbar.Mat', 'RCCADS_Lumbar')
    disp('loaded')
end

%% Change directory to 1CustomCode
cd(matlab_script_home)

%% SimVitro Plotting
%Saves plots here:
    %\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\SimVitro Plots


%Individual Run Plots
for i = 1:length(specimenIDs)
RCCADS_SVplots_Individual(RCCADS_Lumbar,char(specimenIDs(i)))
close all
end
    %Plots all forces/moments/translations/rotations in a 3x2 plot similar to SimVitro's plots + pressure transducers and FL forces
    %Makes a plot for each run and saves it to \\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\SimVitro Plots
        %RCCADS_SVplots_Individual(RCCADS_Lumbar,'992M')

close all
%% 
%Sequential Loading Combined Plots
for i = 1:length(specimenIDs)
RCCADS_SVplots_Combined(RCCADS_Lumbar,char(specimenIDs(i)))
    %Plots JCS translations, rotations, forces, moments for each sequential loading run of a specimen all on one graph. 
close all
end
close all

%% Moment Angle Plots
% Plots moment vs angle for sequential loading FL and no FL runs
for i = 1:length(specimenIDs)
RCCADS_MomentPlots(RCCADS_Lumbar, char(specimenIDs(i)))
close all
end
close all

%% We will need these eventually but not right now
% %% Compression Force vs. Superior Displacement Plots for SimVitro
% % Plots force vs displacement for sequential loading FL and no FL runs
% for i = 1:length(specimenIDs)
% RCCADS_CompFvSupD_Plots(RCCADS_Lumbar, char(specimenIDs(i)))
% close all
% end
% close all

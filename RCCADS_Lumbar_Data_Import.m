%% RCCADS Lumbar Spine Data Import
%Created by James Caldwell, Michael Burns
%Created 3/22/23
%Last modified: 7/17/2023 MRB

%Goal: Load SimVitro and DAS data into RCCADS_Lumbar Struct
    %Loads RCCADS_Lumbar from shared drive, adds any new data to it, then saves it
    %Also includes plot functions
%% Project setup
    %change these for a different project

clearvars -except RCCADS_Lumbar

projectlocation = '\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar'; %Location on the drives of the project
runlogfilename = 'RCCADS Lumbar Run Log.xlsx'; %Location is in main folder of 1Data-RAW
%specimenID = 'THOR50M_2'; %Needs to match an Excel tab within the run log
%Removed above line when changed to specimen_list for readin
matlab_script_home = '\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1CustomCode';
    %Will need to change any instance of RCCADS_Lumbar to newprojectname
    %for a different project
%% Load RCCADS_Lumbar
    %Loads RCCADS_Lumbar.Mat so that more data can be added to it
if exist('RCCADS_Lumbar') == 0 %check whether the .mat is already loaded, 0  = not yet loaded, if 1 then this gets bypassed
    disp('starting load')
    load('\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\RCCADS_Lumbar.Mat', 'RCCADS_Lumbar')
    disp('loaded')
end


%% User Must adjust this
specimen_list = {'945F','992M','1007M','1008M','1040F','1041F','1042F','THOR50M_1','THOR50M_2'}; %for the specimen that you want to load data for
new_save = 0; %Change to 1 when you want to save RCCADS_Lumbar struct to NewData 
runplots = 0; %change to 1 if wanted

%% Begin iterative data loading
for specimen_iter = 1:length(specimen_list) %iterates though all desired specimen
    %Should also match the folder within 1Data-RAW\SimVitro
    specimenID = char(specimen_list(specimen_iter)); %The current specimen to check
    specimenID_2 = strcat('spec_',specimenID); %add spec to the beginning

    cd(strcat(projectlocation,'\1Data-RAW')); %'\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-RAW') changes the current directory to be more specific

    [~,~,runlog] = xlsread(runlogfilename, specimenID); %gets all of the run log not just the numeric values, this is why there is the part on the left

    %Finds rows of the runlog that got loaded as entirely NaN's and deletes them
    hasNaN = cellfun(@nnz,cellfun(@isnan, runlog(:,1), 'Unif',0), 'Unif',0);
    Nanindex = find([hasNaN{:}]);
    for j = length(Nanindex):-1:1
        runlog(Nanindex(j),:) = [];
    end

    warning('off','MATLAB:datetime:AmbiguousDateString') %The DAS CSV throws a weird warning with the date formate, which we don't care about anyway so this turns the warning off


    if isfield(RCCADS_Lumbar,(specimenID_2)) == 0 %determines if the specimen has been loaded already
        RCCADS_Lumbar.(specimenID_2) = struct(); %If loading new specimen data, initializes the specimen struct
    end

    %Iterates through the run log, loading the tdms file/DAS csv for each run
    disp('starting new specimen data import')

    for i = 2:length(runlog) %2 so avoid headings


        %% SimVitro Data
        runID = runlog(i,1); %ith row,first column always

        filepath = strcat(projectlocation,'\1Data-RAW\SimVitro\',specimenID,'\',runID,'\Data'); %sets the filepath to where the SV data is held
        filepath = char(filepath);%changes to a string
        cd(filepath); %changes the directory to this new spot

        runID = string(strcat('Run_',runID)); %adds in Run_ for the sake of formatting
        runID = strrep(runID,' ',''); %gets rid of any spaces because they throw issues
        newdatacheck = zeros(1,length(runlog)-1); %a 1 by number of runs - 1 vector for checking

        if exist('RCCADS_Lumbar') && isfield(RCCADS_Lumbar.(specimenID_2),runID) && isfield(RCCADS_Lumbar.(specimenID_2).(runID),'SimVitro') && isfield(RCCADS_Lumbar.(specimenID_2).(runID),'DAS') && isfield(RCCADS_Lumbar.(specimenID_2).(runID),'Vicon')%check if the variable exists and the field has already been created
            %If a run has already been loaded into RCCADS_Lumbar, don't load it again
            continue

        else %Loads data from run log not already in RCCADS_Lumbar

            newdatacheck(i) = 1;

            %Loads files that end in processed.tdms within the simVitro run folder so that not loading duplicates
            tdmsfile = dir('*processed.tdms');

            %Reads the tdms file using matlab's tdmsread function
            %Line below assumes that the file you want is the FIRST processed.tdms file in the folder. This is always for the trajectory part run first. If you have a different order or more than one trajectory per run, code will need to be adjusted
            data = tdmsread(tdmsfile(1).name);

            for col_iter  = 4:width(data) %These are the columns of the TDMS file. Actual data is in columns 4-21

                channelnames = fieldnames(data{col_iter}); %Gets channel names

                for nameiter = 1:(length(channelnames)-3)%subtract three because it stores three additional values that are unneded at the end
                    workingchannel = string(channelnames(nameiter)); %Gets first stream in channel
                    workingchannel = strrep(workingchannel,' ',''); %Gets rid of spaces
                    workingchannel = strrep(workingchannel,'.',''); %Gets rid of periods
                    workingchannel = strrep(workingchannel,'-','_'); %Replaces - with _
                    tdmsdata = table2array(data{col_iter}); %converts from a table to a vector so that it can be cleanly added to the structure
                    RCCADS_Lumbar.(specimenID_2).(runID).SimVitro.(workingchannel) = tdmsdata(:,nameiter); %puts the data into the proper channel
                end
            end

            %% DAS Data

            if iscellstr(runlog(i,2)) %If the run had DAS, load it, this line chacks to see if theres anything there
                DASRun = char(runlog(i,2)); %DAS run name is in the 2nd column of the run log
                cd([projectlocation '\1Data-RAW\DAS\' specimenID '\' DASRun]) %reset the directory location
                [~,~,DASData] = xlsread(char(strcat(runlog(i,2),'.csv')));
                DASChannelnames = char(DASData{23,1:end}); %pulls the channel names that are always in row 23
                DASData = cell2mat(DASData(24:end,1:end)); %pulls all the data in
                for DAS_iter = 1:width(DASData) %for each channel
                    DASchannelname = DASChannelnames(DAS_iter,1:end);%gets the name and cleans it up; char(DASData{23,DAS_iter});
                    DASchannelname = strrep(DASchannelname,':','');
                    DASchannelname = strrep(DASchannelname,' ','');
                    RCCADS_Lumbar.(specimenID_2).(runID).DAS.(DASchannelname) = DASData(:,DAS_iter);
                end
            else
                RCCADS_Lumbar.(specimenID_2).(runID).NO_DAS = 'No DAS';
            end
            %% This is preprocessed and replaced with what is below for the processed data
            %       %% Vicon Data
            %       if iscellstr(runlog(i,3)) && ~strcmp(specimenID,'940M') && ~strcmp(specimenID,'945F') %If the run had Vicon, load it. skip 940 because vicon was not the same for that one
            %           ViconRun = char(runlog(i,3)); %Vicon run name is in the 3rd column
            %           % cd([projectlocation '\1Data-RAW\Vicon\' specimenID '\Session 2']) %reset the directory location
            %           cd([projectlocation '\1Data-ANALYZED\Processed\' specimenID '\Vicon\' ViconRun]) %set the directory location to where the files are
            %           [~,~,ViconData] = xlsread(char(strcat(runlog(i,3),'.csv'))); %add .csv to the end so can grab this file, convert from cell array to text for the name, reads all the data in in the same form as the csv
            %           markernames = ViconData(3,3:end); %isolate the marker name row
            %
            %           for markeriter = 1:3:length(markernames) %replaces the missing spaces with the marker names
            %               indmarkername = markernames(markeriter);%pull the marker name of interest
            %               indmarkername = strrep(indmarkername,specimenID,''); %get the marker name alone
            %               indmarkername = strrep(indmarkername,':',''); %get the marker name alone
            %               markernames(markeriter:markeriter+2) = indmarkername; %adds the marker name to the ones that it should be on
            %           end
            %           ViconData(3,3:end) = markernames; %Pastes the proper name back in there
            %           for markeriter2 = 3:width(ViconData) %go through all columns
            %               indmarkerall = ViconData(3:end,markeriter2); %take out the column we need
            %               indmarkername = char(indmarkerall(1)); %take out the marker name
            %               indmarkerdir = char(indmarkerall(2)); %take out the xyz
            %               indmarkerdata = cell2mat(indmarkerall(4:end)); %take out the data %this doesnt work if we have any non numeric values
            %               RCCADS_Lumbar.(specimenID_2).(runID).Vicon.(indmarkername).(indmarkerdir) = indmarkerdata; %puts the data into the correct directory
            %           end
            %
            %           RCCADS_Lumbar.(specimenID_2).(runID).Vicon.Frame = cell2mat(ViconData(6:end,1)); %puts the frames into the structure
            %           RCCADS_Lumbar.(specimenID_2).(runID).Vicon.Frequency = cell2mat(ViconData(2,1)); %puts the frequency into the structure
            %           RCCADS_Lumbar.(specimenID_2).(runID).Vicon.Time = cell2mat(ViconData(6:end,1))/cell2mat(ViconData(2,1)); %puts the time into the structure
            %       else
            %           RCCADS_Lumbar.(specimenID_2).(runID).NO_Vicon = 'No VICON';
            %
            %       end
            %% Vicon Data (rewritten 7/14/2023
            if iscellstr(runlog(i,3)) && ~strcmp(specimenID,'940M') && ~strcmp(specimenID,'945F')
                %If the run had Vicon, load it. skip 940 because vicon was not the same for that one.
                ViconRun = char(runlog(i,3)); %Vicon run name is in the 3rd column
                if isfile([projectlocation '\1Data-ANALYZED\Processed\' specimenID '\Vicon\' ViconRun '\' ViconRun '_TransformationMatrices.mat'])
                    %checks if the processed file exists too


                    cd([projectlocation '\1Data-ANALYZED\Processed\' specimenID '\Vicon\' ViconRun]) %set the directory location to where the files are

                    varstoload = {'L1_global','L2_global','L3_global','L4_global','L5_global','x_single_points_global','labels_single_points','test'}; %the variables from that .mat file that we need to load
                    load([projectlocation '\1Data-ANALYZED\Processed\' specimenID '\Vicon\' ViconRun '\' ViconRun '_TransformationMatrices.mat'],varstoload{:}); %this reads in the data from this mat file that we need

                    %read in the frequency in HZ
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.frequency = test.viconsamplerate; %gets the total number of frame numbers and populates this as a number
                    %read in the frames
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.frames = (1:length(L1_global.Position(1,:)'))'; %gets the total number of frame numbers and populates this as a number
                    %calculate the time from the frequency and frames
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.time = RCCADS_Lumbar.(specimenID_2).(runID).Vicon.frames/(RCCADS_Lumbar.(specimenID_2).(runID).Vicon.frequency); %gets the total number of frame numbers and populates this as a number

                    %read in the positions
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L1_global.X_Position_global = L1_global.Position(1,:)'; %puts the global x positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L1_global.Y_Position_global = L1_global.Position(2,:)'; %puts the y positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L1_global.Z_Position_global = L1_global.Position(3,:)'; %puts the z positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L2_global.X_Position_global = L2_global.Position(1,:)'; %puts the global x positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L2_global.Y_Position_global = L2_global.Position(2,:)'; %puts the y positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L2_global.Z_Position_global = L2_global.Position(3,:)'; %puts the z positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L3_global.X_Position_global = L3_global.Position(1,:)'; %puts the global x positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L3_global.Y_Position_global = L3_global.Position(2,:)'; %puts the y positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L3_global.Z_Position_global = L3_global.Position(3,:)'; %puts the z positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L4_global.X_Position_global = L4_global.Position(1,:)'; %puts the global x positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L4_global.Y_Position_global = L4_global.Position(2,:)'; %puts the y positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L4_global.Z_Position_global = L4_global.Position(3,:)'; %puts the z positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L5_global.X_Position_global = L5_global.Position(1,:)'; %puts the global x positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L5_global.Y_Position_global = L5_global.Position(2,:)'; %puts the y positions into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L5_global.Z_Position_global = L5_global.Position(3,:)'; %puts the z positions into a column vector

                    %read in the angles
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L1_global.Yaw_Angle_global     = L1_global.Angles(1,:)'; %puts the global yaw angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L1_global.Pitch_Angle_global   = L1_global.Angles(2,:)'; %puts the pitch angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L1_global.Roll_Angle_global    = L1_global.Angles(3,:)'; %puts the roll angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L2_global.Yaw_Angle_global     = L2_global.Angles(1,:)'; %puts the global yaw angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L2_global.Pitch_Angle_global   = L2_global.Angles(2,:)'; %puts the pitch angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L2_global.Roll_Angle_global    = L2_global.Angles(3,:)'; %puts the roll angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L3_global.Yaw_Angle_global     = L3_global.Angles(1,:)'; %puts the global yaw angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L3_global.Pitch_Angle_global   = L3_global.Angles(2,:)'; %puts the pitch angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L3_global.Roll_Angle_global    = L3_global.Angles(3,:)'; %puts the roll angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L4_global.Yaw_Angle_global     = L4_global.Angles(1,:)'; %puts the global yaw angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L4_global.Pitch_Angle_global   = L4_global.Angles(2,:)'; %puts the pitch angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L4_global.Roll_Angle_global    = L4_global.Angles(3,:)'; %puts the roll angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L5_global.Yaw_Angle_global     = L5_global.Angles(1,:)'; %puts the global yaw angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L5_global.Pitch_Angle_global   = L5_global.Angles(2,:)'; %puts the pitch angle into a column vector
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L5_global.Roll_Angle_global    = L5_global.Angles(3,:)'; %puts the roll angle into a column vector

                    %read in the transformation matricies to index need to have
                    %(:,:,number)
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L1_global.T_L1_wrt_base = L1_global.T; %appends in the global T matricies
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L2_global.T_L2_wrt_base = L2_global.T; %appends in the global T matricies
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L3_global.T_L3_wrt_base = L3_global.T; %appends in the global T matricies
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L4_global.T_L4_wrt_base = L4_global.T; %appends in the global T matricies
                    RCCADS_Lumbar.(specimenID_2).(runID).Vicon.L5_global.T_L5_wrt_base = L5_global.T; %appends in the global T matricies

                    %read in the extra markers here in the global coordinate system
                    labels_single_points_new = erase(string(labels_single_points(:)),[specimenID ':']); %gets the names into usable string format for all of them
                    for marker_iter = 1:length(labels_single_points_new) %iterate through all the markers
                        marker_name = labels_single_points_new(marker_iter); %get the name for this iteration
                        RCCADS_Lumbar.(specimenID_2).(runID).Vicon.single_markers_global.(marker_name).whole_global = x_single_points_global(:,marker_iter,:); %reads in the 4x1 vector for every time point
                        RCCADS_Lumbar.(specimenID_2).(runID).Vicon.single_markers_global.(marker_name).x_global = x_single_points_global(1,marker_iter,:); %reads in the x points in the global frame
                        RCCADS_Lumbar.(specimenID_2).(runID).Vicon.single_markers_global.(marker_name).y_global = x_single_points_global(2,marker_iter,:); %reads in the y points in the global frame
                        RCCADS_Lumbar.(specimenID_2).(runID).Vicon.single_markers_global.(marker_name).z_global = x_single_points_global(3,marker_iter,:); %reads in the z points in the global frame
                    end

                else
                    RCCADS_Lumbar.(specimenID_2).(runID).NO_Vicon = 'No VICON';

                end
            end
        end
    end
end
disp('data import complete')

%% Save Data
if new_save == 1
    disp('Starting save')
    save('\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\RCCADS_Lumbar.Mat', 'RCCADS_Lumbar','-v7.3')
    disp('Save finished')
end

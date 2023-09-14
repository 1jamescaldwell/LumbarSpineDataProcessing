%% RCCADS Lumbar Individual Run Plots

%Created by James Caldwell, Edited by Michael Burns
%Created 3/23/23
%Last modified: 4/27/23

%Outputs force, torque, moment, translation, pressure transducer, and follower LC plots in a 3x2 figure

%Calling the function would look like:
%RCCADS_plotting(RCCADS_Lumbar, '940M')

%At the end, saves a .png of the plot to \\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\SimVitro Plots

function RCCADS_SVplots_Individual(RCCADS_Lumbar,specimenID)

    dbstop if error
%     close all
    
    location = 'southoutside'; %Location of legend on plots
    titleFontSize = 25;
    axisFontSize = 20;
    legendFontSize = 13; %this is as big as it can be made
    TransAndRotLinethickness = 2;
    ForceAndTorqLinethickness = 2;    
    specimenID_2 = specimenID;
    specimenID = strcat('spec_', specimenID);
    runNames = fieldnames(RCCADS_Lumbar.(specimenID));
    savelocation = '\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\SimVitro Plots\';
    if not(isfolder(strcat(savelocation,specimenID_2,'\Individual Plots')))
        mkdir(strcat(savelocation,specimenID_2,'\Individual Plots'));
    end
    savelocation = strcat(savelocation,specimenID_2,'\Individual Plots');

    %Loops through each run of the specimen and makes a plot for that run
    for runIter = 1:(length(runNames))
        runName = char(runNames(runIter));


        figure('Name',specimenID_2,'units','normalized','outerposition',[0 0 1 1])
        set(gcf,'color','white') %Figure background color = white
        
        if ~strcmp(specimenID_2,'THOR50M_1') && ~strcmp(specimenID_2,'THOR50M_2') %if it isnt a THOR plot make it 2 rows, 3 columns
            t = tiledlayout(2,3);
        else %if it is a THOR thing then make it a 2x2
            t = tiledlayout(2,2);
            legendFontSize = 15; %this can be bigger if it is THOR
        end
        title(t,runName,'Interpreter', 'none','FontSize',titleFontSize) %Interpreter=none ignores "_" in the runName so letters don't become subscripts
        subtitle(t,strrep(specimenID_2,'_',' '),'FontSize',titleFontSize-4)
        % Forces
        nexttile
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCSLoadPosteriorShear,'LineWidth',ForceAndTorqLinethickness)
        hold on
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCSLoadCompression,'LineWidth',ForceAndTorqLinethickness)
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCSLoadLeftLateralShear,'LineWidth',ForceAndTorqLinethickness)
        ylabel('Force (N)','FontSize',axisFontSize)
        xlabel('Time (s)','FontSize',axisFontSize)
        set(gca,'FontSize',14)
        legend('Posterior Shear','Compression','Left Lateral Shear','Location',location,'FontSize',legendFontSize,'Orientation','horizontal')
        grid on
        grid minor
        
        % Translations
        nexttile
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCS_Anterior,'LineWidth',TransAndRotLinethickness)
        hold on
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCS_Superior,'LineWidth',TransAndRotLinethickness)
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCS_Lateral,'LineWidth',TransAndRotLinethickness)
        ylabel('Translations (mm)','FontSize',axisFontSize)
        xlabel('Time (s)','FontSize',axisFontSize)
        set(gca,'FontSize',14)
        legend('Anterior','Superior','Lateral','Location',location,'FontSize',legendFontSize,'Orientation','horizontal')
        grid on
        grid minor

        % DAS - Pressure Transducers
            %Determining if the run had DAS or not
        if isfield(RCCADS_Lumbar.(specimenID).(runName),'DAS') && ~strcmp(specimenID_2,'THOR50M_1') && ~strcmp(specimenID_2,'THOR50M_2')
            DAS_check = isfield(RCCADS_Lumbar.(specimenID).(runName).DAS,'Chan6PT_060_1');
        else
            DAS_check = 0;
        end
        
        if ~strcmp(specimenID_2,'THOR50M_1') && ~strcmp(specimenID_2,'THOR50M_2') %dont create the tile if this is a THOR thing
        nexttile
        if DAS_check
                plot(RCCADS_Lumbar.(specimenID).(runName).DAS.Time, RCCADS_Lumbar.(specimenID).(runName).DAS.Chan6PT_060_1*0.00689476,'Linewidth',TransAndRotLinethickness)
                hold on    %.00689 is PSI -> MPa
                plot(RCCADS_Lumbar.(specimenID).(runName).DAS.Time, RCCADS_Lumbar.(specimenID).(runName).DAS.Chan7PT_060_2*0.00689476,'Linewidth',TransAndRotLinethickness)
                xlabel('Time (s)','FontSize',axisFontSize )
                ylabel('Pressure (MPa)','FontSize',axisFontSize)
                set(gca,'FontSize',14)
                legend('T12-L1 Pressure Transducer','L4-L5 Pressure Trandsducer','location',location,'FontSize',legendFontSize,'Orientation','horizontal')
                    %Chan 6:PT_060_1 is T12_L1_Pressure
                    %Chan 7:PT_060_2 is L4-L5 pressure
                grid on
                grid minor
        else
            %Textbox with "No DAS"
            annotation('textbox', [0.78, 0.7, 0.1, 0.1], 'String', "No DAS") %This places a text box with horizontal offset of 78% of the Figure's width, and vertical offset of 70% of the Figure's height. The size of the box is 10% of Figure's height by 10% of Figure's width
            xlabel('Time (s)','FontSize',axisFontSize )
            ylabel('Pressure (MPa)','FontSize',axisFontSize)
            set(gca,'FontSize',14)
        end
        end

        % Torques
        nexttile
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCSLoadLeftlateralBendingTorque,'LineWidth',ForceAndTorqLinethickness)
        hold on
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCSLoadRightAxialRotationTorque,'LineWidth',ForceAndTorqLinethickness)
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCSLoadFlexionTorque,'LineWidth',ForceAndTorqLinethickness)
        ylabel('Moment (Nm)','FontSize',axisFontSize)
        xlabel('Time (s)','FontSize',axisFontSize)
        set(gca,'FontSize',14)
        legend('Left Lateral Bending Torque','Right Axial Rotation Torque','Flexion Torque','Location',location,'FontSize',legendFontSize,'Orientation','horizontal')
        grid on
        grid minor

        % Rotations
        nexttile
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCS_LateralBending,'LineWidth',TransAndRotLinethickness)
        hold on
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCS_AxialRotation,'LineWidth',TransAndRotLinethickness)
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCS_Extension,'LineWidth',TransAndRotLinethickness)
        ylabel('Rotations (deg)','FontSize',axisFontSize)
        xlabel('Time (s)','FontSize',axisFontSize)
        set(gca,'FontSize',14)
        legend('Lateral Bending','Axial Rotation','Extension','Location',location,'FontSize',legendFontSize,'Orientation','horizontal')
        grid on
        grid minor
        
        % Follower Load
        if ~strcmp(specimenID_2,'THOR50M_1') && ~strcmp(specimenID_2,'THOR50M_2')
        nexttile
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.FLLCLeft,'LineWidth',ForceAndTorqLinethickness)
        hold on
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.FLLCRight,'LineWidth',ForceAndTorqLinethickness)
        ylabel('Follower Load Forces (N)','FontSize',axisFontSize)
        xlabel('Time (s)','FontSize',axisFontSize)
        set(gca,'FontSize',14)
        legend('Left FL','Right FL','Location',location,'FontSize',legendFontSize,'Orientation','horizontal')
        grid on
        grid minor
        end

        %saving
        png_name = strcat(savelocation,'\',specimenID_2,'_',runName,'.png');
%         fig_name = strrep(fig_name,'png','fig');
%         saveas(gcf,fig_name); %Uncomment if you also want to save the .fig file, which is a much larger file
        saveas(gcf,png_name);
        hold off
        close all
    end
close all
end
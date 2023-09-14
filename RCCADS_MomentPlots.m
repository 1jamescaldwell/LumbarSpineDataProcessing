%% RCCADS Lumbar Moment Plotting

%Created by James Caldwell
%Created 4/12/23
%Last modified: 4/24/23

%Calling the function would look like:
% RCCADS_MomentPlots(RCCADS_Lumbar, '940M')

%At the end, saves a .png and .fig of the plot to \\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\SimVitro Plots

function RCCADS_MomentPlots(RCCADS_Lumbar,specimenID)

    dbstop if error
    close all
%%     
    location = 'eastoutside'; %Location of legend on plots
    titleFontSize = 30;
    axisFontSize = 22;
    legendFontSize = 16;
    Linethickness = 3;
    colorlist = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F','#FF0000','#FF66FF','#006600','#000066','#CC99FF','#663300','#009999'}; %this is a list of ten colors
    linestylelist = {'-','--',':','-.'}; %these are all of the linestyles we can use here

    specimenID_2 = specimenID;
    specimenID = strcat('spec_', specimenID);
    runNames = fieldnames(RCCADS_Lumbar.(specimenID));
    if ~strcmp(specimenID_2,'THOR50M_1') && ~strcmp(specimenID_2,'THOR50M_2')
        FindingIndex = find(contains(runNames,'SequentialLoading'));
    else
        FindingIndex = find(contains(runNames,'deg'));
    end

    savelocation = '\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\SimVitro Plots\';
    if not(isfolder(strcat(savelocation,specimenID_2,'\Moment-Angle Plots'))) %If the folder doesn't exist, make one
        mkdir(strcat(savelocation,specimenID_2,'\Moment-Angle Plots'));
    end
    savelocation = strcat(savelocation,specimenID_2,'\Moment-Angle Plots\');
    
%% Combined FL and No FL plots


    for zerostart_iter = 1:2 %Makes 2 plots: 1 with unadjusted data, and 1 with all the torques starting at zero
        figure('Name',specimenID,'units','normalized','outerposition',[0 0 1 1])
        set(gcf,'color','white') %Figure background color = white
        title('Flexion Moment vs Flexion Angle','FontSize',titleFontSize)
        subtitle(strrep(specimenID_2,'_',' '),'FontSize',(titleFontSize - 4))
        hold on
        legendNames = cell(length(FindingIndex),1);
        linecolorWO = 1;
        linecolorW = 1;
        for i = 1:(length(FindingIndex))
            runName = char(runNames(FindingIndex(i)));
            %resets the color list if it has gotten too large
            if linecolorWO > length(colorlist)
                linecolorWO = 1;
            elseif linecolorW > length(colorlist)
                linecolorW = 1;
            end
            
            if contains(runName,'wo')
                linestylehere = char(linestylelist(2)); %give it a different line style
                linecolorhere = char(colorlist(linecolorWO)); %define the line color for this run
                linecolorWO = linecolorWO + 1; %move to the next line of the iteration
            else
                linestylehere = char(linestylelist(1));
                linecolorhere = char(colorlist(linecolorW));
                linecolorW = linecolorW + 1;
            end
            momentData = RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCSLoadFlexionTorque;    
            [~,max_moment_index] = max(momentData); %return the max moment and the moment index                    
           
           if zerostart_iter == 1       
               %Plot unadjusted data
               plot(-RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCS_Extension(1:max_moment_index), RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCSLoadFlexionTorque(1:max_moment_index),'LineWidth',Linethickness,'LineStyle',linestylehere,'Color',linecolorhere) 
           else
               %This section has all the moments start at zero
               FlexionTorqueZeroStart = RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCSLoadFlexionTorque(1:max_moment_index);
               data_plot_min = min(FlexionTorqueZeroStart);
               FlexionTorqueZeroStart = FlexionTorqueZeroStart + abs(data_plot_min);
               plot(-RCCADS_Lumbar.(specimenID).(runName).SimVitro.JCS_Extension(1:max_moment_index), FlexionTorqueZeroStart(1:max_moment_index),'LineWidth',Linethickness,'LineStyle',linestylehere,'Color',linecolorhere)
               
           end 
            legendNames{i} = runName;
        end
        ylabel('Moment (Nm)','FontSize',axisFontSize)
        xlabel('Flexion Angle (deg)','FontSize',axisFontSize)
        set(gca,'FontSize',20)
        
        legend(legendNames,'Interpreter', 'none','Location',location,'FontSize',legendFontSize);
        grid on
        grid minor
    
    %% Save
        fig_name = strcat(savelocation,specimenID_2,'_MomentAngle.fig');
        if zerostart_iter == 2
            fig_name = strrep(fig_name,'Angle.','Angle_zerostart.');
        end
        png_name = strrep(fig_name,'fig','png');
        saveas(gcf,fig_name); %gcf is get current figure
        saveas(gcf,png_name);
        hold off
        close all
    end
close all
end
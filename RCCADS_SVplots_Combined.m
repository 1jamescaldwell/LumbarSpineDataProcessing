%% RCCADS Lumbar All Runs

%Created by James Caldwell
%Created 3/23/23
%Last modified: 7/24/2023 by Michael Burns

%Outputs force, torque, moment, and translation plots in a 2x2 figure

%Calling the function would look like:
%RCCADS_plotting(RCCADS_Lumbar, '940M)

%At the end, saves a .png and .fig of the plot to \\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\SimVitro Plots

function RCCADS_SVplots_Combined(RCCADS_Lumbar,specimenID)

    dbstop if error
%     close all
    specimenID = strcat('spec_', specimenID); %Ex: spec_940M
    runNames = fieldnames(RCCADS_Lumbar.(specimenID));
    if ~strcmp(specimenID,'spec_THOR50M_1') && ~strcmp(specimenID,'spec_THOR50M_2')
    FindingIndex = find(contains(runNames,'SequentialLoading')); %Finds all fields in that specimen that have "SequentialLoading" in the run name
    else
    FindingIndex = find(contains(runNames,'deg')); %Finds all fields in that specimen that have "deg" in the run name
    end

    legendNames = cell(length(FindingIndex),1); 

   
    plot_it(RCCADS_Lumbar,specimenID,'JCS_Anterior',runNames,FindingIndex,legendNames,' (mm)')
    plot_it(RCCADS_Lumbar,specimenID,'JCS_Superior',runNames,FindingIndex,legendNames,' (mm)')
    plot_it(RCCADS_Lumbar,specimenID,'JCS_Lateral',runNames,FindingIndex,legendNames,' (mm)')

    plot_it(RCCADS_Lumbar,specimenID,'JCS_LateralBending',runNames,FindingIndex,legendNames,' (deg)')
    plot_it(RCCADS_Lumbar,specimenID,'JCS_AxialRotation',runNames,FindingIndex,legendNames,' (deg)')
    plot_it(RCCADS_Lumbar,specimenID,'JCS_Extension',runNames,FindingIndex,legendNames,' (deg)')

    plot_it(RCCADS_Lumbar,specimenID,'JCSLoadPosteriorShear',runNames,FindingIndex,legendNames,' (N)')
    plot_it(RCCADS_Lumbar,specimenID,'JCSLoadCompression',runNames,FindingIndex,legendNames,' (N)')
    plot_it(RCCADS_Lumbar,specimenID,'JCSLoadLeftLateralShear',runNames,FindingIndex,legendNames,' (N)')

    plot_it(RCCADS_Lumbar,specimenID,'JCSLoadLeftlateralBendingTorque',runNames,FindingIndex,legendNames,' (Nm)')
    plot_it(RCCADS_Lumbar,specimenID,'JCSLoadRightAxialRotationTorque',runNames,FindingIndex,legendNames,' (Nm)')
    plot_it(RCCADS_Lumbar,specimenID,'JCSLoadFlexionTorque',runNames,FindingIndex,legendNames,' (Nm)')
    
end

function plot_it(RCCADS_Lumbar,specimenID, plottype,runNames,FindingIndex,legendNames,units)
    
    %Plot details
    location = 'eastoutside'; %Location of legend on plots
    titleFontSize = 28;
    axisFontSize = 22;
    legendFontSize = 16;
    Linethickness = 3;
    colorlist = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F','#FF0000','#FF66FF','#006600','#000066','#CC99FF','#663300','#009999'}; %this is a list of ten colors
    linestylelist = {'-','--',':','-.'}; %these are all of the linestyles we can use here
    linecolorWO = 1; %iterator for the line color of the plots without follower load
    linecolorW = 1; %iterator for the line color of the plots with follower load
    specimenID_2 = strrep(specimenID,'spec_',''); %Ex: spec_940M -> 940M

    figure('Name',specimenID_2,'units','normalized','outerposition',[0 0 1 1])
    set(gcf,'color','white') %Figure background color = white
    title(strrep(plottype,'_',' '),'FontSize',titleFontSize,'Interpreter', 'none')
    subtitle(strrep(specimenID_2,'_',' '),'FontSize',titleFontSize-4)
    hold on
    
    %Put all the plots on one plot
    for i = 1:(length(FindingIndex))
        runName = char(runNames(FindingIndex(i)));
        %resets the color list if it has gotten too large
        if linecolorWO > length(colorlist)
            linecolorWO = 1;
        elseif linecolorW > length(colorlist)
            linecolorW = 1;
        end
        if contains(runName,'wo') %check if it is without follower load
            linestylehere = char(linestylelist(2)); %give it a different line style
            linecolorhere = char(colorlist(linecolorWO)); %define the line color for this run
            linecolorWO = linecolorWO + 1; %move to the next line of the iteration
        else
            linestylehere = char(linestylelist(1));
            linecolorhere = char(colorlist(linecolorW));
            linecolorW = linecolorW + 1;
        end
        disp(linecolorhere)
        plot(RCCADS_Lumbar.(specimenID).(runName).SimVitro.Time, RCCADS_Lumbar.(specimenID).(runName).SimVitro.(plottype),'LineWidth',Linethickness,'LineStyle',linestylehere,'Color',linecolorhere)
        legendNames{i} = runName;
        hold on
    end

    %Label Axes etc
    axislabel = strcat(plottype,units);
    ylabel(strrep(axislabel,'_',' '),'FontSize',axisFontSize,'Interpreter', 'none')
    xlabel('Time (s)','FontSize',axisFontSize)
    set(gca,'FontSize',20)
    legend(legendNames,'Interpreter', 'none','Location',location,'FontSize',legendFontSize);
    grid on
    grid minor
    %Plot browser is the bees knees
    %It adds a toggle so you can add/remove plots as you need

    %Save a .png and .fig
    savelocation = '\\cab-fs07.mae.virginia.edu\NewData\RCCADS\2021-Lumbar\1Data-ANALYZED\SimVitro Plots\';
    if not(isfolder(strcat(savelocation,specimenID_2,'\Combined Plots')))
        mkdir(strcat(savelocation,specimenID_2,'\Combined Plots'));
    end
    savelocation = strcat(savelocation,specimenID_2,'\Combined Plots');
    fig_name = strcat(savelocation,'\',specimenID_2,'_',plottype,'.fig');
    png_name = strrep(fig_name,'fig','png');
    saveas(gcf,fig_name);
    saveas(gcf,png_name);
    hold off
close all
end

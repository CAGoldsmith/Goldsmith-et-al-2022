%Clarissa Goldsmith
%West Virginia University
%11/8/21
clear all
close all

legNames = {'Right Middle';'Left Middle';'Right Hind'; 'Left Hind'};
limbSets = {'Middle Limbs'; 'Hind Limbs'};
jointNames = {'CTr';'TrF';'FTi';'TiTar'};
conds = {'Normal';...
    'ThC1 (pitch), ThC2 (yaw) Fixed';...
    'ThC1 (pitch), ThC2 (yaw), TrF2 (pitch) Fixed';...
    'ThC1 (pitch), ThC2 (yaw), ThC3 (roll), TrF2 (pitch) Fixed';...
    'ThC1 (pitch), ThC2 (yaw), TrF1 (roll), TrF2 (pitch) Fixed'};
trialNames = {'201217_bolt-Chr_Fly03_M_T002','201217_bolt-Chr_Fly05_M_T007','201217_bolt-Chr_Fly06_F_T004',...
    '201217_bolt-Chr_Fly07_F_T012','201218_bolt-Chr_Fly06_M_T011'};
figPathBase = 'C:\Users\Clarissa G\Documents\MATLAB\Fly Keypoint Processing\';

axisConds = {'All Joints Mobile';...
    'ThC1 (pitch), ThC2 (yaw) Fixed';...
    ['$$\begin{array}{c}' 'ThC1 (pitch), ThC2 (yaw),' '\\' 'TrF2 (pitch) Fixed' '\end{array}$$'];...
    ['$$\begin{array}{c}' 'ThC1 (pitch), ThC2 (yaw),' '\\' 'ThC3 (roll), TrF2 (pitch) Fixed' '\end{array}$$'];...
    ['$$\begin{array}{c}' 'ThC1 (pitch), ThC2 (yaw),' '\\' 'TrF1 (roll), TrF2 (pitch) Fixed' '\end{array}$$']};
titleConds = {'All Joints Mobile';...
    'ThC1 (pitch), ThC2 (yaw) Fixed';...
    {'ThC1 (pitch), ThC2 (yaw),' 'TrF2 (pitch) Fixed'};...
    {'ThC1 (pitch), ThC2 (yaw),' 'ThC3 (roll), TrF2 (pitch) Fixed'};...
    {'ThC1 (pitch), ThC2 (yaw),' 'TrF1 (roll), TrF2 (pitch) Fixed'}};
plotTrial = 2;
%Extract the data and find the averages over time for each
for c = 1:length(conds)
    r = 1;
    for l = 1:length(legNames)
        for t=1:length(trialNames)
            figName1 = [trialNames{t} '_' legNames{l} '_FeTi Plane Angle Plot_' conds{c}];
            figPath = [figPathBase trialNames{t} '\' legNames{l} '\'];
            figName2 = [trialNames{t} '_' legNames{l} '_TiTar Positions_' conds{c}];
            if isfile([figPath figName1 '.fig'])
                fig = openfig([figPath figName1 '.fig']);
                d = fig.Children;
                anglesRaw = [];
                %if c == 1
                [~,lines] = d.Children;
                animalAngles{l}{t} = lines(1).YData';
                anglesRaw = lines(2).YData';
                %else
                %                         lines = d.Children;
                %                         anglesRaw = lines(2).YData';
                %end
                %keyboard
                angleError = abs(animalAngles{l}{t} - anglesRaw);
                angleRange(c,r) = abs(max(anglesRaw) - min(anglesRaw));
                avgAngleError(c,r) = mean(angleError);

                if t == plotTrial
                    if c == 1 || c == 4 || c == 5
                        if l == 1 || l == 3
                            if l == 1
                                plotLeg = 1;
                            elseif l == 3
                                plotLeg = 2;
                            end
                            plotAngles{plotLeg}(:,c) = anglesRaw;
%                             fig2 = openfig([figPath figName2 '.fig']);
%                             d2 = fig2.Children;
%                             [~,lines2] = d2.Children;
%                             if c == 1
%                                 animalTiTarPos{plotLeg}(:,1) = lines2(2).XData';
%                                 animalTiTarPos{plotLeg}(:,2) = lines2(2).YData';
%                             end
%                             TiTarPos{plotLeg}{c}(:,1) = lines2(1).XData';
%                             TiTarPos{plotLeg}{c}(:,2) = lines2(1).YData';
                        end
                    end
                end
            end
            r = r+1;
        end
        close all
    end
end

%%

%Plot the data
tl = tiledlayout(4,6,'TileSpacing','tight','Padding','compact'); %Modify based on number of conditions
title(tl,'Femur Angle from Vertical')

colors = [0 0.4470 0.7410;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880;0.6350 0.0780 0.1840];
markers = {'d';'v';'s';'o'; '^'};
transp = 0.5;
h = nexttile(1,[1,3]);
for c = 1:length(conds)
    for t = 1:length(trialNames)
        s1 = scatter(c,avgAngleError(c,t),40,colors(t,:),'filled','Marker',markers{t},'LineWidth',1.5);
        hold on
        s2 = scatter(c,avgAngleError(c,t+length(trialNames)),40,colors(t,:),'Marker',markers{t},'LineWidth',1.5);
    end

    title(h,limbSets{1});
    plotMax = round(max(max(avgAngleError)),-1);
    if abs(plotMax - max(max(avgAngleError))) < 2
        plotMax = plotMax + 5;
    end
    axis([0 length(conds)+1 0 plotMax]);
    %xticks([1:length(conds)]);
    %xticklabels(plotConds);
    ylabel({'Average Error From Animal Data' 'Over Trial (deg)'});
    %xlabel('Condition');
    set(h,'XTick',1:length(axisConds));
    set(h,'XTickLabel','');
    %set(h,'XTickLabel',plotConds);
    %xtickangle(20);
    grid on
end

h = nexttile(4,[1,3]);
for c = 1:length(conds)
    for t = 1:length(trialNames)
        s1 = scatter(c,avgAngleError(c,t+length(trialNames)*2),40,colors(t,:),'filled','Marker',markers{t},'LineWidth',1.5);
        hold on
        s2 = scatter(c,avgAngleError(c,t+length(trialNames)*3),40,colors(t,:),'Marker',markers{t},'LineWidth',1.5);
    end

    title(h,limbSets{2});
    plotMax = round(max(max(avgAngleError)),-1);
    if abs(plotMax - max(max(avgAngleError))) < 2
        plotMax = plotMax + 5;
    end
    axis([0 length(conds)+1 0 plotMax]);
    %xticks([1:length(conds)]);
    %xticklabels(plotConds);
    %ylabel({'Average Error of Femur Angle Magnitude From Vertical' 'Over Trial (deg)'});
    %xlabel('Condition');
    set(h,'XTick',1:length(axisConds));
    %set(h,'XTickLabel',plotConds);
    set(h,'XTickLabel','');
    set(h, 'YTickLabel','')
    %xtickangle(20);
    grid on
end


h = nexttile(7,[1,3]);
for c = 1:length(conds)
    for t = 1:length(trialNames)
        s1 = scatter(c,angleRange(c,t),40,colors(t,:),'filled','Marker',markers{t},'LineWidth',1.5);
        hold on
        s2 = scatter(c,angleRange(c,t+length(trialNames)),40,colors(t,:),'Marker',markers{t},'LineWidth',1.5);
    end

    plotMax = round(max(max(angleRange)),-1);
    if abs(plotMax - max(max(angleRange))) < 2
        plotMax = plotMax + 5;
    end
    axis([0 length(conds)+1 0 plotMax]);
    set(h,'XTick',1:length(conds));
    %set(h,'XTickLabel',axisConds,'TickLabelInterpreter','latex');
    ylabel({'Maximum Angle Range (deg)'});
    xlabel('Condition');
    %set(h, 'XTickLabelRotation', 20)
    grid on
end

h = nexttile(10,[1,3]);
for c = 1:length(conds)
    for t = 1:length(trialNames)
        s1 = scatter(c,angleRange(c,t+length(trialNames)*2),40,colors(t,:),'filled','Marker',markers{t},'LineWidth',1.5);
        hold on
        s2 = scatter(c,angleRange(c,t+length(trialNames)*3),40,colors(t,:),'Marker',markers{t},'LineWidth',1.5);
    end

    plotMax = round(max(max(angleRange)),-1);
    if abs(plotMax - max(max(angleRange))) < 2
        plotMax = plotMax + 5;
    end
    axis([0 length(conds)+1 0 plotMax]);
    set(h,'XTick',1:length(conds));
    %set(h,'XTickLabel',axisConds,'TickLabelInterpreter','latex');
    %ylabel({'Maximum Angle Range (deg)'});
    xlabel('Condition');
    %set(h, 'XTickLabelRotation', 20)
    set(h, 'YTickLabel','')
    grid on
end

for tile = 13:18
    if tile <= 15
        plotLeg = 1;
        leg = 1;
    else
        plotLeg = 2;
        leg = 3;
    end

    plotMax = round(max([max(max(plotAngles{1})),max(max(plotAngles{2}))]),-1);
    plotMin = round(min([min(min(plotAngles{1})),min(min(plotAngles{2}))]),-1);
    if abs(plotMax - max([max(max(plotAngles{1})),max(max(plotAngles{2}))])) < 2
        plotMax = plotMax + 5;
    end
    if abs(plotMin - min([min(min(plotAngles{1})),min(min(plotAngles{2}))])) < 2
        plotMin = plotMin - 5;
    end

    h = nexttile(tile);
    plot(animalAngles{leg}{plotTrial},'b');
    hold on

    if tile == 13 || tile == 16
        plotC = 1;
    elseif tile == 14 || tile == 17
        plotC = 4;
    else
        plotC = 5;
    end

    plot(plotAngles{plotLeg}(:,plotC),'--r');
    %legend('Animal','Simulation');
    title(titleConds{plotC})
    axis([0 length(animalAngles{leg}{plotTrial}) plotMin plotMax])
    grid on

    if tile ~= 13
        set(h, 'YTickLabel','')
    else
         ylabel('Angle (deg)')
    end

end

% for tile = 19:24
%     if tile <= 21
%         plotLeg = 1;
%         leg = 1;
%     else
%         plotLeg = 2;
%         leg = 3;
%     end
%     if tile == 19 || tile == 22
%         plotC = 1;
%     elseif tile == 20 || tile == 23
%         plotC = 4;
%     else
%         plotC = 5;
%     end
% 
%     plotYMaxMid = round(max([max(TiTarPos{1}{1}(:,1)),max(TiTarPos{1}{4}(:,1)),max(TiTarPos{1}{5}(:,1))]),1);
%     plotYMinMid = round(min([min(TiTarPos{1}{1}(:,1)),min(TiTarPos{1}{4}(:,1)),min(TiTarPos{1}{5}(:,1))]),1);
%     plotZMaxMid = round(max([max(TiTarPos{1}{1}(:,2)),max(TiTarPos{1}{4}(:,2)),max(TiTarPos{1}{5}(:,1))]),1);
%     plotZMinMid = round(min([min(TiTarPos{1}{1}(:,2)),min(TiTarPos{1}{4}(:,2)),min(TiTarPos{1}{5}(:,2))]),1);
% 
%     if abs(plotYMaxMid - max([max(TiTarPos{1}{1}(:,1)),max(TiTarPos{1}{4}(:,1)),max(TiTarPos{1}{5}(:,1))])) < 0.1
%         plotYMaxMid = plotYMaxMid + 0.1;
%     end
%     if abs(plotYMinMid - min([min(TiTarPos{1}{1}(:,1)),min(TiTarPos{1}{4}(:,1)),min(TiTarPos{1}{5}(:,1))])) < 0.1
%         plotYMinMid = plotYMinMid - 0.05;
%     end
%     if abs(plotZMaxMid - max([max(TiTarPos{1}{1}(:,2)),max(TiTarPos{1}{4}(:,2)),max(TiTarPos{1}{5}(:,1))])) < 0.1
%         plotZMaxMid = plotZMaxMid + 0.05;
%     end
%     if abs(plotZMinMid - min([min(TiTarPos{1}{1}(:,2)),min(TiTarPos{1}{4}(:,2)),min(TiTarPos{1}{5}(:,2))])) < 0.1
%         plotZMinMid = plotZMinMid - 0.05;
%     end
% 
%     plotYMaxHind = round(max([max(TiTarPos{2}{1}(:,1)),max(TiTarPos{2}{4}(:,1)),max(TiTarPos{2}{5}(:,1))]),1);
%     plotYMinHind = round(min([min(TiTarPos{2}{1}(:,1)),min(TiTarPos{2}{4}(:,1)),min(TiTarPos{2}{5}(:,1))]),1);
%     plotZMaxHind = round(max([max(TiTarPos{2}{1}(:,2)),max(TiTarPos{2}{4}(:,2)),max(TiTarPos{2}{5}(:,2))]),1);
%     plotZMinHind = round(min([min(TiTarPos{2}{1}(:,2)),min(TiTarPos{2}{4}(:,2)),min(TiTarPos{2}{5}(:,2))]),1);
%    
%     if abs(plotYMaxHind - max([max(TiTarPos{2}{1}(:,1)),max(TiTarPos{2}{4}(:,1)),max(TiTarPos{2}{5}(:,1))])) < 0.1
%         plotYMaxHind = plotYMaxHind + 0.05;
%     end
%     if abs(plotYMinHind - min([min(TiTarPos{2}{1}(:,1)),min(TiTarPos{2}{4}(:,1)),min(TiTarPos{2}{5}(:,1))])) < 0.1
%         plotYMinHind = plotYMinHind - 0.1;
%     end
%     if abs(plotZMaxHind - max([max(TiTarPos{2}{1}(:,2)),max(TiTarPos{2}{4}(:,2)),max(TiTarPos{2}{5}(:,2))])) < 0.1
%         plotZMaxHind = plotZMaxHind + 0.05;
%     end
%     if abs(plotZMinHind - min([min(TiTarPos{2}{1}(:,2)),min(TiTarPos{2}{4}(:,2)),min(TiTarPos{2}{5}(:,2))])) < 0.1
%         plotZMinHind = plotZMinHind - 0.05;
%     end
% 
%     h = nexttile(tile);
%     plot(animalTiTarPos{plotLeg}(:,1),animalTiTarPos{plotLeg}(:,2),'-b','Marker','.')
%     hold on
%     plot(TiTarPos{plotLeg}{plotC}(:,1),TiTarPos{plotLeg}{plotC}(:,2),'--r','Marker','.')
%     xlabel('Y Position of TiTar')
%     if tile == 19
%         ylabel('Z Position of TiTar')
%     else
%         set(h, 'YTickLabel','')
%     end
% 
%     if tile <= 21
%         axis([plotYMinMid plotYMaxMid plotZMinMid plotZMaxMid]);
%     else
%         axis([plotYMinHind plotYMaxHind plotZMinHind plotZMaxHind]);
%     end
% 
%     grid on
% end

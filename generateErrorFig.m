%Clarissa Goldsmith
%West Virginia University
%11/8/21
clear all
close all

legNames = {'Right Middle';'Left Middle'; 'Right Hind';'Left Hind'};
limbSets = {'Middle Limbs'; 'Hind Limbs'};
jointNames = {'CTr';'TrF';'FTi';'TiTar'};
figTitles = {'Middle Limbs';'Hind Limbs'};
conds = {'Normal';...
    'ThC1 (pitch), ThC2 (yaw) Fixed';...
    'ThC1 (pitch), ThC2 (yaw), TrF2 (pitch) Fixed';...
    'ThC1 (pitch), ThC2 (yaw), ThC3 (roll), TrF2 (pitch) Fixed';...
    'ThC1 (pitch), ThC2 (yaw), TrF1 (roll), TrF2 (pitch) Fixed'};
titleConds = {'All Joints Mobile';...
    'ThC1 (pitch), ThC2 (yaw) Fixed';...
    {'ThC1 (pitch), ThC2 (yaw),' 'TrF2 (pitch) Fixed'};...
    {'ThC1 (pitch), ThC2 (yaw),' 'ThC3 (roll), TrF2 (pitch) Fixed'};...
    {'ThC1 (pitch), ThC2 (yaw),' 'TrF1 (roll), TrF2 (pitch) Fixed'}};
trialNames = {'201217_bolt-Chr_Fly03_M_T002','201217_bolt-Chr_Fly05_M_T007','201217_bolt-Chr_Fly06_F_T004',...
    '201217_bolt-Chr_Fly07_F_T012','201218_bolt-Chr_Fly06_M_T011'};
figPathBase = 'C:\Users\Clarissa G\Documents\MATLAB\Fly Keypoint Processing\';

legPosConds = {'ThC3 Fixed'; 'TrF Fixed'};
plotTrial = 2;
%Extract the data and find the averages over time for each
avgErrors = [];
for c = 1:length(conds)
    r = 1;
    for l = 1:length(legNames)
        for t=1:length(trialNames)
            figName = [trialNames{t} '_' legNames{l} '_Inv Kin Error Plot v2_' conds{c}];
            figName2 = [trialNames{t} '_' legNames{l} '_TiTar Positions_' conds{c}];
            figPath = [figPathBase trialNames{t} '\' legNames{l} '\'];
            if isfile([figPath figName '.fig'])
                fig = openfig([figPath figName '.fig']);
                d = fig.Children;
                [~,lines] = d.Children;
                errorsRaw = [];
                for k = 1:length(lines)
                    jointNum = length(lines)-(k-1);
                    errorsRaw(:,jointNum) = lines(k).YData';
                end
                avgErrors{c}(r,:) = mean(errorsRaw);
                badRows = [];
                for m = 2:length(errorsRaw)
                    if norm(errorsRaw(m,:)-avgErrors{c}(r,:)) > 2
                        badRows = [badRows, m];
                    end
                end
                for n = 1:length(badRows)
                    errorsRaw(badRows(n),:) = [];
                    badRows = badRows - 1;
                end
                avgErrors{c}(r,:) = mean(errorsRaw);
            end

            if t == plotTrial
                if c == 1 || c == 4 || c == 5
                    if l == 1 || l == 3
                        if l == 1
                            plotLeg = 1;
                        elseif l == 3
                            plotLeg = 2;
                        end
                        fig2 = openfig([figPath figName2 '.fig']);
                        d2 = fig2.Children;
                        [~,lines2] = d2.Children;
                        if c == 1
                            animalTiTarPos{plotLeg}(:,1) = lines2(2).XData';
                            animalTiTarPos{plotLeg}(:,2) = lines2(2).YData';
                        end
                        TiTarPos{plotLeg}{c}(:,1) = lines2(1).XData';
                        TiTarPos{plotLeg}{c}(:,2) = lines2(1).YData';
                    end
                end
            end

            r = r+1;
        end
        close all
    end
    if r > length(trialNames)
        maxAvgErrors(1,c) = max(max(avgErrors{c}));
    else
        maxAvgErrors(2,c) = max(max(avgErrors{c}));
    end
end

%Find the maximum average error value over all trials to set the plot axes
plotMax(1) = round(max(maxAvgErrors(1,:)),1);
% plotMax(2) = round(max(maxAvgErrors(2,:)),1);
if abs(plotMax(1) - max(max(avgErrors{c}(1:length(trialNames),:)))) < .02 || plotMax(1) - max(max(avgErrors{c}(1:length(trialNames),:))) < 0
    plotMax(1) = plotMax(1) + .05;
end

% if abs(plotMax(2) - max(max(avgErrors{c}(length(trialNames)+1:end,:)))) < .02 || plotMax(2) - max(max(avgErrors{c}(length(trialNames)+1:end,:))) < 0
%     plotMax(2) = plotMax(2) + .05;
% end

%Open the figures saved with the position of each type of leg during the max error
%period for the two cases
for ls = 1:length(limbSets)
    for lc = 1:length(legPosConds)
        if ls == 1
            legName = legNames{1};
        else
            legName = legNames{3};
        end
        fig2 = openfig(['201218_bolt-Chr_Fly06_M_T011_' legName '_Max Error Position_' legPosConds{lc} '.fig']);
        d2 = fig2.Children;
        lines = d2.Children;
        robotLegData{ls}{lc}(:,1) = lines(1).XData';
        robotLegData{ls}{lc}(:,2) = lines(1).YData';
        robotLegData{ls}{lc}(:,3) = lines(1).ZData';

        animalLegData{ls}{lc}(:,1) = lines(2).XData';
        animalLegData{ls}{lc}(:,2) = lines(2).YData';
        animalLegData{ls}{lc}(:,3) = lines(2).ZData';
    end
end

%%
%Plot the data
for tit = 1:length(figTitles)
    fig2 = figure;
    if tit == 1
        tl = tiledlayout(4,6); %Modify based on number of conditions
    else
        tl = tiledlayout(fig2,4,6); %Modify based on number of conditions
    end
    title(tl,figTitles{tit})
    colors = [0 0.4470 0.7410;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880;0.6350 0.0780 0.1840];
    markers = {'d';'v';'s';'o'; '^'};
    transp = 0.5;
    for c = 1:length(conds)
        if c < 4
            h = nexttile(1+2*(c-1),[1,2]);
        else
            h = nexttile(8+2*(c-4),[1,2]);
        end
        for k = 1:4 %Number of joints
            for t = 1:length(trialNames)
                if tit == 1
                    s1 = scatter(k,avgErrors{c}(t,k),40,colors(t,:),'filled','Marker',markers{t},'LineWidth',1.5);
                    hold on
                    s2 = scatter(k,avgErrors{c}(t+length(trialNames),k),40,colors(t,:),'Marker',markers{t},'LineWidth',1.5);
                else
                    s1 = scatter(k,avgErrors{c}(t+length(trialNames)*2,k),40,colors(t,:),'filled','Marker',markers{t},'LineWidth',1.5);
                    hold on
                    s2 = scatter(k,avgErrors{c}(t+length(trialNames)*3,k),40,colors(t,:),'Marker',markers{t},'LineWidth',1.5);
                end
            end
        end
        title(titleConds{c});
        axis([0 length(jointNames)+1 0 plotMax]);
        set(h,'XTick',1:length(jointNames));
        set(h,'XTickLabel',jointNames);
        ylabel({'Average Error Over Trial'; '(Num. of Proximal Segments)'});
        xlabel('Joint');
        grid on
    end

    for lc = 1:length(legPosConds)
        h = nexttile(14+2*(lc-1),[1,2]);
        plot3(animalLegData{tit}{lc}(:,1),animalLegData{tit}{lc}(:,2),animalLegData{tit}{lc}(:,3),'-ob')
        hold on
        plot3(robotLegData{tit}{lc}(:,1),robotLegData{tit}{lc}(:,2),robotLegData{tit}{lc}(:,3),'--or')
        grid on
        %         title(titleConds{4})
        ylabel('Y')
        xlabel('X')
        zlabel('Z')
        pbaspect([1 1 1])
        view(100,25)
        title('Frame of Maximum Positional Error')
    end

    for tile = [20,22]
        h = nexttile(tile,[1,2]);
        if tit == 1
            plotLeg = 1;
            leg = 1;
        else
            plotLeg = 2;
            leg = 3;
        end
        if tile == 20
            plotC = 4;
        else
            plotC = 5;
        end

        plotYMaxMid = round(max([max(TiTarPos{1}{1}(:,1)),max(TiTarPos{1}{4}(:,1)),max(TiTarPos{1}{5}(:,1))]),1);
        plotYMinMid = round(min([min(TiTarPos{1}{1}(:,1)),min(TiTarPos{1}{4}(:,1)),min(TiTarPos{1}{5}(:,1))]),1);
        plotZMaxMid = round(max([max(TiTarPos{1}{1}(:,2)),max(TiTarPos{1}{4}(:,2)),max(TiTarPos{1}{5}(:,1))]),1);
        plotZMinMid = round(min([min(TiTarPos{1}{1}(:,2)),min(TiTarPos{1}{4}(:,2)),min(TiTarPos{1}{5}(:,2))]),1);

        if abs(plotYMaxMid - max([max(TiTarPos{1}{1}(:,1)),max(TiTarPos{1}{4}(:,1)),max(TiTarPos{1}{5}(:,1))])) < 0.1
            plotYMaxMid = plotYMaxMid + 0.1;
        end
        if abs(plotYMinMid - min([min(TiTarPos{1}{1}(:,1)),min(TiTarPos{1}{4}(:,1)),min(TiTarPos{1}{5}(:,1))])) < 0.1
            plotYMinMid = plotYMinMid - 0.05;
        end
        if abs(plotZMaxMid - max([max(TiTarPos{1}{1}(:,2)),max(TiTarPos{1}{4}(:,2)),max(TiTarPos{1}{5}(:,1))])) < 0.1
            plotZMaxMid = plotZMaxMid + 0.05;
        end
        if abs(plotZMinMid - min([min(TiTarPos{1}{1}(:,2)),min(TiTarPos{1}{4}(:,2)),min(TiTarPos{1}{5}(:,2))])) < 0.1
            plotZMinMid = plotZMinMid - 0.05;
        end

        plotYMaxHind = round(max([max(TiTarPos{2}{1}(:,1)),max(TiTarPos{2}{4}(:,1)),max(TiTarPos{2}{5}(:,1))]),1);
        plotYMinHind = round(min([min(TiTarPos{2}{1}(:,1)),min(TiTarPos{2}{4}(:,1)),min(TiTarPos{2}{5}(:,1))]),1);
        plotZMaxHind = round(max([max(TiTarPos{2}{1}(:,2)),max(TiTarPos{2}{4}(:,2)),max(TiTarPos{2}{5}(:,2))]),1);
        plotZMinHind = round(min([min(TiTarPos{2}{1}(:,2)),min(TiTarPos{2}{4}(:,2)),min(TiTarPos{2}{5}(:,2))]),1);

        if abs(plotYMaxHind - max([max(TiTarPos{2}{1}(:,1)),max(TiTarPos{2}{4}(:,1)),max(TiTarPos{2}{5}(:,1))])) < 0.1
            plotYMaxHind = plotYMaxHind + 0.05;
        end
        if abs(plotYMinHind - min([min(TiTarPos{2}{1}(:,1)),min(TiTarPos{2}{4}(:,1)),min(TiTarPos{2}{5}(:,1))])) < 0.1
            plotYMinHind = plotYMinHind - 0.1;
        end
        if abs(plotZMaxHind - max([max(TiTarPos{2}{1}(:,2)),max(TiTarPos{2}{4}(:,2)),max(TiTarPos{2}{5}(:,2))])) < 0.1
            plotZMaxHind = plotZMaxHind + 0.05;
        end
        if abs(plotZMinHind - min([min(TiTarPos{2}{1}(:,2)),min(TiTarPos{2}{4}(:,2)),min(TiTarPos{2}{5}(:,2))])) < 0.1
            plotZMinHind = plotZMinHind - 0.05;
        end
        plot(animalTiTarPos{plotLeg}(:,1),animalTiTarPos{plotLeg}(:,2),'-b','Marker','.')
    hold on
    plot(TiTarPos{plotLeg}{plotC}(:,1),TiTarPos{plotLeg}{plotC}(:,2),'--r','Marker','.')
    xlabel('Y Position of TiTar')
    ylabel('Z Position of TiTar')
    title('Position of TiTar over Trial')
    if tit == 1
        axis([plotYMinMid plotYMaxMid plotZMinMid plotZMaxMid]);
    else
        axis([plotYMinHind plotYMaxHind plotZMinHind plotZMaxHind]);
    end
    grid on
    end
    
end

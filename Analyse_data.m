% This sctipt allows to recreate figures and statistics published by Lena
% Hehemann et al. 2026 - Effects of Short-Term Breathwork on Respiration
% and Cognition
clear all; close all
% To run the scripts they need to be located in the same folder as the file
% containing the data. Add the corresponding path and type it here:
path = 'E:\Promotion\Phd-Git\My_Paper_1\publish_analysis\data and script';

% If show_statistics is set to 1, statistics will directly be plotted in
% the figures
show_statistics = 1;

%% Load data and data informations
data = load(sprintf('%s//data',path));
data = data.data;
all_data = data.all_data;
% all data contains information about every trial included in the analysis
% trials have been cleaned based on RTs and button presses beforehand
% Index information for coloumns
Index.RespPhaseStim = 1;
Index.RespPhaseRT = 2;
Index.RespBinStim = 3;
Index.RespBinRT = 4;
Index.Trial = 5;
Index.StimID = 6;
Index.StimLevel = 7;
Index.RT = 8;
Index.Button = 9;
Index.Response = 10;
Index.SubjID = 11;
Index.Block = 12;
Index.Technique = 13;
Index.Trial_since = 16;
Index.Bin = 17;
Index.Paradigm = 18;

%% preallocation of several variabels
%colors for plotting
orange = [245 116 41]/255;
beige = [251 209 162]/255;
light_blue = [125 207 182]/255;
blue = [1 178 202]/255;
dark_blue = [29 78 137]/255;
color = {orange, beige, light_blue, blue, dark_blue};

%Names of techniques
techniques{1} = {'NOI', 'SILE', 'LISE'};
techniques{2} = {'Slow', 'Fast'};

% Number of bins for binned data
Bins = 10;

% needed for plotting
skip_plot = 1;
transperency = 0.5;
y_labels = {'frequency', 'ratio'}
%==========================================================================
%==========================================================================
%% Figure 1: Exemplary respiratory traces
% illustrating spontaneous respiration and breathing practices

% Visualize breathing practice
Traces = data.figure1.Traces;
Info = data.figure1.Info;
% counter for colors
cc = 1;
% initalize figure
[ax,fig,~] = LH_create_subplots([1,2],'rows');

%plot example respiratory traces for both experiments in the lower left and
%right panel
for iexp = 1:size(Traces,2)
    axes(ax{iexp})      % Axis in figure
    tmp = Traces{iexp}; % Traces for experiment 1 or 2
    for Train=1:2       % Training 1 (slow/LISE) or Training 2 (fast/SILE)
        j = find(Info{iexp}(:,3)==Train); % Find which traces belong to Training
        xpos = 1:900;   % x-vector for plotting
        LHerrorshade(xpos,mean(tmp(j,1:900)),sem(tmp(j,1:900)),color{cc})
        cc = cc+1; %Color counter
    end
    % figure settings
    drawnow;
    ylim([-2,2])
    xlim([0,900])
    xticks(0:100:900)
    xlabel('time [s]','FontSize', 16, 'FontWeight','bold')
    xticklabels({'1','2','3','4','5','6','7','8','9'})
    yticks([])
    ylabel('z-score','FontSize', 16, 'FontWeight','bold')
end %iexp

%--------------------------------------------------------------------------
% Plot example characterisation of phases in the upper panel
axes(ax{3})
% % Colormap
cmap = crameri('romaO');
cmap = flipud(cmap);
%Get data
t = data.figure1.ClassTime;     % time vector
Sig = data.figure1.ClassSignal;  % Signal
phase = data.figure1.ClassPhase;% defined phase for each datapoint in Signal

% Interpolation to 256 colors
cmap = interp1(linspace(0,1,size(cmap,1)), cmap, linspace(0,1,256));
% norm phase [1,256]
phase_idx = round(phase/100*255)+1;

hold on
% Plot colorcoded signal of classification
for i = 1:length(t)-1
    if isnan(phase_idx(i)) || isnan(Sig(i))
        % If phase is not defined = black...
        plot(t(i:i+1), Sig(i:i+1), 'k', 'LineWidth', 2)
        hold on
    else
        %... else use the colormap to plot signal
        plot(t(i:i+1), Sig(i:i+1), 'Color', cmap(phase_idx(i),:), 'LineWidth', 3)
        hold on
    end
end

%Figure Settings
xlim([0,2500])
xticks([])
yticks([])
ylabel('Z-score','FontSize', 16, 'FontWeight','bold')
colormap(cmap)
cb = colorbar;
cb.Ticks = [0.1 0.9];
cb.TickLabels = {'Inspiration', 'Expiration'};
cb.FontSize = 16;
cb.FontWeight = 'bold';
xlabel('time','FontSize', 16, 'FontWeight','bold');
ylabel('z-score','FontSize', 16, 'FontWeight','bold');
%==========================================================================
%==========================================================================
%% figure 2 -  Respiratory characteristics during breathing practice
% Prepare figure
[ax,breath] = LH_create_subplots([2,2],'rows');
% Plot respiration frequency for LS03
for ivar = 4
    cc=1; %color_counter
    %subplot at position X
    axes(ax{2});
    %% get data for LS03
    combined = data.figure2.combined{1};
    normal = data.figure2.normal{1};
    %if the sum of normal = 0; normal respiration wasn't recorded for the
    %experiment
    if sum(sum(normal,'omitnan') ~= 0)
        %get the information about cycles during normal respiration
        norm_data = normal(:,ivar);
        %create figure with boxplot and scatter data
        LH_scatterbox(skip_plot,norm_data,'Color','k','alpha', transperency)
    end %if sum(normal) == 0

    %repeat the plotting for each technique
    %skip_plot is needed since some experiments are not containing
    %spontanious respiration.
    for itech = 1:length(techniques)
        %if there is no data for the technique, skip the plot
        if ~isempty(combined{itech})
            %get cycle data for the technique
            tmp_data = combined{itech}(:,ivar);
            %create figure with boxplot and scatter data
            LH_scatterbox(skip_plot+itech,tmp_data,'Color',color{cc},'alpha',transperency,'Size',5)
            hold on
        end %if isempty(combined{itech}
        cc = cc +1;
    end%itech
    hold off
    % Statistics (ttest with fase discovery rate correction)
    line_pos = {[1,2],[2,3],[1,3]};
    line_hight = [0.9, 1.1, 1.3]
    for i = 1:3
        [bfs(i),ps(i)] = bf.ttest(combined{line_pos{i}(1)}(:,ivar),combined{line_pos{i}(2)}(:,ivar));
        Effect2_frequ{i} = meanEffectSize(combined{line_pos{i}(1)}(:,ivar),combined{line_pos{i}(2)}(:,ivar),'Effect','cohen','Paired',true);
    end
    %Correct pvalues of multiple t-test by controling for false discovery rate
    [~, ~, ~, ps]=ck_stat_fdr(ps,0.05,'dep');
    for i =1:3
        line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)], 'Color','k')
        symbol = LH_check_significanz(ps(i));
        text(mean(line_pos{i}),line_hight(i)+0.04,symbol,'Fontsize', 12);
        if show_statistics ==1
            text(line_pos{i}(1)+0.2,line_hight(i)+0.01,sprintf('bf10 = %s',num2str(bfs(i))))
            text(line_pos{i}(1)+0.2,line_hight(i)-0.01,sprintf('p = %s',num2str(ps(i))))
        end
    end
end %ivar

% Plot inhaltation exhalation ratio for each technique in plot 2
%calculate ratio for each technique and participant
axes(ax{4})
color_counter = 3;

if sum((sum(normal,'omitnan')))~=0
    norm_ratio = normal(:,2)./normal(:,3);
    LH_scatterbox(0,norm_ratio,'Color','k', 'Alpha',transperency,'Size',5)
end
for itech = 1:length(techniques{1})
    for isubj = 1:size(combined{itech},1)
        %if insp. or exp. duration is not defined ratio can not be calculated
        if ~isnan(combined{itech}(isubj,2)) || ~isnan(combined{itech}(isubj,3))
            ratio{itech}(isubj,1) = combined{itech}(isubj,2)/combined{itech}(isubj,3);
        else
            ratio{itech}(isubj,1) = NaN;
        end
    end%isubj
    LH_scatterbox(itech,ratio{itech},'Color',color{color_counter},'alpha',transperency,'size',5)
    hold on
    color_counter = color_counter +1;

end%itech
% Statistics (ttest and false discovery correction for p values)
line_pos = {[1,2],[2,3],[1,3]};
line_hight = [3,3.5,4]
for i = 1:3
    [bfs(i),ps(i)] = bf.ttest(ratio{line_pos{i}(1)},ratio{line_pos{i}(2)});
    Effect2_ratio{i} = meanEffectSize(ratio{line_pos{i}(1)},ratio{line_pos{i}(2)}, 'Effect','cohen','Paired',true);
end
%Correct pvalues of multiple t-test by controling for false discovery rate
[~, ~, ~, ps]=ck_stat_fdr(ps,0.05,'dep');
for i =1:3
    line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)],'Color','k');
    symbol = LH_check_significanz(ps(i));
    text(mean(line_pos{i}),line_hight(i)+0.12,symbol,'FontSize',12)
    if show_statistics == 1
        text(line_pos{i}(1)+0.2,line_hight(i)+0.15,sprintf('bf10 = %s',num2str(bfs(i))))
        text(line_pos{i}(1)+0.2,line_hight(i)-0.15,sprintf('p = %s',num2str(ps(i))))
    end
end
ylim([0,4])


% plot data for LH01
% get data for LH01
combined = data.figure2.combined{2};
normal = data.figure2.normal{2};
% combine normal and combined to facilitate t-test calculations
t_combined = {normal,combined{1},combined{2}}
for ivar = 4
    %subplot at position X
    axes(ax{1});
    cc = 1;
    %if the sum of normal = 0; normal respiration wasn't recorded for the
    %experiment
    if sum(sum(normal,'omitnan') ~= 0)
        %get the information about cycles during normal respiration
        norm_data = normal(:,ivar);
        %create figure with boxplot and scatter data
        LH_scatterbox(1,norm_data, 'Color','k','alpha', transperency,'size', 5)
    end %if sum(normal) == 0

    %repeat the plotting for each technique
    %skip_plot is needed since some experiments are not containing
    %spontanious respiration.
    for itech = 1:length(techniques{2})
        %if there is no data for the technique, skip the plot
        if ~isempty(combined{itech})
            %get cycle data for the technique
            tmp_data = combined{itech}(:,ivar);
            %create figure with boxplot and scatter data
            LH_scatterbox(skip_plot+itech,tmp_data,'Color',color{cc},'Alpha',transperency,'size', 5)
            hold on
            color_counter = color_counter +1;
        end %if isempty(combined{itech}
    end%itech
    hold off
    % Statistics (ttest and false discovery correction for p values)
    line_pos = {[1,2],[2,3],[1,3]};
    line_hight = [0.9, 1.1, 1.3]
    for i = 1:3
        [bfs(i),ps(i)] = bf.ttest(t_combined{line_pos{i}(1)}(:,ivar),t_combined{line_pos{i}(2)}(:,ivar));
        Effect1_frequ{i} = meanEffectSize(t_combined{line_pos{i}(1)}(:,ivar),t_combined{line_pos{i}(2)}(:,ivar), 'Effect','cohen','Paired',true);
    end
    %Correct pvalues of multiple t-test by controling for false discovery rate
    [~, ~, ~, ps]=ck_stat_fdr(ps,0.05,'dep');
    for i =1:3
        line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)],'Color', 'k')
        symbol = LH_check_significanz(ps(i));
        text(mean(line_pos{i}),line_hight(i)+0.04,symbol,'Fontsize', 12);
        if show_statistics == 1
            line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)])
            text(line_pos{i}(1)+0.2,line_hight(i)+0.05,sprintf('bf10 = %s',num2str(bfs(i))))
            text(line_pos{i}(1)+0.2,line_hight(i)-0.05,sprintf('p = %s',num2str(ps(i))))
        end
    end
end %ivar



% Plot inhaltation exhalation ratio for each technique in plot 5
%calculate ratio for each technique and participant
axes(ax{3})
color_counter = 1;
if sum((sum(normal,'omitnan')))~=0
    norm_ratio = normal(:,2)./normal(:,3);
    LH_scatterbox(1,norm_ratio,'Color','k','alpha', transperency,'size', 5)
end
for itech = 1:length(techniques{2})
    for isubj = 1:size(combined{itech},1)
        %if insp. or exp. duration is not defined ratio can not be calculated
        if ~isnan(combined{itech}(isubj,2)) || ~isnan(combined{itech}(isubj,3))
            ratio{itech}(isubj,1) = combined{itech}(isubj,2)/combined{itech}(isubj,3);
        else
            ratio{itech}(isubj,1) = NaN;
        end
    end%isubj
    LH_scatterbox(itech+skip_plot,ratio{itech},'Color',color{color_counter},'alpha',transperency,'size',5)
    hold on
    color_counter = color_counter +1;
end%itech
%combine norm_ratio and ratio to facilitate ttest calculation
t_ratio = {norm_ratio,ratio{1},ratio{2}}

% Statistics (ttest and false discovery correction for p values)
line_pos = {[1,2],[2,3],[1,3]};
line_hight = [3, 3.5, 4]
for i = 1:3
    [bfs(i),ps(i)] = bf.ttest(t_ratio{line_pos{i}(1)},t_ratio{line_pos{i}(2)});
    Effect1_ratio{i} = meanEffectSize(t_ratio{line_pos{i}(1)},t_ratio{line_pos{i}(2)}, 'Effect','cohen','Paired',true);
end
%Correct pvalues of multiple t-test by controling for false discovery rate
[~, ~, ~, ps]=ck_stat_fdr(ps,0.05,'dep');
for i =1:3
    line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)],'Color','k')
    symbol = LH_check_significanz(ps(i))
    text(mean(line_pos{i}),line_hight(i)+0.12,symbol,'FontSize',12)
    if show_statistics == 1
        text(line_pos{i}(1)+0.2,line_hight(i)+0.1,sprintf('bf10 = %s',num2str(bfs(i))))
        text(line_pos{i}(1)+0.2,line_hight(i)-0.1,sprintf('p = %s',num2str(ps(i))))
    end
end



axes(ax{1})
%X-axis
axis = gca;
axis.XAxis.FontSize = 16;
axis.XAxis.FontWeight = 'bold';   % optional fett
xticks([1:3])
xticklabels({'normal', 'Slow', 'Fast'})
ylabel(y_labels{1}, 'FontSize',16,'FontWeight', 'bold')
set(breath, 'InvertHardcopy', 'off');

axes(ax{3})
%X-axis
axis = gca;
axis.XAxis.FontSize = 16;
axis.XAxis.FontWeight = 'bold';   % optional fett
xticks([1:3])
xticklabels([])
ylabel(y_labels{2},"FontSize",16, 'FontWeight', 'bold')
xlim([0,4.5])
set(breath, 'InvertHardcopy', 'off');



axes(ax{2})
%X-axis
axis = gca;
axis.XAxis.FontSize = 16;
axis.XAxis.FontWeight = 'bold';   % optional fett
xticks([1:3])
xticklabels(techniques{2})
ylabel(y_labels{1},'FontSize',16,'FontWeight', 'bold')
set(breath, 'InvertHardcopy', 'off');

axes(ax{4})
%X-axis
axis = gca;
axis.XAxis.FontSize = 16;
axis.XAxis.FontWeight = 'bold';   % optional fett
xticks([1:3])
xticklabels([])
ylabel(y_labels{2},'FontSize',16,'FontWeight', 'bold')
clim([0,4.5])

breath.Color = [1 1 1];
breath.Position = [20 20 1000 600];

%==========================================================================
%==========================================================================
%% figure 3 - Exemplary respiratory traces
% from three participants illustrating individual differences
% in respiration following one-minute of fast breathing practice

% Prepare figure
[ax,fig,one_plot] = LH_create_subplots(3,'columns');
hold on
win = [-1500,1500];
ax_main = axes('Position', [0.0500 0.1000 0.9000 0.8500], 'Color', 'none');
ax_main.XColor = 'none';
ax_main.YColor = 'none';
ax_main.XLim = ([0,(abs(win(1))+abs(win(2)))/100]);

% Extract data for figure from datas struct
After_sig = data.figure3.After_sig;
% Plot data
for i = 1:3
    axes(ax{i})
    plot(After_sig{i},'LineWidth',3,'Color', color{i}, 'LineStyle', '-')
    hold on

    % Figure Settings
    xlim([0,(abs(win(1))+win(2))])
    if i == 1
        xlabel('time in s','FontSize',12,'FontWeight','bold')
        xticks(0:500:(abs(win(1))+win(2)))
        xticklabels(0:5:(abs(win(1))+win(2))/100)
    else
        xticks([])
    end
    yticks([])
    ylabel('Z-score','FontSize',12,'FontWeight','bold')
end
% Draw vertical lines in figure to illustrate end of practice and beginning
% of task
xpos1 = abs(win(1))/100;
axes(ax_main)
line([xpos1,xpos1],[0,0.83],'Color','k', 'Linestyle','-.', 'LineWidth', 3);
text(ax_main,abs(win(1))/100,0.84, 'Trial start',...
    'HorizontalAlignment','center', 'VerticalAlignment','middle',...
    'FontSize',10,'FontWeight','bold')
xpos2 = abs(win(1))/100-2;
line([xpos2,xpos2],[0,0.85], 'Color','k', 'Linestyle','-.', 'LineWidth', 3);
text(ax_main,abs(win(1))/100-2,0.87, 'End of guidance',...
    'HorizontalAlignment','center', 'VerticalAlignment','middle',...
    'FontSize',10, 'FontWeight','bold')
uistack(ax_main,'top')

%==========================================================================
%==========================================================================
%% figure 4 -  Respiration characteristics in a period of one minute
% following the breathing practice

% Extract data from data struct
Resp_performance = data.figure4.Resp_performance;
% Set up colors and technique names
help_color = [{'k'},color];
help_tech = techniques;
help_tech{1} = [{'normal'},help_tech{1}{1},help_tech{1}{2}];

% plot undefined cycles after intervention
[comb_ax, comb_fig] = LH_create_subplots([3,3],'rows');
%[ax, Resp_perf] = LH_create_subplots(2,'rows');
for iexp = 1:size(Resp_performance.undefined_after,2)
    for isubj = 1:size(Resp_performance.undefined_after{iexp},2)
        if iexp == 1
            tmp = [Resp_performance.undefined_after{iexp}{isubj}];
            tmp(:,2) = tmp(:,2)+1;
            tmp_data = [tmp;[normal(isubj,5),1]];
        elseif iexp == 2
            tmp_data = Resp_performance.undefined_after{iexp}{isubj};
        end
        if ~isempty(tmp_data)
            techs = max(tmp_data(:,2));
            for itech = 1:techs
                new_data = tmp_data(:,2) == itech;
                mean_data{iexp}(isubj,itech) = mean(tmp_data(new_data,1));
            end %itech
        else
            mean_data{iexp}(isubj,:) = NaN;
        end %isempty
    end %isubj
end %iexp

positions = [4,1];
color_count = 1;
for iexp = 1:2
    axes(comb_ax{positions(iexp)})
    axis = gca;
    axis.XAxis.FontSize = 14;
    axis.XAxis.FontWeight = 'bold';   % optional fett
    techs = size(mean_data{iexp},2);
    for itech = 1:techs
        tmp_data = mean_data{iexp}(:,itech);
        LH_scatterbox(itech,tmp_data,'color',help_color{color_count})
        hold on
        color_count = color_count +1;
    end %itech
    xticks([1:size(help_tech{iexp},2)])
    xticklabels(help_tech{iexp})
    ylim([0,1.1])
    ylabel('atypical cyles', 'FontSize',14,'FontWeight','bold')

    line_pos = {[1,2],[2,3],[1,3]};
    line_hight = [0.8, 0.9, 1]
    for i = 1:3
        [bfs(i),ps(i)] = bf.ttest(mean_data{iexp}(:,line_pos{i}(1)),mean_data{iexp}(:,line_pos{i}(2)));
        Cohens_atypical_after{iexp}{i} = meanEffectSize(mean_data{iexp}(:,line_pos{i}(1)),mean_data{iexp}(:,line_pos{i}(2)), 'Effect','cohen','Paired',true);
    end
    %Correct pvalues of multiple t-test by controling for false discovery rate
    [~, ~, ~, ps]=ck_stat_fdr(ps,0.05,'dep');
    for i =1:3
        line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)],'Color', 'k')
        symbol = LH_check_significanz(ps(i));
        text(mean(line_pos{i}),line_hight(i)+0.025,symbol,'Fontsize', 12);
        if show_statistics == 1
            text(line_pos{i}(1)+0.2,line_hight(i)+0.03,sprintf('bf10 = %s',num2str(bfs(i))))
            text(line_pos{i}(1)+0.2,line_hight(i)-0.03,sprintf('p = %s',num2str(ps(i))))
        end
    end
    %     end
end%iexp


% Plot frequency after intervention
%[ax, Resp_frequ] = LH_create_subplots(2,'rows');
for iexp = 1:size(Resp_performance.frequ_after,2)
    for isubj = 1:size(Resp_performance.frequ_after{iexp},2)
        if ~isempty(Resp_performance.frequ_after{iexp}{isubj})
            if iexp == 1
                %add frequency of normal recording as condition 1
                %(therefore add 1 to all other conditions)
                tmp = Resp_performance.frequ_after{iexp}{isubj};
                tmp(:,2) = tmp(:,2)+1;
                tmp_data = [tmp;[normal(isubj,4),1]]
            elseif iexp == 2
                tmp_data = Resp_performance.frequ_after{iexp}{isubj};
            end
            if ~isempty(tmp_data)
                techs = max(tmp_data(:,2));
                %if there is more than one block per technique, take the
                %mean for each technique
                for itech = 1:techs
                    new_data = tmp_data(tmp_data(:,2) == itech,1);
                    mean_data{iexp}(isubj,itech) = mean(new_data);
                end %itech
            else
                mean_data{iexp}(isubj,:) = NaN;
            end %isempty
        end %isempty
    end %isubj
end %iexp

color_count = 1;
positions = [5,2];
for iexp = 1:2
    axes(comb_ax{positions(iexp)})
    axis = gca;
    axis.XAxis.FontSize = 14;
    axis.XAxis.FontWeight = 'bold';   % optional fett
    techs = size(mean_data{iexp},2);
    for itech = 1:techs
        tmp_data = mean_data{iexp}(:,itech);
        LH_scatterbox(itech,tmp_data,'color',help_color{color_count})
        hold on
        color_count = color_count +1;
    end %itech
    xticks([1:size(help_tech{iexp},2)])
    xticklabels(help_tech{iexp})
    ylim([0,1.1])
    ylabel('frequency', 'FontSize',14,'FontWeight','bold')

    line_pos = {[1,2],[2,3],[1,3]};
    line_hight = [0.8, 0.9, 1]
    for i = 1:3
        [bfs(i),ps(i)] = bf.ttest(mean_data{iexp}(:,line_pos{i}(1)),mean_data{iexp}(:,line_pos{i}(2)));
        Cohens_frequency_after{iexp}{i} = meanEffectSize(mean_data{iexp}(:,line_pos{i}(1)),mean_data{iexp}(:,line_pos{i}(2)), 'Effect','cohen','Paired',true);
    end
    %Correct pvalues of multiple t-test by controling for false discovery rate
    [~, ~, ~, ps]=ck_stat_fdr(ps,0.05,'dep');
    for i =1:3
        line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)],'Color', 'k')
        symbol = LH_check_significanz(ps(i));
        text(mean(line_pos{i}),line_hight(i)+0.025,symbol,'Fontsize', 12);
        if show_statistics == 1
            text(line_pos{i}(1)+0.2,line_hight(i)+0.03,sprintf('bf10 = %s',num2str(bfs(i))))
            text(line_pos{i}(1)+0.2,line_hight(i)-0.03,sprintf('p = %s',num2str(ps(i))))
        end
    end
    %end
end%iexp

% Plot ratio after intervention
%[ax, Resp_ratio] = LH_create_subplots(2,'rows');
for iexp = 1:size(Resp_performance.ratio_after,2)
    for isubj = 1:size(Resp_performance.ratio_after{iexp},2)
        if ~isempty(Resp_performance.ratio_after{iexp}{isubj})
            if iexp == 1
                %If experiment is 1 use ratio from normal recording to show
                %ration of normal respiration
                tmp = Resp_performance.ratio_after{iexp}{isubj};
                tmp(:,2) = tmp(:,2)+1;
                tmp_data = [tmp;[normal(isubj,2)/normal(isubj,3),1]];
            elseif iexp == 2
                tmp_data = Resp_performance.ratio_after{iexp}{isubj};
            end
            if ~isempty(tmp_data)
                techs = max(tmp_data(:,2));
                for itech = 1:techs
                    new_data = tmp_data(tmp_data(:,2) == itech);
                    mean_data{iexp}(isubj,itech) = mean(new_data);
                end %itech
            else
                mean_data{iexp}(isubj,:) = NaN;
            end %isempty
        end %isempty
    end %isubj
end %iexp

color_count = 1;
positions = [6,3]
for iexp = 1:2
    axes(comb_ax{positions(iexp)})
    axis = gca;
    axis.XAxis.FontSize = 14;
    axis.XAxis.FontWeight = 'bold';   % optional fett
    techs = size(mean_data{iexp},2);
    for itech = 1:techs
        tmp_data = mean_data{iexp}(:,itech);
        LH_scatterbox(itech,tmp_data,'color',help_color{color_count})
        hold on
        color_count = color_count +1;
    end %itech
    xticks([1:size(help_tech{iexp},2)])
    xticklabels(help_tech{iexp})
    ylim([0,3])
    ylabel('in/ex ratio','FontSize',14,'FontWeight','bold')

    line_pos = {[1,2],[2,3],[1,3]};
    line_hight = [2.3, 2.5, 2.7]
    for i = 1:3
        [bfs(i),ps(i)] = bf.ttest(mean_data{iexp}(:,line_pos{i}(1)),mean_data{iexp}(:,line_pos{i}(2)));
        Cohens_ratio_after{iexp}{i} = meanEffectSize(mean_data{iexp}(:,line_pos{i}(1)),mean_data{iexp}(:,line_pos{i}(2)), 'Effect','cohen','Paired',true);
    end
    %Correct pvalues of multiple t-test by controling for false discovery rate
    [~, ~, ~, ps]=ck_stat_fdr(ps,0.05,'dep');
    for i =1:3
        line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)],'Color', 'k')
        symbol = LH_check_significanz(ps(i));
        text(mean(line_pos{i}),line_hight(i)+0.07,symbol,'Fontsize', 12);
        if show_statistics == 1
            text(line_pos{i}(1)+0.2,line_hight(i)+0.06,sprintf('bf10 = %s',num2str(bfs(i))))
            text(line_pos{i}(1)+0.2,line_hight(i)-0.06,sprintf('p = %s',num2str(ps(i))))
        end
    end
end %iexp

%==========================================================================
%==========================================================================
%% figure 5 - 8 - Response and RT accuracy following breathing practice.
% Temporal dynamics of task accuracy (FCR) and RTs
% Get data for figures from data struct
% RTs are squareroot transformed and normalized by mean RT in Block 
% BinSize for RT_bin and FCRbin = 10;
RTs = data.figures5to8.RTs;
RT_bin = data.figures5to8.RT_bin;
FCR = data.figures5to8.FCR;
FCR_bin = data.figures5to8.FCR_bin;
%settings for plotting 
%Names fof techniques
techniques{1} = {'Slow', 'Fast'};
techniques{2} = {'NOI', 'SILE', 'LISE'};
% Initalize figures
[ax_RT,RT_fig] = LH_create_subplots(2,'rows');
[ax_FCR,FCR_fig] = LH_create_subplots(2,'rows');
[ax_bin,bin_fig] = LH_create_subplots([2,3],'columns');
[ax_FCR_bin,FCR_bin_fig] = LH_create_subplots([2,3],'columns');
figure_graphical = figure;
% Color counter
cc = 1;
% shift within figure 
shift_it = -0.3;

for iexp = 1:size(RTs,2)
    plot_count = 1;
    for itech = 1:size(RTs{iexp},2)
        % Plot RTs --------------------------------------------------------
        figure(RT_fig)
        axes(ax_RT{iexp})
        hold on 
        LH_scatterbox(plot_count,RTs{iexp}(:,itech),...
            'Color',color{cc},'Alpha',0.5)

        % Plot FCRs -------------------------------------------------------
        figure(FCR_fig)
        axes(ax_FCR{iexp})
        LH_scatterbox(plot_count,FCR{iexp}(:,itech),...
            'Color',color{cc},'Alpha', 0.5)

        % Plot Bin data 
        % Binned RTs ------------------------------------------------------
        figure(bin_fig)
        axes(ax_bin{cc});
        hold on
        %get data for experiment and technqiue
        bin_data = RT_bin{iexp,itech};

        for ibin = 1:size(bin_data,2)
        % get data for bin 
        plot_data = bin_data(:,ibin);
        % Create vector for x-position 
        xpos_box = ones(1,size(bin_data,1))*ibin;
        %boxplot
        bp = boxchart(xpos_box,plot_data);
        %boxplot settings
        bp.BoxFaceColor = color{cc};
        bp.BoxFaceAlpha = 0.5;
        bp.BoxEdgeColor = color{cc};
        bp.BoxWidth = 0.1;
        bp.MarkerColor = color{cc};
        bp.MarkerStyle = "none";
        
        % Connect bins with lines 
        if ibin>1
            line([ibin-1,ibin], ...
                [median(bin_data(:,ibin-1)),...
                median(bin_data(:,ibin))],...
                'Color', color{cc},'Linewidth',2);
        end %ibin>1
        end % ibin
        %figure settings
        xticks([1:size(RT_bin{iexp},2)])
        ylim([-0.2,0.3])
        ylabel('RT','FontSize',16,'FontWeight','bold')
        xlabel(sprintf('Trialbin ', num2str(Bins)),'FontSize',16,'FontWeight','bold')
        if itech>1
            xlabel([])
            xticks([])
        end
        text(1, 0.2, techniques{iexp}{itech},...
            'FontSize',16, 'FontWeight','bold')  % plot label

        %Permutation test for technique for binend RT ---------------------
        [percentile, original_slope, ~] = ...
            LH_linear_permutation(bin_data,2000);
        if show_statistics
            text(3,0.2,...
                ['percentile in permutation test =  ', num2str(percentile)])
            text(3,0.15,['original slope = ',...
                num2str(original_slope)])
        end % show statistics

        %Binned FCR -------------------------------------------------------
        figure(FCR_bin_fig)
        axes(ax_FCR_bin{cc});
        hold on
        FCR_bin_data = FCR_bin{iexp,itech};
        for ibin = 1:size(FCR_bin_data,2)
            tmp_data = FCR_bin_data(:,ibin);
            xpos_box = ones(1,size(FCR_bin_data,1))*ibin;
            %boxplot
            bp = boxchart(xpos_box,tmp_data);
            %boxplot settings
            bp.BoxFaceColor = color{cc};
            bp.BoxFaceAlpha = 0.5;
            bp.BoxEdgeColor = color{cc};
            bp.BoxWidth = 0.2;
            bp.MarkerColor = color{cc};
            bp.MarkerStyle = "none";
            hold on
            if ibin>1
                line([ibin-1,ibin], ...
                    [median(FCR_bin_data(:,ibin-1)),...
                    median(FCR_bin_data(:,ibin))],...
                    'Color', color{cc});
            end %ibin>1
        end %size(FCR_bin_data)

        %figure settings
        ylabel('FCR', 'FontSize',16,'FontWeight','bold')
        xlabel('Trialbin',"FontSize",16,"FontWeight",'bold')
        xticks([1:size(bin_data,2)])
        if itech > 1
            xlabel([])
            xticks([])
        end %keep xlabel only for the lower plots
        text(1,1.05,  techniques{iexp}{itech},...
            'FontSize',16,'FontWeight','bold'); % Plot label

        %Permutation test for technique for binend FCRs -------------------
        [percentile, original_slope, ~] = ...
            LH_linear_permutation(FCR_bin_data,2000);
        ylim([0.5,1.2])
        if show_statistics
            text(3,1.15,['percentile in permutation test =  ',...
                num2str(percentile)])
            text(3,1.1,['original slope = ', num2str(original_slope)])
        end %show statistics

       
        %increase counter
        plot_count = plot_count + 1;
        cc = cc + 1;
    end%itech
end%iexp

% Settings for FCR and RTs
for iexp = 1:2
    % Reaction time figure
    figure(RT_fig)
    axes(ax_RT{iexp})
    axis = gca;
    % To create figures for graphical abstract decomment follwoing line of
    % code 
    axis.Color = 'none';
    axis.XAxis.FontSize = 16;
    axis.XAxis.FontWeight = 'bold';   % optional fett
    xticks([1:size(RTs{iexp},2)])
    xticklabels(techniques{iexp})
    ylabel('RT','FontSize',16,'FontWeight','bold')
    ylim([-0.2,0.2])
    %% Statistics
    if iexp == 1
        [bf10,p1] = bf.ttest(RTs{1}(:,1),RTs{1}(:,2))
        Effect1RTs = meanEffectSize(RTs{1}(:,1),RTs{1}(:,2), 'Effect','cohen','Paired',true)
        line([1,2],[0.15,0.15],'Color','k')
        if show_statistics
            text(1.2,0.165,sprintf('bf10 = %s',num2str(bf10)))
            text(1.2,0.145,sprintf('p = %s',num2str(p1)))
        else
            symbol = LH_check_significanz(p1);
            text(1.2+0.2,0.15+0.005,symbol)
        end

    elseif iexp == 2
        line_pos = {[1,2],[2,3],[1,3]};
        line_hight = [0.15, 0.175, 0.2];
        for i = 1:3
            [bfs(i),ps(i)] = bf.ttest(RTs{2}(:,line_pos{i}(1)),RTs{2}(:,line_pos{i}(2)));
            Effect2RTs{i} = meanEffectSize(RTs{2}(:,line_pos{i}(1)),RTs{2}(:,line_pos{i}(2)), 'Effect','cohen','Paired',true)
        end
        %        Correct pvalues of multiple t-test by controling for false discovery rate
        [~, ~, ~, ps]=ck_stat_fdr(ps,0.05,'dep');
        if show_statistics
            for i =1:3
                line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)],'Color','k')
                text(line_pos{i}(1)+0.2,line_hight(i)+0.01,sprintf('bf10 = %s',num2str(bfs(i))))
                text(line_pos{i}(1)+0.2,line_hight(i)-0.01,sprintf('p = %s',num2str(ps(i))))
            end
        else
            for i =1:3
                symbol = LH_check_significanz(ps(i));
                line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)], 'Color', 'k')
                text(line_pos{i}(1)+0.4,line_hight(i)+0.005,symbol)

            end
        end %show_statistics
    end % experiment 1/2



    %FCR figure
    figure(FCR_fig)
    axes(ax_FCR{iexp})
    axis = gca;
    axis.XAxis.FontSize = 16;
    axis.XAxis.FontWeight = 'bold';   % optional fett
    xticks([1:size(RT_bin{iexp},2)])
    xticklabels(techniques{iexp})
    ylabel('FCR','FontSize',16,'FontWeight','bold')
    ylim([0.6,1.15])
    % Statistics
    if iexp == 1
        [bf10,p2] = bf.ttest(FCR{1}(:,1),FCR{1}(:,2))
        Effect1FCR = meanEffectSize(FCR{1}(:,1),FCR{1}(:,2), 'Effect','cohen','Paired',true);
        line([1,2],[1,1], 'Color','k')
        if show_statistics
            text(1.2,1.01,sprintf('bf10 = %s',num2str(bf10)))
            text(1.2,0.995,sprintf('p = %s',num2str(p2)))
        else
            symbol = LH_check_significanz(p2);
            text(1+0.4,1+0.0055,symbol)
        end
    elseif iexp == 2
        line_pos = {[1,2],[2,3],[1,3]};
        line_hight = [1, 1.05, 1.1]
        for i = 1:3
            [bfs(i),ps(i)] = bf.ttest(FCR{2}(:,line_pos{i}(1)),FCR{2}(:,line_pos{i}(2)));
            Effect2FCR{i} = meanEffectSize(FCR{2}(:,line_pos{i}(1)),FCR{2}(:,line_pos{i}(2)), 'Effect','cohen','Paired',true);
        end
%        Correct pvalues of multiple t-test by controling for false discovery rate
        [~, ~, ~, ps]=ck_stat_fdr(ps,0.05,'dep');
        % Plotting p calues and BF10 in the plot

        if show_statistics
            for i =1:3
                line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)],'Color', 'k')
                text(line_pos{i}(1)+0.2,line_hight(i)+0.01,sprintf('bf10 = %s',num2str(bfs(i))))
                text(line_pos{i}(1)+0.2,line_hight(i)-0.01,sprintf('p = %s',num2str(ps(i))))
            end
        else
            for i =1:3
                symbol = LH_check_significanz(ps(i));
                line([line_pos{i}(1),line_pos{i}(2)],[line_hight(i),line_hight(i)], 'Color', 'k')
                text(line_pos{i}(1)+0.4,line_hight(i)+0.006,symbol)
            end
        end

    end % i
end

% Compare slopes of techniques, to control whether NOI condition is
% different from respiration pratice conditions

%Therefor calculate the slope of a linear regession across all bins
% for each technique for each participant 
tech_count = 0;
for iexp = 1:size(RT_bin,1)
    for itech = 1:length(techniques{iexp})
        bin_data = RT_bin{iexp,itech};
        tech_count = tech_count + 1;
        for isubj = 1:size(bin_data,1)
            subj_data = bin_data(isubj,:);
            xaxis = 1:size(subj_data,2);
            [original_fit,S,mu] = polyfit(xaxis,subj_data,1);
            subj_slopes(isubj,tech_count) = original_fit(1);
        end %isubj
    end %itech
end %iexp

% Test for NOI vs. LISE or SILE 
%Experiment 2
slopes_Noi = subj_slopes((subj_slopes(:,3)~=0),3);
slopes_Sile = subj_slopes((subj_slopes(:,4)~=0),4);
slopes_Lise = subj_slopes((subj_slopes(:,5)~=0),5);
[slope_bf(1),slope_p(1)]= bf.ttest(slopes_Noi,slopes_Sile);
[slope_bf(2),slope_p(2)]= bf.ttest(slopes_Sile,slopes_Lise);  
[slope_bf(3),slope_p(3)]= bf.ttest(slopes_Noi,slopes_Lise);  
Cohens_slope{1} = meanEffectSize(slopes_Noi,slopes_Sile, 'Effect','cohen','Paired',true);
Cohens_slope{2} = meanEffectSize(slopes_Sile,slopes_Lise, 'Effect','cohen','Paired',true);
Cohens_slope{3} = meanEffectSize(slopes_Noi,slopes_Lise, 'Effect','cohen','Paired',true);
%Experiment 1
[slope_bf(4),slope_p(4)]= bf.ttest(subj_slopes(:,1), subj_slopes(:,2));
Cohens_slope{4} = meanEffectSize(subj_slopes(:,1), subj_slopes(:,2), 'Effect','cohen','Paired',true);
function [ax,fig,one_plot] = LH_create_subplots(columns, orientation, x_space, y_space, x_shift, y_shift)
%Function to create a pannel of subpplots
%to call a specific plot use axes(ax{plot_number})

% 'rows' (numeration of plots)
% eg. LH_create_subplot([3,3,2],'rows')
%
%   6   7   8
%   3   4   5    
%     1   2
%
% 'columns' (numeration of plots)
% eg. LH_create_subplot([3,1,3], 'columns')
%   3       7
%   2   4   6  
%   1       5

%Input: 
% coloumns: Array with the amount of subplots...
%'coloums': numbers in array are the numbers of plot in columns
%'rows': numbers in array are the numbers of plot in rows

%Output:
%ax = axes handels
%fig = figure handel

% Author: 
% Lena Hehemann 
% Universität Bielefeld,
% Dept. of Cognitive Science 
% Sept. 2026 


%% Manuel Settings
%Define [x_pos, y_pos, width, hight] to define the borders of your figure. 
% x_pos and y_pos defining the coordinates of the lower left corner of the
% lower left plot
% width and hight defining total width and hight of all plots the figure

%% Preallocating 
if nargin< 6
    y_shift = 0;
    if nargin < 5
        x_shift = 0;
        if nargin<4
            y_space = 0.05;
            warning('y_space is automatically set to 0.05')
            if nargin < 3
                x_space = 0.05;
                warning('x_space is automatically set to 0.05')
                if nargin < 2
                    orientation = 'rows';
                    warning('Orientation is automatically set to rows')
                end
            end
        end
    end
end

if isempty(y_space)
    y_space = 0.05;
end 

if isempty(x_space)
    x_space = 0.05;
end 

if isempty(x_shift)
    x_shift = 0;
end 

%define coordinates for one big plot which is used as basis to calculate
%the lower, upper, left and right boarders for subplots 


lower_left_corner = [0.05+x_shift,0.1+y_shift];
one_plot_width = 0.9-x_shift;
one_plot_hight = 0.85-y_shift;
one_plot = [lower_left_corner,one_plot_width,one_plot_hight];

%preallocate the output ax
ax = cell(1,sum(columns));

%% horizontal orientation
if strcmp(orientation,'rows')
%how many rows of plots will we have?
rows = length(columns);
%Total width of all plots
total_width = one_plot(3);
%Total hight of all plots
total_hight = one_plot(4);

%Calculate the hight for each plot
plot_hight = (total_hight-((rows-1)*y_space))/rows;
ax_counter = 1;
%Create and clear figure
fig = figure; clf
%For each row of plots
for irow = linspace(rows,1,rows)
    %Calculate width for each plot in the row
    plot_width = (total_width-(columns(irow)*x_space))/columns(irow);
    %for each plot in the row
    for iplot = 1:columns(irow)

        %for the first row of plots
        if irow == rows
            %plot the first plot in the lower left corner
            if  iplot==1
                x_cord = one_plot(1);
                y_cord = one_plot(2);
            else
                %shift all following plots one position to the right
                x_cord = x_cord+plot_width+x_space;
            end
        end
    
        %for all following rows of plots
        if irow<rows
            % for the first plot in the row
            if iplot == 1
               %Define coordinates 
               x_cord = one_plot(1);
               %shift y_coordinate to the next row
               y_cord = y_cord+plot_hight+y_space;
            else
               %for all other plots shift plot one position to the right  
               x_cord = x_cord+plot_width+x_space;
            
            end%irows 
        end%if plot

    %create axes and stor axes handels
    handel = axes('Position',[x_cord,y_cord,plot_width,plot_hight]);
    ax{ax_counter} = handel;
    ax_counter = ax_counter+1;

    end %iplot
end %irow

%% vertical orientation
elseif strcmp(orientation,'columns')
columns = flip(columns)
%how many colums of plots will we have?
co = length(columns);
%Total width of all plots
total_width = one_plot(3);
%Total hight of all plots
total_hight = one_plot(4);

%Calculate the hight for each plot
plot_width = (total_width-((co-1)*y_space))/co;
ax_counter = 1;
%Create and clear figure
fig = figure; clf
%For each row of plots
for ico = linspace(co,1,co)
    %Calculate width for each plot in the row
    plot_hight = (total_hight-(columns(ico)*y_space))/columns(ico);
    %for each plot in the row
    for iplot = 1:columns(ico)

        %for the first row of plots
        if ico == co
            %plot the first plot in the lower left corner
            if  iplot==1
                x_cord = one_plot(1);
                y_cord = one_plot(2);
            else
                %shift all following plots one position to the top
                y_cord = y_cord+plot_hight+y_space;
            end
        end
    
        %for all following co of plots
        if ico<co
            % for the first plot in the row
            if iplot == 1
               %Define coordinates 
               x_cord = x_cord+plot_width+x_space;
               %shift y_coordinate to the next row
               y_cord = one_plot(2);
            else
               %for all other plots shift plot one position to the right  
               y_cord = y_cord+plot_hight+x_space;
            
            end%irows 
        end%if plot

    %create axes and stor axes handels
    handel = axes('Position',[x_cord,y_cord,plot_width,plot_hight]);
    ax{ax_counter} = handel;
    ax_counter = ax_counter+1;

    end %iplot
end %irow

end %orientation 
end%function

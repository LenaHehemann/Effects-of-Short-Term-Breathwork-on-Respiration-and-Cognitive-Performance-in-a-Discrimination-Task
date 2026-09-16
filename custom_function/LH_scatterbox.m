% Function to create scatter an box plot at the same time S

% Author: 
% Lena Hehemann 
% Universität Bielefeld,
% Dept. of Cognitive Science 
% Sept. 2026 

function LH_scatterbox(xpos,data,varargin)

% Set default options
Size = 50;
transperency = 0.5;
color = 'k';
seperate_colors = false;
markerst = 'o';
show_scatter = true;
show_box = true;

%Loop through input and define which input was given;
% If no Input was given for one of the variables default values from above
% will be used 
for k = 1:2:length(varargin)
    name = varargin{k};
    value = varargin{k+1};
    switch lower(name)
        case 'color'
            color = value;
        case 'alpha'
            transperency = value;
        case 'size'
            Size = value;
        case 'scatter_colors'
            scatter_color = value;
            seperate_colors = true; 
        case 'markerstyle'
            markerst = value; 
        case 'scatter'
            show_scatter = value;
        case 'box'
            show_box = value; 
        otherwise
            error(['Unknowen parameter: ', name])
    end %switch
end %k

%get the current axes of the actual figure
gca
hold on
%scatter individual data points  
if show_scatter
if seperate_colors
    for isubj = 1:length(data)
    scatter(xpos-0.2,data(isubj),...
                Size,...
                'Marker',markerst,...
                'MarkerFaceColor',scatter_color(isubj,:),...
                'MarkerEdgeColor', scatter_color(isubj,:),...
                'MarkerFaceAlpha',transperency,...
                'MarkerEdgeAlpha', transperency);
            hold on
    end 
else
scatter(xpos-0.2,data,...
                Size,...
                'Marker',markerst,...
                'MarkerFaceColor',color,...
                'MarkerEdgeColor', color,...
                'MarkerFaceAlpha',transperency,...
                'MarkerEdgeAlpha', transperency)
            hold on
end 
end %if show_scatter

if show_box
            %To plot a boxplot with boxchart we need a vector in the length of the
            %data containing the x-position
            xpos_box = ones(1,length(data))*xpos+0.2;
            %boxplot 
            bp = boxchart(xpos_box,data);
            %boxplot settings
            bp.BoxFaceColor = color;
            bp.BoxFaceAlpha = transperency;
            bp.BoxEdgeColor = color;
            bp.BoxWidth = 0.2;
            bp.MarkerColor = color;
            bp.MarkerStyle = "none";
end %if show_box 

%scatter group mean in boxplot box
% group_mean = mean(data,'omitnan');
% scat1 = scatter(xpos+0.2,group_mean,Size,'*','filled');
group_median = median(data,'omitnan');
scat1.MarkerFaceColor = [255 255 255]/255;
scat1.MarkerEdgeColor = [255 255 255]/255;

scat1.LineWidth = 2;


end 
function [] = LHerrorshade(tax,M,SEM,color)

% Error-bar lines with shaded background
% transformed form ckerrorshade: 22.07.2025S

% Author: 
% Lena Hehemann 
% Universität Bielefeld,
% Dept. of Cognitive Science 
% Sept. 2026 S


% if user has not defined a color use standard colors
if  nargin<4 || isempty(color) 
    color = [250,180,0]/250; %
end

h = fill([tax(1:end) tax(end:-1:1)],[M-SEM M(:,[end:-1:1])+SEM(:,[end:-1:1])],color,'FaceAlpha',0.5);
set(h,'EdgeColor',color)
hold on

h =  plot(tax,M,'Color',color);
set(h,'LineWidth',2)

end
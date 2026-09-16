% Author: 
% Lena Hehemann 
% Universität Bielefeld,
% Dept. of Cognitive Science 
% Sept. 2026 

function symbol = LH_check_significanz(p)

if p > 0.05
    symbol = 'n.s.';
elseif p <= 0.05 && p > 0.01
    symbol = '*';
elseif p<=0.01 && p > 0.001
    symbol = '**';
elseif p<=0.001
    symbol = '***';
end 
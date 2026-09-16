% function to perform a permutation test for a linear 
% Returns a value representing the percentile in which the slope of the
% original data lies (percentile)
% distribution: distribution of random generated slopes 

% Author: 
% Lena Hehemann 
% Universität Bielefeld,
% Dept. of Cognitive Science 
% Sept. 2026 


function [percentile, original_slope, random_slopes] = LH_linear_permutation(data,permutations)

if nargin<2
    permutations = 1000;
end 

mean_data = mean(data,"omitnan");
xaxis = [1:size(data,2)];
[original_fit,S,mu] = polyfit(xaxis,mean_data,1);
original_slope = original_fit(1);

for i = 1:permutations
shuffeled_data  = LH_shuffle_data(data);
shuffle_mean = mean(shuffeled_data,'omitnan');
[shuffle_fit,S,mu] = polyfit(xaxis,shuffle_mean,1);
random_slopes(i) = shuffle_fit(1);
end

mu = mean(random_slopes);
sigma = std(random_slopes);
percentile = normcdf(original_slope, mu, sigma) * 100;



close all; clear all;

all_info_data = csvread('data/info_T800.csv');

b = getOneSourceSinkInfo('data/info_T800.csv',9,22);

%delay = 40
c = b(4,:);

%
time = c(4:3:end)
dist = c(5:3:end)
fuel = c(6:3:end)

time_perc = (time - time(1))*100/time(1)
dist_perc = (dist - dist(3))*100/dist(3)
fuel_perc = (fuel - fuel(5))*100/fuel(5)
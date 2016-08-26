clear all; close all;

%heavy_truck
%very bad coding for adv_no_gui.
% Every varable in the base workspace will be cleared
% after excuting adv_no_gui function!!!
% So we should execute it first
input.init.saved_veh_file='HeavyTruck_in';
[a,b]=adv_no_gui('initialize',input);

veh_file = 'HeavyTruck_in';
grade_my = 0;
%speed_my = 30;
time_my = 60*60; %30 min
data_file = 'data.csv';
for speed_my = 30:10:50
    collectData(veh_file, grade_my, speed_my, time_my, data_file)
    %first save every paramters and then clear all paramters and then load
    %all paramters
    save parameters.mat
    clear all; 
    load parameters.mat
end
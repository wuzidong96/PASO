clear all; close all;

%heavy_truck
%very bad coding for adv_no_gui.
% Every varable in the base workspace will be cleared
% after excuting adv_no_gui function!!!
% So we should execute it first
input.init.saved_veh_file='HeavyTruck_in_ldeng';
[a,b]=adv_no_gui('initialize',input);
tic;
veh_file = 'HeavyTruck_in_ldeng';
%grade_my = 0;
%speed_my = 30;
time_my = 30*60; %60 min, ADVISOR unit seconds 
data_file = 'data_dlll.csv';
cyc_file = 'CYC_MY.m';
for grade_my = 0:0.001:0
    for speed_my = 50:1:50
        collectData(veh_file, grade_my, speed_my, time_my, data_file, cyc_file)
        %first save every paramters and then clear all paramters and then load
        %all paramters
        save parameters.mat
        clear all;
        load parameters.mat
        speed_my
        gal(end)
        brake_loss_kj/1000
        total_energy_in_kj/1000
        brake_loss_kj/total_energy_in_kj
    end
end
toc
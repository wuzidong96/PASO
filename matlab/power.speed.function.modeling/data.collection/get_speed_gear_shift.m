clear all; close all;

%get the gear shift according to the speed
%tx_spd_dep_upshift, and
%tx_spd_dep_dnshift

% a two column matrix with speed (m/s) in the first column
% and gear number in the second column.
% This matrix is used as a lookup table for gear duing upshifting.
% Note: the information should be presented as a step-function (e.g., [0 1; 10 1; 10 2; 20 2])

%heavy_truck
%very bad coding for adv_no_gui.
% Every varable in the base workspace will be cleared
% after excuting adv_no_gui function!!!
% So we should execute it first
input.init.saved_veh_file='HeavyTruck_in';
[a,b]=adv_no_gui('initialize',input);
tic;
veh_file = 'HeavyTruck_in';
%grade_my = 0;
%speed_my = 30;
time_my = 30*60; %60 min, ADVISOR unit seconds
data_file = 'data_dlll.csv';
cyc_file = 'CYC_MY.m';
for grade_my = 2:0.001:2
    for speed_my = 70:1:70
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


figure;
font_size = 22.4;
line_width = 2;
set(gca,'FontSize',font_size);
hold on;
h=plot(tx_spd_dep_upshift(:,1)*2.23694,  tx_spd_dep_upshift(:,2), '-r');
set(h,'linewidth', line_width);
hold off;
xlabel('speed (mph)','FontSize', font_size, 'FontName', 'Arial');
ylabel('gear number','FontSize', font_size, 'FontName', 'Arial');
title('tx-spd-dep-upshift','FontSize', font_size, 'FontName', 'Arial');
box on;
grid on;
%export_fig('fig/power_speed_fit_grade_zero', '-pdf','-transparent','-nocrop');
export_fig('fig/speed_gear_number', '-pdf','-transparent','-nocrop');
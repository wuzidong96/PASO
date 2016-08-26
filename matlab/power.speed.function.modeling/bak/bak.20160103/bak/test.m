clear all; close all; clc;

%input.init.saved_veh_file='CONVENTIONAL_defaults_in';

%heavy_truck
input.init.saved_veh_file='HeavyTruck_in';
[a,b]=adv_no_gui('initialize',input);


T = 30*60; %30 minuts;
speed = 30; % 30 mph
cyc_mph = zeros(T,2);
cyc_mph(:,1) = 1:T;
cyc_mph(:,2) = speed;
cyc_grade = 0;
generateCycleFile(cyc_mph, cyc_grade, 'CYC_MY.m');
clear T;
clear speed;
clear cyc_mph;
clear cyc_grade;

input.cycle.param={'cycle.name'};
input.cycle.value={'CYC_MY'};

[a,b]=adv_no_gui('drive_cycle',input);
mpg = b.cycle.mpgge;



gal(end)


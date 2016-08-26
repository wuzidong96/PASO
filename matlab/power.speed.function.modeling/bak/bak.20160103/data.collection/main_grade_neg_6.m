clear all; close all;

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
time_my = 2*60*60; %2 hour, ADVISOR unit seconds

%grade_level: -9, -8, -7, -6, -5, -4, -3, -2, -1, -0, +0, +1, +2, +3, +4,
%+5, +6, +7, +8, +9
grade_level='neg_6';
[~, host_name] = system('hostname');
% remove trailing newline or null characters
host_name = host_name(host_name ~= 10);

data_file = sprintf('data_grade_%s_%s.csv', grade_level, host_name);
cyc_file = sprintf('CYC_MY_grade_%s_%s.m', grade_level, host_name);

if(strcmp(grade_level, 'neg_9'))
    grade_my_lb = -10;
    grade_my_ub = -9;
elseif(strcmp(grade_level, 'neg_8'))
    grade_my_lb = -8.9;
    grade_my_ub = -8;
elseif(strcmp(grade_level, 'neg_7'))
    grade_my_lb = -7.9;
    grade_my_ub = -7;
elseif(strcmp(grade_level, 'neg_6'))
    grade_my_lb = -6.9;
    grade_my_ub = -6;
elseif(strcmp(grade_level, 'neg_5'))
    grade_my_lb = -5.9;
    grade_my_ub = -5;
elseif(strcmp(grade_level, 'neg_4'))
    grade_my_lb = -4.9;
    grade_my_ub = -4;
elseif(strcmp(grade_level, 'neg_3'))
    grade_my_lb = -3.9;
    grade_my_ub = -3;
elseif(strcmp(grade_level, 'neg_2'))
    grade_my_lb = -2.9;
    grade_my_ub = -2;
elseif(strcmp(grade_level, 'neg_1'))
    grade_my_lb = -1.9;
    grade_my_ub = -1;
elseif(strcmp(grade_level, 'neg_0'))
    grade_my_lb = -0.9;
    grade_my_ub = -0;
elseif(strcmp(grade_level, 'pos_0'))
    grade_my_lb = 0.1;
    grade_my_ub = 0.9;
elseif(strcmp(grade_level, 'pos_1'))
    grade_my_lb = 1;
    grade_my_ub = 1.9;
elseif(strcmp(grade_level, 'pos_2'))
    grade_my_lb = 2;
    grade_my_ub = 2.9;
elseif(strcmp(grade_level, 'pos_3'))
    grade_my_lb = 3;
    grade_my_ub = 3.9;
elseif(strcmp(grade_level, 'pos_4'))
    grade_my_lb = 4;
    grade_my_ub = 4.9;
elseif(strcmp(grade_level, 'pos_5'))
    grade_my_lb = 5;
    grade_my_ub = 5.9;
elseif(strcmp(grade_level, 'pos_6'))
    grade_my_lb = 6;
    grade_my_ub = 6.9;
elseif(strcmp(grade_level, 'pos_7'))
    grade_my_lb = 7;
    grade_my_ub = 7.9;
elseif(strcmp(grade_level, 'pos_8'))
    grade_my_lb = 8;
    grade_my_ub = 8.9;
elseif(strcmp(grade_level, 'pos_9'))
    grade_my_lb = 9;
    grade_my_ub = 10;
else
    error('wrong grade level');
end

data_file
cyc_file
grade_my_lb
grade_my_ub

%grade_my is in units of percentage, change it to double when calling collectData function
for grade_my = grade_my_lb:0.1:grade_my_ub
    for speed_my = 10:1:100 %units: mph
        collectData(veh_file, grade_my/100, speed_my, time_my, data_file, cyc_file)
        %first save every paramters and then clear all paramters and then load
        %all paramters
        save(sprintf('parameters_grade_%s_%s.mat', grade_level, host_name));
        clear all;
        grade_level='neg_6';
        [~, host_name] = system('hostname');
        % remove trailing newline or null characters
        host_name = host_name(host_name ~= 10);
        load(sprintf('parameters_grade_%s_%s.mat', grade_level, host_name));
    end
end
toc

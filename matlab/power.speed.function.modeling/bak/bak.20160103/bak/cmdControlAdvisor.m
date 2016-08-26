clear all; close all; clc;

%input.init.saved_veh_file='CONVENTIONAL_defaults_in';
input.init.saved_veh_file='HeavyTruck_in';
[a,b]=adv_no_gui('initialize',input);


cyc_grade_vec = -0.2:0.1:0.2;
n_cyc_grade_vec = length(cyc_grade_vec);
Rec_mpg = zeros(n_cyc_grade_vec,1);

for nn=1:n_cyc_grade_vec
    T = 30*60; %30 minuts;
    speed = 30; % 30 mph
    cyc_mph = zeros(T,2);
    cyc_mph(:,1) = 1:T;
    cyc_mph(:,2) = speed;
    cyc_grade = cyc_grade_vec(nn);
    generateCycleFile(cyc_mph, cyc_grade, 'CYC_MY.m');
    clear T;
    clear speed;
    clear cyc_mph;
    clear cyc_grade;

    input.cycle.param={'cycle.name'};
    input.cycle.value={'CYC_MY'};
    
    [a,b]=adv_no_gui('drive_cycle',input); 
    Rec_mpg(nn,1) = b.cycle.mpgge;
    
    input.resp.param={'cyc_mph_r','distance','elevation','mpha'};
    [a, b] = adv_no_gui('other_info', input);
    b
    plot(0:1800, b.other.value{1}, '-ro', 0:1800, b.other.value{4}, '-bx')
    %remeber to clear a and b,  otherwise, something wrong
    %happens.
    clear a;
    clear b;
end

plot(cyc_grade_vec, Rec_mpg, '-bo');
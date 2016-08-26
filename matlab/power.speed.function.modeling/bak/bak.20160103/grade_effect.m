clear all; close all; clc;

%input.init.saved_veh_file='CONVENTIONAL_defaults_in';

%heavy_truck
input.init.saved_veh_file='HeavyTruck_in';
[a,b]=adv_no_gui('initialize',input);

cyc_grade_vec = -0.5:0.01:0.5;
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
  
    
    input.resp.param={'t', 'cyc_mph_r','mpha','distance','elevation', 'gal'};
    [a, b] = adv_no_gui('other_info', input);
    
    
    %plot some figures
    
    figure;
    font_size = 22.4;
    line_width = 5;
    set(gca,'FontSize',font_size);
    hold on;
    plot(t,  cyc_mph_r, '-r', 'Linewidth', line_width);
    plot(t,  mpha, '-b', 'Linewidth', line_width);
    hold off;
    xlabel('t','FontSize', font_size, 'FontName', 'Arial');
    ylabel('mph','FontSize', font_size, 'FontName', 'Arial');
    legend('cyc-mph-r','mpha','Location','Northeast');
    box on;
    grid on;
    export_fig(sprintf('fig/grade_effect/grade_effect_mph_grade=%.2f', cyc_grade_vec(nn)), '-pdf','-transparent','-nocrop');
    
    figure;
    font_size = 22.4;
    line_width = 5;
    set(gca,'FontSize',font_size);
    hold on;
    plot(distance, elevation, '-r', 'Linewidth', line_width);
    hold off;
    xlabel('distance','FontSize', font_size, 'FontName', 'Arial');
    ylabel('elevation','FontSize', font_size, 'FontName', 'Arial');
    box on;
    grid on;
    export_fig(sprintf('fig/grade_effect/grade_effect_distance_elevation_grade=%.2f', cyc_grade_vec(nn)), '-pdf','-transparent','-nocrop');
    
    figure;
    font_size = 22.4;
    line_width = 5;
    set(gca,'FontSize',font_size);
    hold on;
    plot(t, gal, '-r', 'Linewidth', line_width);
    hold off;
    xlabel('t','FontSize', font_size, 'FontName', 'Arial');
    ylabel('gal-cum','FontSize', font_size, 'FontName', 'Arial');
    box on;
    grid on;
    export_fig(sprintf('fig/grade_effect/grade_effect_gal_grade=%.2f', cyc_grade_vec(nn)), '-pdf','-transparent','-nocrop');    
    
    
    %remeber to clear a and b,  otherwise, something wrong happens.
    clear a;
    clear b;
end


figure;
font_size = 22.4;
line_width = 5;
set(gca,'FontSize',font_size);
hold on;
plot(cyc_grade_vec, Rec_mpg, '-bo','Linewidth', line_width);
hold off;
xlabel('grade','FontSize', font_size, 'FontName', 'Arial');
ylabel('mpg','FontSize', font_size, 'FontName', 'Arial');
box on;
grid on;
export_fig('fig/grade_effect/grade_effect_mpg_vs_grade', '-pdf','-transparent','-nocrop');

save grade_effect_2015_11_22.mat;

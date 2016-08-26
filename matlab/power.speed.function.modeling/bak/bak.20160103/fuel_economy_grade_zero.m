clear all; close all; clc;

%input.init.saved_veh_file='CONVENTIONAL_defaults_in';

%heavy_truck
input.init.saved_veh_file='HeavyTruck_in';
[a,b]=adv_no_gui('initialize',input);

cyc_mph_vec = 0:1:100;
n_cyc_mph_vec = length(cyc_mph_vec);
Rec_mpg = zeros(n_cyc_mph_vec,1);

for nn=1:n_cyc_mph_vec
    T = 30*60; %30 minuts;
    speed = cyc_mph_vec(nn); %units: mph
    cyc_mph = zeros(T,2);
    cyc_mph(:,1) = 1:T;
    cyc_mph(:,2) = speed;
    cyc_grade = 0; % no grade
    generateCycleFile(cyc_mph, cyc_grade, 'CYC_MY.m');
    clear T;
    clear speed;
    clear cyc_mph;
    clear cyc_grade;
    
    input.cycle.param={'cycle.name'};
    input.cycle.value={'CYC_MY'};
    
    [a,b]=adv_no_gui('drive_cycle',input);
    Rec_mpg(nn,1) = b.cycle.mpgge;
  
    
    input.resp.param={'t', 'cyc_mph_r','mpha','distance', 'gal'};
    [a, b] = adv_no_gui('other_info', input);
    
    
    %plot some figures
    
    figure;
    font_size = 22.4;
    line_width = 2;
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
    export_fig(sprintf('fig/fuel_economy/fuel_economy_mph_mph=%.2f', cyc_mph_vec(nn)), '-pdf','-transparent','-nocrop');
    
    figure;
    font_size = 22.4;
    line_width = 2;
    set(gca,'FontSize',font_size);
    hold on;
    plot(t, distance, '-r', 'Linewidth', line_width);
    hold off;
    xlabel('t','FontSize', font_size, 'FontName', 'Arial');
    ylabel('distance','FontSize', font_size, 'FontName', 'Arial');
    box on;
    grid on;
    export_fig(sprintf('fig/fuel_economy/fuel_economy_distance_mph=%.2f', cyc_mph_vec(nn)), '-pdf','-transparent','-nocrop');
    
    figure;
    font_size = 22.4;
    line_width = 2;
    set(gca,'FontSize',font_size);
    hold on;
    plot(t, gal, '-r', 'Linewidth', line_width);
    hold off;
    xlabel('t','FontSize', font_size, 'FontName', 'Arial');
    ylabel('gal-cum','FontSize', font_size, 'FontName', 'Arial');
    box on;
    grid on;
    export_fig(sprintf('fig/fuel_economy/fuel_economy_gal_mph=%.2f', cyc_mph_vec(nn)), '-pdf','-transparent','-nocrop');    
    
    
    %remeber to clear a and b,  otherwise, something wrong happens.
    clear a;
    clear b;
    %close all figures
    close all;
end


figure;
font_size = 22.4;
line_width = 2;
set(gca,'FontSize',font_size);
hold on;
plot(cyc_mph_vec, Rec_mpg, '-bo','Linewidth', line_width);
hold off;
xlabel('mph','FontSize', font_size, 'FontName', 'Arial');
ylabel('mpg','FontSize', font_size, 'FontName', 'Arial');
box on;
grid on;
export_fig('fig/fuel_economy/fuel_economy_mpg_vs_mph', '-pdf','-transparent','-nocrop');


figure;
Rec_gpm = 1./Rec_mpg; %gallon per mile
font_size = 22.4;
line_width = 2;
set(gca,'FontSize',font_size);
hold on;
plot(cyc_mph_vec, Rec_gpm, '-bo','Linewidth', line_width);
hold off;
xlabel('mph','FontSize', font_size, 'FontName', 'Arial');
ylabel('gpm','FontSize', font_size, 'FontName', 'Arial');
box on;
grid on;
export_fig('fig/fuel_economy/fuel_economy_gpm_vs_mph', '-pdf','-transparent','-nocrop');

%fuel-rate function v.s. speed, fuel-rate is in units of gallon per hour
Rec_gph = cyc_mph_vec'./Rec_mpg;
figure;
font_size = 22.4;
line_width = 2;
set(gca,'FontSize',font_size);
hold on;
plot(cyc_mph_vec, Rec_gph, '-bo','Linewidth', line_width);
hold off;
xlabel('mph','FontSize', font_size, 'FontName', 'Arial');
ylabel('gph','FontSize', font_size, 'FontName', 'Arial');
box on;
grid on;
export_fig('fig/fuel_economy/fuel_economy_gph_vs_mph', '-pdf','-transparent','-nocrop');


save('fig/fuel_economy/fuel_economy_2015_11_23.mat');

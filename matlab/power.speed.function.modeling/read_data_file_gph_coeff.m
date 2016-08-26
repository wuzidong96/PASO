clear all; close all;

%
% data_grade_neg_0_cic21.csv
% data_grade_neg_1_cic13.csv
% data_grade_neg_2_cic12.csv
% data_grade_neg_3_cic7.csv
% data_grade_neg_4_cic6.csv
% data_grade_neg_5_cic5.csv
% data_grade_neg_6_cic4.csv
% data_grade_neg_7_cic3.csv
% data_grade_neg_8_cic2.csv
% data_grade_neg_9_cic1.csv
% data_grade_pos_0_cic27.csv
% data_grade_pos_1_cic29.csv
% data_grade_pos_2_cic30.csv
% data_grade_pos_3_cic31.csv
% data_grade_pos_4_cic32.csv
% data_grade_pos_5_cic33.csv
% data_grade_pos_6_cic38.csv
% data_grade_pos_7_cic39.csv
% data_grade_pos_8_cic39.csv
% data_grade_pos_9_cic39.csv

%Each record contains 12 columns,  e.g.
% HeavyTruck_in,0.001000,30.000000,7200.000000,59.963482,8.690104,7.586282,3.450102,59.894789,8.742450,7.631980,3.431711
%
% 1 veh_file
% 2 grade  (float value, e.g., 0.001000 = 0.1% grade)
% 3 speed  (mph)
% 4 time   (seconds)
% 5 dist   (miles)
% 6 mpg    (miles per gallon)
% 7 mpgge  (miles per gallon gasoline equivalent)
% 8 gph    (gallon per hour)
% 9 dist_c  (miles, during constant speed intervals, ignoring accelerating process)
% 10 mpg_c  (miles per gallon, during constant speed intervals, ignoring accelerating process)
% 11 mpgge_c (miles per gallon gasoline equivalent, during constant speed intervals, ignoring accelerating process)
% 12 gph_c (gallon per hour, during constant speed intervals, ignoring accelerating process)



data_file = 'data_file/data_all_20151208.csv';
fid = fopen(data_file);
if(fid == -1)
    error('cannot open data file');
end
%data_vec_org is a 1x12 cell
data_vec_org = textscan(fid, '%s %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter',',');
fclose(fid);


coef_file = 'coef_file_gph.txt';
fid = fopen(coef_file, 'w');

%get the individual parameters
grade_vec_org = data_vec_org{2};
speed_vec_org = data_vec_org{3};
time_vec_org = data_vec_org{4};
dist_vec_org = data_vec_org{5};
mpg_vec_org = data_vec_org{6};
mpgge_vec_org = data_vec_org{7};
gph_vec_org = data_vec_org{8};
dist_c_vec_org = data_vec_org{9};
mpg_c_vec_org = data_vec_org{10};
mpgge_c_vec_org = data_vec_org{11};
gph_c_vec_org = data_vec_org{12};

grade_level_vec = -9:0.1:9;
n_grade_level = length(grade_level_vec);
coefa = zeros(size(grade_level_vec));
coefb = zeros(size(grade_level_vec));
coefc = zeros(size(grade_level_vec));
coefd = zeros(size(grade_level_vec));

%we only fit the data for the speed in the range [min_speed, max_speed]
min_speed = 30;
max_speed = 70;
grade_1 = -2;
grade_2 = 0;
grade_3 = 2;
fitpoly3_grade_1 = [];
fitpoly3_grade_2 = [];
fitpoly3_grade_3 =[];
speed_vec_grade_1 = [];
speed_vec_grade_2 = [];
speed_vec_grade_3 = [];
gph_c_vec_grade_1 = [];
gph_c_vec_grade_2 = [];
gph_c_vec_grade_3 = [];

for nn=1:n_grade_level
    grade_level = grade_level_vec(nn);
    
    if(grade_level < -2.6)
        min_speed = 30;
        max_speed = 60;
    else
        min_speed = 10;
        max_speed = 70;
    end
    
    idx_vec = [ (abs(grade_vec_org - grade_level/100) < 1e-10) ...
        & dist_c_vec_org >= 1e-10 ...
        & speed_vec_org >= min_speed - 1e-10 ...
        & speed_vec_org <= max_speed + 1e-10];
    
    if(sum(idx_vec) < 4)
        disp('we get less than 4 points, cannot fit');
        continue;
    end
    
    grade_vec = grade_vec_org(idx_vec);
    speed_vec = speed_vec_org(idx_vec);
    time_vec = time_vec_org(idx_vec);
    dist_vec = dist_vec_org(idx_vec);
    mpg_vec = mpg_vec_org(idx_vec);
    mpgge_vec = mpgge_vec_org(idx_vec);
    gph_vec = gph_vec_org(idx_vec);
    dist_c_vec = dist_c_vec_org(idx_vec);
    mpg_c_vec = mpg_c_vec_org(idx_vec);
    mpgge_c_vec = mpgge_c_vec_org(idx_vec);
    gph_c_vec = gph_c_vec_org(idx_vec);
    
    
    %scale to gallon per mile
    gpm_c_vec = 1./mpg_c_vec;
    %scale to gallon per 100 miles
    gp100m_c_vec = gpm_c_vec*100;
    
    %fit model
    [fitpoly3, gof] = fit(speed_vec,gph_c_vec,'poly3');
    coefa(nn) = fitpoly3.p1;
    coefb(nn) = fitpoly3.p2;
    coefc(nn) = fitpoly3.p3;
    coefd(nn) = fitpoly3.p4;
    fprintf(fid, '%.1f %e %e %e %e\n', grade_level, coefa(nn), coefb(nn), coefc(nn), coefd(nn));


    if ( abs(grade_level - grade_1 ) <= 1e-10)
        fitpoly3_grade_1 = fitpoly3;
        speed_vec_grade_1 = speed_vec;
        gph_c_vec_grade_1 = gph_c_vec;
       % h1=plot(fitpoly3, '-r', speed_vec, gph_c_vec, 'r+');
       % set(h1,'linewidth', line_width);
       % legend('data (-2%)','fitted curve (-2%)','Location','northwest');
    end
    if (abs(grade_level - grade_2) <= 1e-10)
        fitpoly3_grade_2 = fitpoly3;
        speed_vec_grade_2 = speed_vec;
        gph_c_vec_grade_2 = gph_c_vec;
      %  h2=plot(fitpoly3, '-b', speed_vec, gph_c_vec, 'b+');
      %  set(h2,'linewidth', line_width);
      %  legend('data (0%)','fitted curve (0%)','Location','northwest');
    end
    if (abs(grade_level - grade_3) <= 1e-10)
        fitpoly3_grade_3 = fitpoly3;
        speed_vec_grade_3 = speed_vec;
        gph_c_vec_grade_3 = gph_c_vec;
       % h3=plot(fitpoly3, '-g', speed_vec, gph_c_vec, 'g+');
       % set(h3,'linewidth', line_width);
       %  legend('data (2%)','fitted curve (2%)','Location','northwest');
    end
    
    %fuel economy
    %     figure;
    %     font_size = 22.4;
    %     line_width = 2;
    %     set(gca,'FontSize',font_size);
    %     hold on;
    %     % plot(speed_vec, gph_c_vec, '-r', 'Linewidth', line_width);
    %     plot(speed_vec, mpg_c_vec, '-b', 'Linewidth', line_width);
    %     % plot(speed_vec, gp100m_c_vec, '-g', 'Linewidth', line_width);
    %     hold off;
    %     xlabel('speed (mph)','FontSize', font_size, 'FontName', 'Arial');
    %    % legend('gph','mpg','gp100m','Location','north');
    %     legend('mpg','Location','north');
    %     %ylim([0,22]);
    %     box on;
    %     grid on;
    %     export_fig(sprintf('fig/fuel_economy_grade_%d', grade_level), '-pdf','-transparent','-nocrop');
    %
    %     %evaluate c_e(t_e) function, where we suppose D_e = 100 miles
    %     te = 100./speed_vec;
    %     ce = te.*gph_c_vec;
    %
    %     figure;
    %     font_size = 22.4;
    %     line_width = 2;
    %     set(gca,'FontSize',font_size);
    %     hold on;
    %     plot(te, ce, '-r', 'Linewidth', line_width);
    %     hold off;
    %     xlabel('Travel time (h)','FontSize', font_size, 'FontName', 'Arial');
    %     ylabel('Fuel consumed (gallon)','FontSize', font_size, 'FontName', 'Arial');
    %     box on;
    %     grid on;
    %     export_fig(sprintf('fig/fuel_consumed_grade_%d_100_miles', grade_level), '-pdf','-transparent','-nocrop');
    
    
    %     figure
    %     line_width = 2;
    %     font_size = 12;
    %     [ax, p1, p2] = plotyy(te,ce,te,100./te);
    %     set(p1, 'Linewidth', line_width);
    %     set(p1, 'Color', 'r');
    %     set(p2, 'Linewidth', line_width);
    %     set(p2, 'Color', 'b');
    %     set(ax,'FontSize',font_size);
    %     set(ax,{'ycolor'},{'k';'k'})
    %     ylabel(ax(1),'Fuel consumed (gallon)','FontSize', font_size,'Color', 'r') % label left y-axis
    %     ylabel(ax(2),'Speed (mph)','FontSize', font_size, 'Color', 'b' ) % label right y-axis
    %     xlabel(ax(1),'Travel time (h)','FontSize', font_size) % label x-axis
    %     grid off;
    %     box on;
    % %    export_fig('fig/fuel_consumed_grade_zero_100_miles', '-pdf','-transparent','-nocrop');
    %     export_fig(sprintf('fig/fuel_consumed_grade_%d_100_miles', grade_level), '-pdf','-transparent','-nocrop');
    
    
    %
    %     %fit model
    %     [fitpoly3, gof, output] = fit(speed_vec,gph_c_vec,'poly3');
    %     coefa(nn) = fitpoly3.p1;
    %     coefb(nn) = fitpoly3.p2;
    %     coefc(nn) = fitpoly3.p3;
    %     coefd(nn) = fitpoly3.p4;
    
    
    %     figure;
    %     font_size = 22.4;
    %     line_width = 2;
    %     set(gca,'FontSize',font_size);
    %     hold on;
    %     h=plot(fitpoly3, '-b', speed_vec, gph_c_vec, 'r+');
    %     set(h,'linewidth', line_width);
    %     hold off;
    %     xlabel('speed (mph)','FontSize', font_size, 'FontName', 'Arial');
    %     ylabel('power-speed function (gph)','FontSize', font_size, 'FontName', 'Arial');
    %     legend('data','fitted curve','Location','northwest');
    %     %ylim([0,22]);
    %     box on;
    %     grid on;
    %     %export_fig('fig/power_speed_fit_grade_zero', '-pdf','-transparent','-nocrop');
    %     export_fig(sprintf('fig/power_speed_fit_grade_%d',grade_level), '-pdf','-transparent','-nocrop');
end
fclose(fid);

%plot the figure here
figure;
font_size = 22.4;
line_width = 2;
set(gca,'FontSize',font_size);
hold on;
h1=plot(fitpoly3_grade_1, '-g', speed_vec_grade_1, gph_c_vec_grade_1, 'g+');
set(h1,'linewidth', line_width);
h2=plot(fitpoly3_grade_2, '-b', speed_vec_grade_2, gph_c_vec_grade_2, 'b+');
set(h2,'linewidth', line_width);
h3=plot(fitpoly3_grade_3, '-r', speed_vec_grade_3, gph_c_vec_grade_3, 'r+');
set(h3,'linewidth', line_width);
hold off;
xlabel('speed (mph)','FontSize', font_size, 'FontName', 'Arial');
ylabel('fuel-rate-speed function (gph)','FontSize', font_size, 'FontName', 'Arial');
%ylim([0,22]);
xlim([10,70]);
h_legend = legend('data (-2%)','fitted (-2%)',...
       'data (0%)','fitted (0%)', ...
       'data (2%)','fitted (2%)','Location','northwest');
set(h_legend,'FontSize',14);
box on;
grid on;
%export_fig('fig/power_speed_fit_grade_zero', '-pdf','-transparent','-nocrop');
export_fig(sprintf('fig/fuel_rate_speed_function_fit'), '-pdf','-transparent','-nocrop');

%suppose the distance is 100miles
D = 100;
a = 0;
b = 0;
c = 0;
d = 0;
figure;
font_size = 22.4;
line_width = 2;
set(gca,'FontSize',font_size);
hold on;
% grade 1
a = fitpoly3_grade_1.p1;
b = fitpoly3_grade_1.p2;
c = fitpoly3_grade_1.p3;
d = fitpoly3_grade_1.p4;
t1 = D./speed_vec_grade_1;
t1_flip = fliplr(t1')';
c1 = t1.*(a*speed_vec_grade_1.^3 + b*speed_vec_grade_1.^2 + c*speed_vec_grade_1 + d);
c1_flip = fliplr(c1')';
%h1=plot(speed_vec_grade_1, c1, '-g', speed_vec_grade_1, t1.*gph_c_vec_grade_1, 'g+');
h1=plot(t1, c1, '-g', t1, t1.*gph_c_vec_grade_1, 'g+');
set(h1,'linewidth', line_width);
% grade 2
a = fitpoly3_grade_2.p1;
b = fitpoly3_grade_2.p2;
c = fitpoly3_grade_2.p3;
d = fitpoly3_grade_2.p4;
t2 = D./speed_vec_grade_2;
t2_flip = fliplr(t2')';
c2 = t2.*(a*speed_vec_grade_2.^3 + b*speed_vec_grade_2.^2 + c*speed_vec_grade_2 + d);
c2_flip = fliplr(c2')';
%h2=plot(speed_vec_grade_2, c2, '-b', speed_vec_grade_2, t2.*gph_c_vec_grade_2, 'b+');
h2=plot(t2, c2, '-b', t2, t2.*gph_c_vec_grade_2, 'b+');
set(h2,'linewidth', line_width);
% grade 3
a = fitpoly3_grade_3.p1;
b = fitpoly3_grade_3.p2;
c = fitpoly3_grade_3.p3;
d = fitpoly3_grade_3.p4;
t3 = D./speed_vec_grade_3;
t3_flip = fliplr(t3')';
c3 = t3.*(a*speed_vec_grade_3.^3 + b*speed_vec_grade_3.^2 + c*speed_vec_grade_3 + d);
c3_flip = fliplr(c3')';
%h3=plot(speed_vec_grade_3, c3, '-r', speed_vec_grade_3, t3.*gph_c_vec_grade_3, 'r+');
h3=plot(t3, c3, '-r', t3, t3.*gph_c_vec_grade_3, 'r+');
set(h3,'linewidth', line_width);
hold off;
xlabel('time (hours)','FontSize', font_size, 'FontName', 'Arial');
ylabel('fuel-time function (gallons)','FontSize', font_size, 'FontName', 'Arial');
set(gca,'XTick',[1:1:10]);
xlim([1,10]);
ylim([0,40]);
%xlim([10,70]);
h_legend = legend('data (-2%)','fitted (-2%)',...
       'data (0%)','fitted (0%)', ...
       'data (2%)','fitted (2%)','Location','northeast');
set(h_legend,'FontSize',14);
box on;
grid on;
%export_fig('fig/power_speed_fit_grade_zero', '-pdf','-transparent','-nocrop');
export_fig(sprintf('fig/fuel_time_function_fit'), '-pdf','-transparent','-nocrop');



save('coef_fit_gph.mat', 'grade_level_vec', 'coefa', 'coefb', 'coefc', 'coefd');
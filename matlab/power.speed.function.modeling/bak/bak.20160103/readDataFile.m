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


data_file = 'data_file/data_all_20151208.csv';
data_vec_org = csvread(data_file, 0, 1);

grade_level_vec = -3:1:-3;
n_grade_level = length(grade_level_vec);
for nn=1:n_grade_level
    grade_level = grade_level_vec(nn);
    data_vec = data_vec_org(abs(data_vec_org(:,1) - grade_level/100) < 1e-10,:);
    %data_vec = data_vec(data_vec(:,2) >= 40, :);
    
    %find all valid records
    k = find(data_vec(:,8) > 1e-10);
    data_vec = data_vec (k,:);
    
    %get the individual parameters
    grade_vec = data_vec(:,1);
    speed_vec = data_vec(:,2);
    time_vec = data_vec(:,3);
    dist_vec = data_vec(:,4);
    mpg_vec = data_vec(:,5);
    mpgge_vec = data_vec(:,6);
    gph_vec = data_vec(:,7);
    dist_c_vec = data_vec(:,8);
    mpg_c_vec = data_vec(:,9);
    mpgge_c_vec = data_vec(:,10);
    gph_c_vec = data_vec(:,11);
    
    %scale to gallon per mile
    gpm_c_vec = 1./mpg_c_vec;
    %scale to gallon per 100 miles
    gp100m_c_vec = gpm_c_vec*100; 
    
    %fuel economy
    figure;
    font_size = 22.4;
    line_width = 2;
    set(gca,'FontSize',font_size);
    hold on;
    plot(speed_vec, gph_c_vec, '-r', 'Linewidth', line_width);
    plot(speed_vec, mpg_c_vec, '-b', 'Linewidth', line_width);
    plot(speed_vec, gp100m_c_vec, '-g', 'Linewidth', line_width);
    hold off;
    xlabel('speed (mph)','FontSize', font_size, 'FontName', 'Arial');
    legend('gph','mpg','gp100m','Location','north');
    %ylim([0,22]);
    box on;
    grid on;
    export_fig(sprintf('fig/fuel_economy_grade_%d', grade_level), '-pdf','-transparent','-nocrop');
    
    %evaluate c_e(t_e) function, where we suppose D_e = 100 miles
    te = 100./speed_vec;
    ce = te.*gph_c_vec;
    
    % figure;
    % font_size = 22.4;
    % line_width = 2;
    % set(gca,'FontSize',font_size);
    % hold on;
    % plot(te, ce, '-r', 'Linewidth', line_width);
    % hold off;
    % xlabel('Travel time (h)','FontSize', font_size, 'FontName', 'Arial');
    % ylabel('Fuel consumed (gallon)','FontSize', font_size, 'FontName', 'Arial');
    % box on;
    % grid on;
    % %export_fig('fig/fuel_consumed_grade_zero_100_miles', '-pdf','-transparent','-nocrop');
    
    
    figure
    line_width = 2;
    font_size = 12;
    [ax, p1, p2] = plotyy(te,ce,te,100./te);
    set(p1, 'Linewidth', line_width);
    set(p1, 'Color', 'r');
    set(p2, 'Linewidth', line_width);
    set(p2, 'Color', 'b');
    set(ax,'FontSize',font_size);
    set(ax,{'ycolor'},{'k';'k'})
    ylabel(ax(1),'Fuel consumed (gallon)','FontSize', font_size,'Color', 'r') % label left y-axis
    ylabel(ax(2),'Speed (mph)','FontSize', font_size, 'Color', 'b' ) % label right y-axis
    xlabel(ax(1),'Travel time (h)','FontSize', font_size) % label x-axis
    grid off;
    box on;
%    export_fig('fig/fuel_consumed_grade_zero_100_miles', '-pdf','-transparent','-nocrop');
    export_fig(sprintf('fig/fuel_consumed_grade_%d_100_miles', grade_level), '-pdf','-transparent','-nocrop');
    
    %fit model
    [fitpoly3, gof] = fit(speed_vec,gph_c_vec,'poly3')
    figure;
    font_size = 22.4;
    line_width = 2;
    set(gca,'FontSize',font_size);
    hold on;
    h=plot(fitpoly3, '-b', speed_vec, gph_c_vec, 'r+');
    set(h,'linewidth', line_width);
    hold off;
    xlabel('speed (mph)','FontSize', font_size, 'FontName', 'Arial');
    ylabel('power-speed function (gph)','FontSize', font_size, 'FontName', 'Arial');
    legend('data','fitted curve','Location','northwest');
    %ylim([0,22]);
    box on;
    grid on;
    %export_fig('fig/power_speed_fit_grade_zero', '-pdf','-transparent','-nocrop');
    export_fig(sprintf('fig/power_speed_fit_grade_%d',grade_level), '-pdf','-transparent','-nocrop');
end

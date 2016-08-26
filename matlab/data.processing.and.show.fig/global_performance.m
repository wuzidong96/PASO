close all; clear all;

all_info_data_orig = csvread('data/info_T800.csv');
%remove shortest path infeasible instance
row_idx_feasible = all_info_data_orig(:,13) > 1e-10;
all_info_data = all_info_data_orig(row_idx_feasible,:);

avg_infeasible_per = (1- sum(row_idx_feasible)/size(all_info_data_orig,1))*100
%% get all entries
%solutions: F, F_SO, S, S_SO, LB, UB, OPT

src_v = all_info_data(:,1);
des_v = all_info_data(:,2);
delay_v = all_info_data(:,3);

% sol_fastest_path_time_min
F_time = all_info_data(:,4);
F_dist = all_info_data(:,5);
F_fuel = all_info_data(:,6);
F_gp100m = 100*F_fuel./F_dist;
F_mpg = F_dist./F_fuel;

% sol_fastest_path_opt
F_SO_time = all_info_data(:,7);
F_SO_dist = all_info_data(:,8);
F_SO_fuel = all_info_data(:,9);
F_SO_gp100m = 100*F_SO_fuel./F_SO_dist;
F_SO_mpg = F_dist./F_SO_fuel;

% sol_shortest_path_time_min
S_time = all_info_data(:,10);
S_dist = all_info_data(:,11);
S_fuel = all_info_data(:,12);
S_gp100m = 100*S_fuel./S_dist;
S_mpg = S_dist./S_fuel;

% sol_shortest_path_opt
S_SO_time = all_info_data(:,13);
S_SO_dist = all_info_data(:,14);
S_SO_fuel = all_info_data(:,15);
S_SO_gp100m = 100*S_SO_fuel./S_dist;
S_SO_mpg = S_SO_dist./S_SO_fuel;


% sol_lb
LB_time = all_info_data(:,16);
LB_dist = all_info_data(:,17);
LB_fuel = all_info_data(:,18);
LB_gp100m = 100*LB_fuel./LB_dist;
LB_mpg = LB_dist./LB_fuel;

% sol_ub
UB_time = all_info_data(:,19);
UB_dist = all_info_data(:,20);
UB_fuel = all_info_data(:,21);
UB_gp100m = 100*UB_fuel./UB_dist;
UB_mpg = UB_dist./UB_fuel;

% sol_opt
OPT_time = all_info_data(:,22);
OPT_dist = all_info_data(:,23);
OPT_fuel = all_info_data(:,24);
OPT_gp100m = 100*OPT_fuel./OPT_dist;

%% avg performance over all feasible instances
avg_F_mpg = mean(F_mpg)
avg_F_SO_mpg = mean(F_SO_mpg)
avg_S_mpg = mean(S_mpg)
avg_S_SO_mpg = mean(S_SO_mpg)
avg_LB_mpg = mean(LB_mpg)
avg_UB_mpg = mean(UB_mpg)


diff_F_SO_time_perc = (F_SO_time - F_time)*100./F_time;
diff_S_time_perc = (S_time - F_time)*100./F_time;
diff_S_SO_time_perc = (S_SO_time - F_time)*100./F_time;
diff_LB_time_perc = (LB_time - F_time)*100./F_time;
diff_UB_time_perc = (UB_time - F_time)*100./F_time;

avg_diff_F_SO_time_perc = mean(diff_F_SO_time_perc)
avg_diff_S_time_perc = mean(diff_S_time_perc)
avg_diff_S_SO_time_perc = mean(diff_S_SO_time_perc)
avg_diff_LB_time_perc = mean(diff_LB_time_perc)
avg_diff_UB_time_perc = mean(diff_UB_time_perc)


diff_F_dist_perc = (F_dist - S_dist)*100./S_dist;
diff_F_SO_dist_perc = (F_SO_dist - S_dist)*100./S_dist;
diff_LB_dist_perc = (LB_dist - S_dist)*100./S_dist;
diff_UB_dist_perc = (UB_dist - S_dist)*100./S_dist;

avg_diff_F_dist_perc = mean(diff_F_dist_perc)
avg_diff_F_SO_dist_perc = mean(diff_F_SO_dist_perc)
avg_diff_LB_dist_perc = mean(diff_LB_dist_perc)
avg_diff_UB_dist_perc = mean(diff_UB_dist_perc)

diff_F_fuel_perc = (F_fuel - LB_fuel)*100./LB_fuel;
diff_F_SO_fuel_perc = (F_SO_fuel - LB_fuel)*100./LB_fuel;
diff_S_fuel_perc = (S_fuel - LB_fuel)*100./LB_fuel;
diff_S_SO_fuel_perc = (S_SO_fuel - LB_fuel)*100./LB_fuel;
diff_UB_fuel_perc = (UB_fuel - LB_fuel)*100./LB_fuel;

avg_diff_F_fuel_perc = mean(diff_F_fuel_perc)
avg_diff_F_SO_fuel_perc = mean(diff_F_SO_fuel_perc)
avg_diff_S_fuel_perc = mean(diff_S_fuel_perc)
avg_diff_S_SO_fuel_perc = mean(diff_S_SO_fuel_perc)
avg_diff_UB_fuel_perc = mean(diff_UB_fuel_perc)


%% avg performance for each delay
% T_v = min(delay_v):max(delay_v);
% n_T = length(T_v);
% for nn=1:n_T
%     T = T_v(nn);
%     idx = [delay_v == T];
%     diff_F_fuel_perc_temp = diff_F_fuel_perc(idx);
%     diff_F_SO_fuel_perc_temp = diff_F_SO_fuel_perc(idx);
%     diff_S_fuel_perc_temp = diff_S_fuel_perc(idx);
%     diff_S_SO_fuel_perc_temp = diff_S_SO_fuel_perc(idx);
%     diff_UB_fuel_perc_temp = diff_UB_fuel_perc(idx);
%     
%     avg_diff_F_fuel_perc_delay(nn) = mean(diff_F_fuel_perc_temp)
%     avg_diff_F_SO_fuel_perc_delay(nn) = mean(diff_F_SO_fuel_perc_temp)
%     avg_diff_S_fuel_perc_delay(nn) = mean(diff_S_fuel_perc_temp)
%     avg_diff_S_SO_fuel_perc_delay(nn) = mean(diff_S_SO_fuel_perc_temp)
%     avg_diff_UB_fuel_perc_delay(nn) = mean(diff_UB_fuel_perc_temp)
%     
%     %also get the infeasible percentage
%     delay_orig_v = all_info_data_orig(:,3);
%     S_SO_time_orig = all_info_data_orig(:,13);
%     idx_temp = [delay_orig_v == T];
%     total_number = sum(idx_temp);
%     infeasible_number = sum(S_SO_time_orig(idx_temp) < 1e-10);
%     infeasible_perc_delay(nn) = infeasible_number*100/total_number;
% end
% 
% 
% figure;
% font_size = 22.4;
% line_width = 3;
% set(gca,'FontSize',font_size);
% hold on;
% %plot(T_v, avg_diff_F_fuel_perc_delay, '-r', 'Linewidth', line_width);
% plot(T_v, avg_diff_F_SO_fuel_perc_delay, '--r', 'Linewidth', line_width);
% %plot(T_v, avg_diff_S_fuel_perc_delay, '-b', 'Linewidth', line_width);
% plot(T_v, avg_diff_S_SO_fuel_perc_delay, '--b', 'Linewidth', line_width);
% plot(T_v, avg_diff_UB_fuel_perc_delay, '-g', 'Linewidth', line_width);
% %plot(T_v, infeasible_perc_delay, '-k', 'Linewidth', line_width);
% hold off;
% xlabel('Delay (h)','FontSize', font_size, 'FontName', 'Arial');
% ylabel('Fuel Increment (%)','FontSize', font_size, 'FontName', 'Arial');
% %h=legend('F', 'F-SO', 'S', 'S-SO', 'OPT-UB', 'location', 'northeast');
% h=legend('F-SO', 'S-SO', 'OPT-UB', 'location', 'northwest');
% set(h, 'fontsize', 18);
% xlim([5,40]);
% box on;
% grid on;
% %export_fig(sprintf('fig/comparision_fuel_economy_all_instances'), '-pdf','-transparent','-nocrop');


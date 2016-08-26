function [ one_instance_info_data ] = getOneSourceSinkInfo(info_csv_file, source, sink)
%getOneInstanceInfo get the infomation of one instance (source, sink, T)
%   Detailed explanation goes here
    all_info_data = csvread(info_csv_file);
    %from here http://stackoverflow.com/questions/20293118/find-corresponding-rows-if-it-has-some-missing-elements
    key = [source sink NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
    pos = ~isnan(key); %// positions of actual values
    idx = ismember(all_info_data(:,pos),key(pos),'rows'); %// select columns and apply ismember
    one_instance_info_data = all_info_data(idx,:);
    
    delay = one_instance_info_data(:,3)
    max_delay = max(delay)
    % sol_fastest_path_time_min
    F_time = one_instance_info_data(:,4)
    F_distance = one_instance_info_data(:,5);
    F_fuel = one_instance_info_data(:,6);
    
    %get the scalars
    fatest_time  = F_time(1);
    fatest_time_fuel = F_fuel(1);
    
    fatest_time_v = linspace(fatest_time, max_delay, 10);
    fatest_time_fuel_v = fatest_time_fuel.*ones(size(fatest_time_v));
    
    
    % sol_fastest_path_opt
    F_opt_time = one_instance_info_data(:,7);
    F_opt_distance = one_instance_info_data(:,8);
    F_opt_fuel = one_instance_info_data(:,9);
    
    % sol_shortest_path_time_min
    S_time = one_instance_info_data(:,10)
    S_distance = one_instance_info_data(:,11);
    S_fuel = one_instance_info_data(:,12);
    
    %get the scalars
    shortest_time = S_time(1);
    shortest_time_fuel = S_fuel(1);
    
    shortest_time_v = linspace(shortest_time, max_delay, 10);
    shortest_time_fuel_v = shortest_time_fuel.*ones(size(shortest_time_v));
    
    % sol_shortest_path_opt
    S_opt_time = one_instance_info_data(:,13)
    S_opt_distance = one_instance_info_data(:,14);
    S_opt_fuel = one_instance_info_data(:,15)
    idx = (delay > shortest_time)
    delay_valid_for_S_opt = delay(idx)
    S_opt_fuel_valid = S_opt_fuel(idx)
    [min_delay_valid_for_S_opt, min_delay_valid_for_S_opt_idx] = min(delay_valid_for_S_opt)
    
    
    
    % sol_lb
    LB_time = one_instance_info_data(:,16);
    LB_distance = one_instance_info_data(:,17);
    LB_fuel = one_instance_info_data(:,18);
    
    % sol_ub
    UB_time = one_instance_info_data(:,19);
    UB_distance = one_instance_info_data(:,20);
    UB_fuel = one_instance_info_data(:,21);
        
    
    % sol_opt
    OPT_time = one_instance_info_data(:,22);
    OPT_distance = one_instance_info_data(:,23);
    OPT_fuel = one_instance_info_data(:,24);
    
    %plot it here
    figure;
    font_size = 22.4;
    line_width = 2;
    set(gca,'FontSize',font_size);
    hold on;
    plot(fatest_time_v, fatest_time_fuel_v, '-r', 'Linewidth', line_width);
    plot(delay, F_opt_fuel, '--rs', 'Linewidth', line_width, 'markersize', 10);
    plot(shortest_time_v, shortest_time_fuel_v, '-b', 'Linewidth', line_width);
    plot(delay_valid_for_S_opt, S_opt_fuel_valid, '--b+', 'Linewidth', line_width,'markersize', 10);
    plot(delay, UB_fuel, '-go', 'Linewidth', line_width,'markersize', 10);
    plot(delay, LB_fuel, '-gx', 'Linewidth', line_width,'markersize', 10);
   % plot(min_delay_valid_for_S_opt, S_opt_fuel_valid(min_delay_valid_for_S_opt_idx), 'xb',  'Linewidth', line_width, 'markersize', 20');
    hold off;
    xlabel('Delay (hour)','FontSize', font_size, 'FontName', 'Arial');
    ylabel('Fuel consumed (gallon)','FontSize', font_size, 'FontName', 'Arial');
    h=legend('F', 'F-SO', 'S', 'S-SO', 'OPT-UB', 'OPT-LB', 'location', 'northeast');
    xlim([delay(1)-1,delay(end)+1]);
    %set(gca,'XTick',delay(1):1:delay(end));
    set(h, 'fontsize', 18);
    box on;
    grid on;
    export_fig(sprintf('fig/comparision_%d_%d', source, sink), '-pdf','-transparent','-nocrop');
end


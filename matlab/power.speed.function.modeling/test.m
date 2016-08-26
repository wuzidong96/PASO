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



data_file = 'data_file/data_T800_20160127.csv';
fid = fopen(data_file);
if(fid == -1)
    error('cannot open data file');
end
%data_vec_org is a 1x12 cell
data_vec_org = textscan(fid, '%s %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter',',');
fclose(fid);



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

grade_level_vec = 0:0.1:0;
n_grade_level = length(grade_level_vec);
coefa = zeros(size(grade_level_vec));
coefb = zeros(size(grade_level_vec));
coefc = zeros(size(grade_level_vec));
coefd = zeros(size(grade_level_vec));

%we only fit the data for the speed in the range [min_speed, max_speed]
min_speed = 30;
max_speed = 70;
grade_1 = -3.5;
grade_2 = 0;
grade_3 = 1;
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
        min_speed = 10;
        max_speed = 70;
    else
        min_speed = 30;
        max_speed = 60;
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
   

    figure;
    font_size = 22.4;
    line_width = 2;
    set(gca,'FontSize',font_size);
    hold on;
    % plot(speed_vec, gph_c_vec, '-r', 'Linewidth', line_width);
    plot(speed_vec(1:10:end), mpg_c_vec(1:10:end), '-b', 'Linewidth', line_width);
    % plot(speed_vec, gp100m_c_vec, '-g', 'Linewidth', line_width);
    hold off;
    xlabel('speed (mph)','FontSize', font_size, 'FontName', 'Arial');
    ylabel('Fuel economy (mpg)','FontSize', font_size, 'FontName', 'Arial');
    %ylim([0,22]);
    box on;
    grid on;
end



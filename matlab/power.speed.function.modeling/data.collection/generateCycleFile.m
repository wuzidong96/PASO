function [ ] = generateCycleFile(data_obj, cyc_file_name )
%generateCycleFile Generate cycle file according to the input cyc_mph and
%cyc_grade
%   Detailed explanation goes here
%   Input:   cyc_mph
%               -Dim: zeros(T,2)
%               -cyc_mph(t, 1) = t; means the time instance t (seconds)
%               -cyc_mph(t, 2) is the speed (units: mph) at t second
%            cyc_grade
%               -Dim: scalar
%               -The constance grade of the road



cyc_mph = zeros(data_obj.input_time+1,2);
cyc_mph(:,1) = 0:data_obj.input_time;
cyc_mph(:,2) = data_obj.input_speed;
cyc_grade = data_obj.input_grade;

fid = fopen(cyc_file_name, 'w');
if(fid == -1)
    error('cannot open the file cyc_file_name');
end

fprintf(fid, '\n');
fprintf(fid, 'cyc_description=''My speed cycle'';\n');
fprintf(fid, 'cyc_version=2003;\n');
fprintf(fid, 'cyc_proprietary=0;\n');
fprintf(fid, 'cyc_validation=0;\n');
fprintf(fid, 'disp([''Data loaded: CYC_MY - '',cyc_description])\n');


% size of cyc_mph
[m, n] = size(cyc_mph);
if(n ~= 2)
    error('wrong matrix');
end

fprintf(fid, '\n\n');


fprintf(fid, 'cyc_mph=zeros(%d,%d);\n', m, n);
for tt=1:m
    time_sec = cyc_mph(tt,1);
    speed_mph = cyc_mph(tt,2);
    fprintf(fid, 'cyc_mph(%d,1)=%d; cyc_mph(%d,2)=%f;\n', tt, time_sec, tt, speed_mph);
end

% fprintf(fid, 'cyc_mph=[0 %f\n', data_obj.input_speed);
% fprintf(fid, '         5-eps %f\n', data_obj.input_speed);
% fprintf(fid, '         5 %f\n', data_obj.input_speed);
% fprintf(fid, '         %d %f];', data_obj.input_time, data_obj.input_speed);


fprintf(fid, '\n\n');
fprintf(fid, 'vc_key_on=[cyc_mph(:,1) ones(size(cyc_mph,1),1)];\n');

fprintf(fid, '\n\n');
fprintf(fid, 'cyc_avg_time=1;\n');
fprintf(fid, 'cyc_filter_bool=0;\n');
fprintf(fid, 'cyc_grade=%f;\n', cyc_grade);
fprintf(fid, 'cyc_elevation_init=0;\n');

fprintf(fid, '\n\n');
fprintf(fid, 'if size(cyc_grade,1)<2\n');
fprintf(fid, '    cyc_grade=[0 cyc_grade; 1 cyc_grade];\n');
fprintf(fid, 'end\n');

fprintf(fid, '\n\n');
fprintf(fid, 'cyc_cargo_mass=[0 0;1 0];\n'); 

fprintf(fid, '\n\n');
fprintf(fid, 'if size(cyc_cargo_mass,1)<2\n');
fprintf(fid, '    cyc_cargo_mass=[0 cyc_cargo_mass; 1 cyc_cargo_mass];\n');
fprintf(fid, 'end\n');

fprintf(fid, '\n\n');
fprintf(fid, 'if exist(''cyc_coast_gb_shift_delay'')\n');
fprintf(fid, '    gb_shift_delay=cyc_coast_gb_shift_delay;\n');
fprintf(fid, 'end\n');

fclose(fid);

end


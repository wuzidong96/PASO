function [] = collectData(veh_file,grade,speed, time, data_file)
% we should initilize outside this function
% during this function, we only modify the paramters

data_obj = DataInstance();
data_obj.input_veh_file = veh_file;
data_obj.input_grade = grade;
data_obj.input_speed = speed;
data_obj.input_time = time; %30 min
generateCycleFile(data_obj, 'CYC_MY.m');


% %heavy_truck
% input.init.saved_veh_file=data_obj.input_veh_file;
% [a,b]=adv_no_gui('initialize',input);

input.cycle.param={'cycle.name'};
input.cycle.value={'CYC_MY'};
[a,b]=adv_no_gui('drive_cycle',input);

input.resp.param={'dist','gal','mpg','mpgge', 'trace_miss','distance',};
[a,b] = adv_no_gui('other_info',input);

data_obj.output_dist = b.other.value{1};
data_obj.output_gal = b.other.value{2}(end);
data_obj.output_mpg = b.other.value{3};
data_obj.output_mpgge = b.other.value{4};
data_obj.output_gps = data_obj.output_gal/data_obj.input_time;

k = find(b.other.value{5} <= 1e-10,1);
if(isempty(k))
    disp('speed not achieved');
else
    % distance is in unit of m, change it to mile
    data_obj.output_dist_c = (b.other.value{6}(end) - b.other.value{6}(k))/1609.34;
    data_obj.output_gal_c = b.other.value{2}(end) - b.other.value{2}(k);
    data_obj.output_mpg_c = data_obj.output_dist_c/data_obj.output_gal_c;
    data_obj.output_mpgge_c = data_obj.output_mpg_c * (data_obj.output_mpgge/data_obj.output_mpg);
    data_obj.output_gps_c = data_obj.output_gal_c/(data_obj.input_time - k);
end

data_obj.writeToFile(data_file);


% data_obj.output_dist = dist;
% data_obj.output_gal = gal(end);
% data_obj.output_mpg = mpg;
% data_obj.output_mpgge = mpgge;
% data_obj.output_gps = gal(m)/data_obj.input_time;
% 
% k = find(trace_miss <= 1e-10,1);
% if(isempty(k))
%     disp('speed not achieved');
% else
%     % distance is in unit of m, change it to mile
%     data_obj.output_dist_c = (distance(end) - distance(k))/1609.34;
%     data_obj.output_gal_c = gal(end) - gal(k);
%     data_obj.output_mpg_c = data_obj.output_dist_c/data_obj.output_gal_c;
%     data_obj.output_mpgge_c = data_obj.output_mpg_c * (data_obj.output_mpgge/data_obj.output_mpg);
%     data_obj.output_gps_c = data_obj.output_gal_c/(data_obj.input_time - k);
% end
% 
% data_obj.writeToFile(data_file);

end


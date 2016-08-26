close all; clear all;
%close all biograph viewer
child_handles = allchild(0);
names = get(child_handles,'Name');
k = find(strncmp('Biograph Viewer', names, 15));
close(child_handles(k))

%% construct the transportation network
% # of nodes;
n_node = 6;
% # of links;
%n_link = 10;

topology_obj = Topology(n_node);

% positions of each node (x,y,z) where z is the elevation
pos_x_node = zeros(n_node,1);
pos_y_node = zeros(n_node,1);
%pos_z_node = zeros(n_node,1);

% % the network area [0, 100km] * [0, 100km] * [0, 500m] 
% x_max = 100e3;
% y_max = 100e3;
% z_max = 500;
% 
% pos_x_node = x_max*rand(n_node,1);
% pos_y_node = y_max*rand(n_node,1);
% pos_z_node = z_max*rand(n_node,1);

scale = 100; %the scale, all postions are normerlized according to scale
pos_x_node(1)=0.1; pos_y_node(1)=0.5*2; %source node
pos_x_node(2)=0.5; pos_y_node(2)=0.7*2;
pos_x_node(3)=1.5; pos_y_node(3)=0.73*2;
pos_x_node(4)=1; pos_y_node(4)=0.1*2;
pos_x_node(5)=0.8; pos_y_node(5)=0.4*2;
pos_x_node(6)=1.9; pos_y_node(6)=0.5*2;

pos_x_node = scale*pos_x_node;
pos_y_node = scale*pos_y_node;

topology_obj.position_node = [pos_x_node,pos_y_node];


distance = zeros(n_node,n_node);
for ii=1:n_node
    for jj=1:n_node
        dis = sqrt((pos_x_node(ii)-pos_x_node(jj))^2+(pos_y_node(ii)-pos_y_node(jj))^2);
        distance(ii,jj)=dis;
    end
end

links = zeros(n_node,n_node);
links(1,2)=1;
links(1,4)=1;
links(1,5)=1;
links(2,3)=1;
links(2,5)=1;
links(3,6)=1;
links(4,6)=1;
links(5,3)=1;
links(5,4)=1;
links(5,6)=1;
%links(3,5)=1;


topology_obj.links = links;
topology_obj.distance_link = links.*distance;


speed_min = 10*ones(n_node,n_node);
speed_min(1,2)=10;
speed_min(1,4)=10;
speed_min(1,5)=10;
speed_min(2,3)=10;
speed_min(2,5)=10;
speed_min(3,6)=10;
speed_min(4,6)=10;
speed_min(5,3)=10;
speed_min(5,4)=10;
speed_min(5,6)=10;
topology_obj.speed_min_link = topology_obj.links.*speed_min;


speed_max = 100*ones(n_node,n_node);
speed_max(1,2)=100;
speed_max(1,4)=100;
speed_max(1,5)=100;
speed_max(2,3)=100;
speed_max(2,5)=100;
speed_max(3,6)=100;
speed_max(4,6)=100;
speed_max(5,3)=100;
speed_max(5,4)=100;
speed_max(5,6)=100;
topology_obj.speed_max_link = topology_obj.links.*speed_max;


coefa = 10*1e-5*rand(n_node,n_node).*links;
%coefa = zeros(n_node, n_node).*links;
coefb = 10*1e-3*rand(n_node,n_node).*links;
coefc = 5*1e-1*rand(n_node,n_node).*links; %have no effect
%coefc = zeros(n_node, n_node).*links;
coefd = 10*1e-2*rand(n_node,n_node).*links;
save('coef.mat','coefa','coefb','coefc','coefd');

load coef.mat;
topology_obj.coef_a_link = coefa;
topology_obj.coef_b_link = coefb;
topology_obj.coef_c_link = coefc;
topology_obj.coef_d_link = coefd;
% 
% topology_obj.plotTopology();
% 
% [x1, y1] = topology_obj.plot_fuel_rate_speed_function(1,2);
% [x2, y2] = topology_obj.plot_fuel_rate_speed_function(1,4);
% [x3, y3] = topology_obj.plot_fuel_rate_speed_function(1,5);
% 
% [x4, y4] = topology_obj.plot_total_fuel_time_function(1,2);
% tic;
% [x5, y15, y25] = topology_obj.plot_new_weight_with_delay_price_function(1,2);
% toc;


%topology_obj.plotAll();

source = 1;
sink = 6;
T = 6;

[sp_dist, sp_path] = topology_obj.getShortestPath(source, sink);
[sp_fuel_opt, sp_t_opt, sp_speed_opt, sp_dual_opt] = optimizeSinglePath(source, sink, T, topology_obj, sp_path, 'cvx');


all_paths = topology_obj.getAllPaths(source,sink);
n_path = length(all_paths);
fuel_path = zeros(n_path,1);
dual_path = zeros(n_path,1);
speed_path = cell(n_path,1);
t_path = cell(n_path,1);

for pp=1:n_path
    [fuel_path(pp), t_path{pp}, speed_path{pp}, dual_path(pp)] = optimizeSinglePath(source, sink, T, topology_obj, all_paths{pp}, 'cvx');
end

[min_fuel, min_fuel_path_idx] = min(fuel_path);
min_fuel_path = all_paths{min_fuel_path_idx};
min_fuel_dual = dual_path(min_fuel_path_idx);
min_fuel_t = t_path{min_fuel_path_idx};
min_fuel_speed = speed_path{min_fuel_path_idx};

figure;
set(gca,'FontSize',20);
hold on;
[ax, p1, p2] = plotyy(1:n_path, fuel_path ,1:n_path,dual_path);
set(p1, 'Linewidth', 3);
set(p1, 'Color', 'r');
set(p2, 'Linewidth', 3);
set(p2, 'Color', 'b');
set(ax,'FontSize',12);
set(ax,{'ycolor'},{'r';'b'});
plot(min_fuel_path_idx,min_fuel, 'gx', 'linewidth', 3, 'markersize', 12);
text(min_fuel_path_idx,min_fuel, sprintf('(%.2f, %.2f)',min_fuel, min_fuel_dual))
hold off;
ylabel(ax(1), 'Optimal fuel','FontSize', 20, 'FontName', 'Arial');
ylabel(ax(2), 'Optimal dual value','FontSize', 20, 'FontName', 'Arial');
xlabel(ax(1),'Path index','FontSize', 20) % label x-axis
box on;
grid on;



tic;
lambda_vec = 0:0.01:100;
total_weight = zeros(length(lambda_vec),1);
total_time = zeros(length(lambda_vec),1);
opt_path_idx = zeros(length(lambda_vec),1);
for nn=1:length(lambda_vec)
    lambda = lambda_vec(nn);
    if(mod(lambda,1) <= 1e-10)
        lambda
    end
    [total_weight(nn), new_path, new_time] = topology_obj.getShortestPathWithNewWeight(source, sink, lambda);
    for pp=1:n_path
        if(isequal(new_path, all_paths{pp}))
            opt_path_idx(nn) = pp;
            break;
        end
    end
    for ee=1:length(new_path)-1
        tail = new_path(ee);
        head = new_path(ee+1);
        total_time(nn) = total_time(nn) + new_time(tail,head);
    end
end
toc;


dual_value_vec = total_weight-lambda_vec'*T;
[max_dual_value, max_dual_value_idx] = max(dual_value_vec);
max_dual_value_lambda = lambda_vec(max_dual_value_idx);

figure;
set(gca,'FontSize',20);
hold on;
plot(lambda_vec, total_time, 'k', 'linewidth',3);
[ax, p1, p2] = plotyy(lambda_vec, dual_value_vec ,lambda_vec,opt_path_idx);
set(p1, 'Linewidth', 3);
set(p1, 'Color', 'r');
set(p2, 'Linewidth', 3);
set(p2, 'Color', 'b');
set(ax,'FontSize',12);
set(ax,{'ycolor'},{'r';'b'});
plot(max_dual_value_lambda,max_dual_value, 'gx', 'linewidth', 3, 'markersize', 12);
plot(max_dual_value_lambda,total_time(max_dual_value_idx), 'gx', 'linewidth', 3, 'markersize', 12);
text(max_dual_value_lambda,max_dual_value, sprintf('(%.2f, %.2f)',max_dual_value_lambda,max_dual_value));
text(max_dual_value_lambda,total_time(max_dual_value_idx), sprintf('(%.2f, %.2f)',max_dual_value_lambda,total_time(max_dual_value_idx)));
hold off;
ylabel(ax(1), 'Dual value','FontSize', 20, 'FontName', 'Arial');
ylabel(ax(2), 'Optimal path index','FontSize', 20, 'FontName', 'Arial');
xlabel(ax(1),'$\lambda$','FontSize', 20, 'Interpreter', 'latex') % label x-axis
title(sprintf('$T=%.2f$', T'),'FontSize', 20, 'Interpreter', 'latex');
box on;
grid on;
export_fig('fig/network_effect_lambda', '-pdf','-transparent','-nocrop'); 



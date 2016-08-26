close all; clear all;
%close all biograph viewer
child_handles = allchild(0);
names = get(child_handles,'Name');
k = find(strncmp('Biograph Viewer', names, 15));
close(child_handles(k))

%% construct the transportation network
% # of nodes;
n_node = 4;
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

% scale = 100; %the scale, all postions are normerlized according to scale
% pos_x_node(1)=0.1; pos_y_node(1)=0.5*2; %source node
% pos_x_node(2)=0.5; pos_y_node(2)=0.7*2;
% pos_x_node(3)=1.5; pos_y_node(3)=0.73*2;
% pos_x_node(4)=1; pos_y_node(4)=0.1*2;
% pos_x_node(5)=0.8; pos_y_node(5)=0.4*2;
% pos_x_node(6)=1.9; pos_y_node(6)=0.5*2;

% pos_x_node = scale*pos_x_node;
% pos_y_node = scale*pos_y_node;
% 
% topology_obj.position_node = [pos_x_node,pos_y_node];


distance = zeros(n_node,n_node);
distance(1,2) = 100;
distance(1,3) = 100;
distance(2,4) = 100;
distance(3,4) = 100;
% for ii=1:n_node
%     for jj=1:n_node
%         dis = sqrt((pos_x_node(ii)-pos_x_node(jj))^2+(pos_y_node(ii)-pos_y_node(jj))^2);
%         distance(ii,jj)=dis;
%     end
% end

links = zeros(n_node,n_node);
links(1,2)=1;
links(1,3)=1;
links(2,4)=1;
links(3,4)=1;


topology_obj.links = links;
topology_obj.distance_link = links.*distance;


speed_min = 10*ones(n_node,n_node);
topology_obj.speed_min_link = topology_obj.links.*speed_min;

speed_max = 200*ones(n_node,n_node);
topology_obj.speed_max_link = topology_obj.links.*speed_max;


%coefa = 10*1e-5*rand(n_node,n_node).*links;
%coefa = zeros(n_node, n_node).*links;
%coefb = 10*1e-3*rand(n_node,n_node).*links;
%coefc = 5*1e-1*rand(n_node,n_node).*links; %have no effect
%coefc = zeros(n_node, n_node).*links;
%coefd = 10*1e-2*rand(n_node,n_node).*links;

coefa = zeros(n_node, n_node);
coefb = zeros(n_node, n_node);
coefc = zeros(n_node, n_node);
coefd = zeros(n_node, n_node);

%for path1: 1->2->4
coefb(1,2) =16*1e-4;
coefb(2,4) = coefb(1,2);
coefd(1,2) =  3;
coefd(2,4) = coefd(1,2);
coefc(1,2) = 0;
coefc(2,4) = coefc(1,2);

%for path2: 1->3->4
coefb(1,3) =  12*1e-4;
coefb(3,4) = coefb(1,3);
coefd(1,3) = 1;
coefd(3,4) = coefd(1,3);
coefc(1,3) = 0.06;
coefc(3,4) = coefc(1,3);
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

[t1,f1] = topology_obj.plot_total_fuel_time_function(1,2);
[t2,f2] = topology_obj.plot_total_fuel_time_function(1,3);
[lambda1, w1, tt1] = topology_obj.plot_new_weight_with_delay_price_function(1,2);
[lambda2, w2, tt2] = topology_obj.plot_new_weight_with_delay_price_function(1,3);

[f1_min, f1_min_idx] = min(f1);
f1_min_t1 = t1(f1_min_idx);
[f2_min, f2_min_idx] = min(f2);
f2_min_t2 = t2(f2_min_idx);
figure;
set(gca,'FontSize',20);
hold on;
plot(2*t1,2*f1, 'b', 'linewidth',3);
plot(2*t2,2*f2,'r', 'linewidth',3);
text(2*f1_min_t1-0.5, 2*f1_min+0.5, sprintf('(%.2f,%.2f)', 2*f1_min_t1, 2*f1_min), 'fontsize',20);
plot(2*f1_min_t1, 2*f1_min, 'gx', 'markersize', 12, 'linewidth', 3);
text(2*f2_min_t2-0.5, 2*f2_min+0.5, sprintf('(%.2f,%.2f)', 2*f2_min_t2, 2*f2_min),'fontsize',20);
plot(2*f2_min_t2, 2*f2_min, 'gx', 'markersize', 12, 'linewidth', 3);
legend('Path1: (1->2->4)', 'Path2: (1->3->4)');
xlabel('time');
ylabel('fuel cost');
xlim([2,8]);
hold off;
grid on;
box on;

for nn=1:length(lambda1)
    fuel_cost1(nn) = topology_obj.total_fuel_time_function(1,2,tt1(nn));
    delay_cost1(nn) = lambda1(nn)*tt1(nn);
end


for nn=1:length(lambda2)
    fuel_cost2(nn) = topology_obj.total_fuel_time_function(1,3,tt2(nn));
    delay_cost2(nn) = lambda2(nn)*tt2(nn);
end



% 
% 
% %topology_obj.plotAll();
% 
source = 1;
sink = 4;
T = 4.2;

all_paths = topology_obj.getAllPaths(source,sink);
n_path = length(all_paths);
fuel_path = zeros(n_path,1);
dual_path = zeros(n_path,1);
speed_path = cell(n_path,1);
t_path = cell(n_path,1);

for pp=1:n_path
    [fuel_path(pp), t_path{pp}, speed_path{pp}, dual_path(pp)] = optimizeSinglePath(source, sink, T, topology_obj, all_paths{pp}, 'cvx')
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
lambda_vec = 0:0.005:2;
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
% 
% figure;
% set(gca,'FontSize',20);
% hold on;
% plot(lambda_vec, total_time, 'k', 'linewidth',3);
% [ax, p1, p2] = plotyy(lambda_vec, dual_value_vec ,lambda_vec,opt_path_idx);
% set(p1, 'Linewidth', 3);
% set(p1, 'Color', 'r');
% set(p2, 'Linewidth', 3);
% set(p2, 'Color', 'b');
% set(ax,'FontSize',12);
% set(ax,{'ycolor'},{'r';'b'});
% %plot(max_dual_value_lambda,max_dual_value, 'gx', 'linewidth', 3, 'markersize', 12);
% plot(max_dual_value_lambda,total_time(max_dual_value_idx), 'gx', 'linewidth', 3, 'markersize', 12);
% text(max_dual_value_lambda,max_dual_value, sprintf('(%.2f, %.2f)',max_dual_value_lambda,max_dual_value));
% text(max_dual_value_lambda,total_time(max_dual_value_idx), sprintf('(%.2f, %.2f)',max_dual_value_lambda,total_time(max_dual_value_idx)));
% hold off;
% ylabel(ax(1), 'Dual value','FontSize', 20, 'FontName', 'Arial');
% ylabel(ax(2), 'Optimal path index','FontSize', 20, 'FontName', 'Arial');
% xlabel(ax(1),'$\lambda$','FontSize', 20, 'Interpreter', 'latex') % label x-axis
% title(sprintf('$T=%.2f$', T'),'FontSize', 20, 'Interpreter', 'latex');
% box on;
% grid on;
% export_fig('fig/network_effect_lambda', '-pdf','-transparent','-nocrop'); 




figure;
set(gca,'FontSize',20);
hold on;
plot(lambda_vec, dual_value_vec, 'go', 'linewidth',3);
[ax, p1, p2] = plotyy(lambda_vec, total_time ,lambda_vec,opt_path_idx);
set(p1, 'Linewidth', 3);
set(p1, 'Color', 'r');
set(p2, 'Linewidth', 3);
set(p2, 'Color', 'b');
set(ax,'FontSize',12);
set(ax,{'ycolor'},{'r';'b'});
%plot(max_dual_value_lambda,max_dual_value, 'gx', 'linewidth', 3, 'markersize', 12);
%plot(max_dual_value_lambda,total_time(max_dual_value_idx), 'gx', 'linewidth', 3, 'markersize', 12);
plot(lambda_vec, T*ones(size(lambda_vec,1)),'-k', 'linewidth', 3);
%text(max_dual_value_lambda,max_dual_value, sprintf('(%.2f, %.2f)',max_dual_value_lambda,max_dual_value));
text(max_dual_value_lambda,total_time(max_dual_value_idx), sprintf('(%.2f, %.2f)',max_dual_value_lambda,total_time(max_dual_value_idx)));
hold off;
ylabel(ax(1), 'Total travel time','FontSize', 20, 'FontName', 'Arial');
ylabel(ax(2), 'Optimal path index','FontSize', 20, 'FontName', 'Arial');
xlabel(ax(1),'$\lambda$','FontSize', 20, 'Interpreter', 'latex') % label x-axis
title(sprintf('$T=%.2f$', T'),'FontSize', 20, 'Interpreter', 'latex');
box on;
grid on;
export_fig('fig/network_effect_lambda', '-pdf','-transparent','-nocrop'); 



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
pos_y_node(1) = 0;
pos_y_node(2) = 100;
pos_y_node(3) = 200;
pos_y_node(4) = 400;
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
links(2,3)=1;
links(3,4)=1;
topology_obj.links = links;
topology_obj.distance_link = links.*distance;

speed_min = 10*ones(n_node,n_node);
speed_max = 100*ones(n_node,n_node);
topology_obj.speed_min_link = topology_obj.links.*speed_min;
topology_obj.speed_max_link = topology_obj.links.*speed_max;


%coefa = 10*1e-5*rand(n_node,n_node).*links;
coefa = zeros(n_node, n_node).*links;
coefb = 5*1e-3*rand(n_node,n_node).*links;
%coefc = 5*1e-1*rand(n_node,n_node).*links; %have no effect
coefc = zeros(n_node, n_node).*links;
coefd = 2*1e-2*rand(n_node,n_node).*links;

topology_obj.coef_a_link = coefa;
topology_obj.coef_b_link = coefb;
topology_obj.coef_c_link = coefc;
topology_obj.coef_d_link = coefd;

%topology_obj.plotTopology();
%topology_obj.plotAll();

source = 1;
sink = 4;
T = 10;

[sp_dist, sp_path] = topology_obj.getShortestPath(source, sink);
[sp_fuel_opt, sp_t_opt, sp_speed_opt, sp_dual_opt] = optimizeSinglePath(source, sink, T, topology_obj, sp_path, 'cvx');
%[sp_fuel_opt, sp_t_opt, sp_speed_opt, sp_dual_opt] = optimizeSinglePath(source, sink, T, topology_obj, sp_path, 'yalmip');

[w(1),t(1)] = topology_obj.new_weight_with_delay_price_function(1,2,sp_dual_opt);
[w(2),t(2)] = topology_obj.new_weight_with_delay_price_function(2,3,sp_dual_opt);
[w(3),t(3)] = topology_obj.new_weight_with_delay_price_function(3,4,sp_dual_opt);

sp_t_opt
t
sp_fuel_opt
dual_vale = sum(w) - sp_dual_opt*T





tic;
lambda_vec = 0:0.1:10
total_weight = zeros(length(lambda_vec),1);
total_time = zeros(length(lambda_vec),1);
for nn=1:length(lambda_vec)
    lambda = lambda_vec(nn);
    if(mod(lambda,1) <= 1e-10)
        lambda
    end
    [total_weight(nn), new_path, new_time] = topology_obj.getShortestPathWithNewWeight(source, sink, lambda);
    total_time(nn) = sum(sum(new_time));
end
toc;

idx = find(abs(lambda_vec-sp_dual_opt) <= 4*1e-2)
figure;
set(gca,'FontSize',20);
hold on;
plot(lambda_vec, total_time, 'linewidth', 3);
plot(lambda_vec(idx), total_time(idx), 'rx', 'linewidth', 3, 'markersize', 12);
xlabel('$\lambda$','FontSize', 20, 'Interpreter', 'latex');
ylabel('$\sum_{i=1}^{n} t^*_i (\lambda)$','FontSize', 20, 'Interpreter', 'latex');
title(sprintf('$n=%d, T=%d$', n_node-1, T),'FontSize', 20, 'Interpreter', 'latex');
hold off;
grid on;
box on;
export_fig('fig/single_path_effect_lambda', '-pdf','-transparent','-nocrop'); 


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

scale = 100e3; %the scale, all postions are normerlized according to scale
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
% topology_obj.crr_link = 0.02*links;
% topology_obj.grade_link = 0*links; %0 degree

%car tire of road http://www.tribology-abc.com/abc/cof.htm
%crr is between 0.01  to 0.035
% topology_obj.crr_link(3,6)=0.02;

% topology_obj.coef_a_link = 0.8*rand(n_node,n_node).*links;
% topology_obj.coef_b_link = 1000/40*rand(n_node,n_node).*links;
% topology_obj.coef_c_link = 1000*rand(n_node,n_node).*links; %have no effect
% topology_obj.coef_d_link = 0.2*rand(n_node,n_node).*links;
% 
% coefa = topology_obj.coef_a_link;
% coefb = topology_obj.coef_b_link;
% coefc = topology_obj.coef_c_link;
% coefd = topology_obj.coef_d_link;
% save('coef.mat','coefa','coefb','coefc','coefd');

load coef.mat;
topology_obj.coef_a_link = coefa;
topology_obj.coef_b_link = coefb;
topology_obj.coef_c_link = coefc;
topology_obj.coef_d_link = coefd;

topology_obj.plotTopology();

%% optimization
source = 1;
sink = 6;
T  = 7200;
%path = [1, 2, 5, 3, 6];

[dist_shortest_path, shortest_path] = topology_obj.getShortestPath( source, sink);
[dist_shortest_path2, t_shortest_path, speed_shortest_path, energy_shortest_path ] = optimizeSinglePath(source, sink, T, topology_obj, shortest_path);
%[x_opt, t_opt, energy_opt ] = optimizeGlobelNetwork(source, sink, T, topology_obj)


%find all s-t simple paths

[all_paths] = topology_obj.getAllPaths(source,sink);
n_path = length(all_paths);
dist_path = cell(n_path,1);
speed_path = cell(n_path,1);
t_path = cell(n_path,1);
energy_path = cell(n_path,1);

for pp=1:n_path
    [dist_path{pp}, speed_path{pp}, t_path{pp}, energy_path{pp} ] = optimizeSinglePath(source, sink, T, topology_obj, all_paths{pp});
end

energy_opt1 = energy_path{1};
path_opt1 = all_paths{1};
for pp=1:n_path
    if(energy_path{pp} < energy_opt1)
        energy_opt1 = energy_path{pp};
        path_opt1 = all_paths{pp};
    end
end
    
%% constructed network
n_N = 29;
for k=1:n_N
    N=k+1;
topology_obj_c = ConstructedTopology(topology_obj, source, sink, T, N);
topology_obj_c.constructLinkAndCost();
topology_obj_c.constructNodeLabel();
%topology_obj_c.plotTopology();
[energy_opt2, path_opt2, path_c_opt] = topology_obj_c.getShortestPath();
%topology_obj_c.highlightPath(path_c_opt);

% display(shortest_path);
% topology_obj.highlightPath(shortest_path);
% display(path_opt1);
% topology_obj.highlightPath(path_opt1);
% display(path_opt2);
% topology_obj.highlightPath(path_opt2);
% display(energy_opt1);
% display(energy_opt2);
energy_opt2_k(k) = energy_opt2;
end




figure;
set(gca,'FontSize',20);
hold on;
plot(2:n_N+1,energy_opt2_k/10^6, '-bo', 'Linewidth', 3);
plot(2:n_N+1,energy_opt1.*ones(n_N,1)/10^6, '-r', 'Linewidth', 3);
plot(2:n_N+1,energy_shortest_path.*ones(n_N,1)/10^6, '--g', 'Linewidth', 3);
hold off;
xlabel('N','FontSize', 20, 'FontName', 'Arial');
ylabel('Energy Cost (MJ)');
legend('Approximate', 'Optimal', 'Shortest Path');
xlim([1,n_N+1]);
set(gca, 'XTick', 0:5:n_N+1);
box on;
grid on;
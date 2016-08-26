close all; clear all;
%close all biograph viewer
child_handles = allchild(0);
names = get(child_handles,'Name');
k = find(strncmp('Biograph Viewer', names, 15));
close(child_handles(k))

%% construct the transportation network
% # of nodes;
n_node = 4;
topology_obj = Topology(n_node);
distance = 10*ones(n_node,n_node); %all links have unit distance
links = zeros(n_node,n_node);
links(1,2)=1;
links(1,3)=1;
%links(2,3)=1;
links(2,4)=1;
links(3,4)=1;

topology_obj.links = links;
topology_obj.distance_link = links.*distance;

%quradic cost ax^3+bx^2+cx +d = bx^2 + d
% topology_obj.coef_a_link = 0.*links;
% topology_obj.coef_b_link = 10*rand(n_node,n_node).*links;
% topology_obj.coef_c_link = 0.*links; %have no effect
% topology_obj.coef_d_link = 1*rand(n_node,n_node).*links;
% 
% coefa = topology_obj.coef_a_link;
% coefb = topology_obj.coef_b_link;
% coefc = topology_obj.coef_c_link;
% coefd = topology_obj.coef_d_link;
% save('coef_example2.mat','coefa','coefb','coefc','coefd');

load coef_example2.mat;
topology_obj.coef_a_link = coefa;
topology_obj.coef_b_link = coefb;
topology_obj.coef_c_link = coefc;
topology_obj.coef_d_link = coefd;

%calculate \tilde{t}_e and \tilde{C}_e
te_tilde = links;
Ce_tilde = links;
te_tilde(1,2)=distance(1,2)*sqrt(topology_obj.coef_b_link(1,2)/topology_obj.coef_d_link(1,2));
te_tilde(1,3)=distance(1,3)*sqrt(topology_obj.coef_b_link(1,3)/topology_obj.coef_d_link(1,3));
%te_tilde(2,3)=distance(2,3)*sqrt(topology_obj.coef_b_link(2,3)/topology_obj.coef_d_link(2,3));
te_tilde(2,4)=distance(2,4)*sqrt(topology_obj.coef_b_link(2,4)/topology_obj.coef_d_link(2,4));
te_tilde(3,4)=distance(3,4)*sqrt(topology_obj.coef_b_link(3,4)/topology_obj.coef_d_link(3,4));

Ce_tilde(1,2)=2*distance(1,2)*sqrt(topology_obj.coef_b_link(1,2)*topology_obj.coef_d_link(1,2));
Ce_tilde(1,3)=2*distance(1,3)*sqrt(topology_obj.coef_b_link(1,3)*topology_obj.coef_d_link(1,3));
%Ce_tilde(2,3)=2*distance(2,3)*sqrt(topology_obj.coef_b_link(2,3)*topology_obj.coef_d_link(2,3));
Ce_tilde(2,4)=2*distance(2,4)*sqrt(topology_obj.coef_b_link(2,4)*topology_obj.coef_d_link(2,4));
Ce_tilde(3,4)=2*distance(3,4)*sqrt(topology_obj.coef_b_link(3,4)*topology_obj.coef_d_link(3,4));


%topology_obj.plotTopology();

%path = [1, 2, 5, 3, 6];

%[dist_shortest_path, shortest_path] = topology_obj.getShortestPath( source, sink);
%[t_shortest_path, energy_shortest_path ] = optimizeSinglePath(source, sink, T, topology_obj, shortest_path);
%[x_opt, t_opt, energy_opt ] = optimizeGlobelNetwork(source, sink, T, topology_obj)

%find all s-t simple paths
%% optimization
source = 1;
sink = 4;
[all_paths] = topology_obj.getAllPaths(source,sink);
n_path = length(all_paths);
dist_path = cell(n_path,1);
speed_path = cell(n_path,1);
t_path = cell(n_path,1);
energy_path = cell(n_path,1);





n_T = 200;
sum_t_opt_n_T = zeros(n_T,1);
idx_path_opt_n_T = zeros(n_T,1);
energy_opt_n_T = zeros(n_T,1);
for T  = 1:n_T


for pp=1:n_path
    [dist_path{pp}, speed_path{pp}, t_path{pp}, energy_path{pp} ] = optimizeSinglePath(source, sink, T, topology_obj, all_paths{pp});
end

energy_opt1 = energy_path{1};
path_opt1 = all_paths{1};
t_opt1 = t_path{1};
speed_opt1 = speed_path{pp};
idx_path_opt1 =1;
for pp=1:n_path
    if(energy_path{pp} < energy_opt1)
        energy_opt1 = energy_path{pp};
        path_opt1 = all_paths{pp};
        t_opt1 = t_path{pp};
        speed_opt1 = speed_path{pp};
        idx_path_opt1 = pp;
    end
end

sum_t_opt_n_T(T) = sum(t_opt1);
idx_path_opt_n_T(T) = idx_path_opt1;
energy_opt_n_T(T) = energy_opt1;

%% constructed network
% N = 2;
% topology_obj_c = ConstructedTopology(topology_obj, source, sink, T, N);
% topology_obj_c.constructLinkAndCost();
% topology_obj_c.constructNodeLabel();
% topology_obj_c.plotTopology();
% [energy_opt2, path_opt2, path_c_opt] = topology_obj_c.getShortestPath();
% 
% 
% display(shortest_path);
% topology_obj.highlightPath(shortest_path);
 display(path_opt1);
 display(energy_opt1);
 display(t_opt1);
 display(te_tilde);
 display(Ce_tilde);
% topology_obj.highlightPath(path_opt1);
% display(path_opt2);
% topology_obj.highlightPath(path_opt2);
% display(energy_opt1);
% display(energy_opt2);
end

figure;
hold on;
%plot(1:n_T, sum_t_opt_n_T,'b');
%plot(1:n_T, idx_path_opt_n_T, 'r');
plot(1:n_T, energy_opt_n_T, 'g');
hold off

close all; clear all;
%close all biograph viewer
child_handles = allchild(0);
names = get(child_handles,'Name');
k = find(strncmp('Biograph Viewer', names, 15));
close(child_handles(k))
% # of nodes;
n_node = 4;
topology_obj = Topology(n_node);

distance = zeros(n_node,n_node);
distance(1,2) = 10e3; %100km
distance(1,3) = 10e3; %100km
distance(2,4) = 10e3; %100km
distance(3,4) = 10e3; %100km

links = zeros(n_node,n_node);
links(1,2)=1;
links(1,3)=1;
links(2,4)=1;
links(3,4)=1;

topology_obj.links = links;
topology_obj.distance_link = links.*distance;


topology_obj.coef_a_link = 0.*links;
topology_obj.coef_b_link = 0.*links;
topology_obj.coef_c_link = 0.*links; %have no effect
topology_obj.coef_d_link = 0.*links;

topology_obj.coef_a_link(1,2)=1;
topology_obj.coef_a_link(2,4)=1;
topology_obj.coef_d_link(1,2)=0;
topology_obj.coef_d_link(2,4)=0;

topology_obj.coef_b_link(1,3)=1;
topology_obj.coef_b_link(3,4)=20;
topology_obj.coef_d_link(1,2)=0;
topology_obj.coef_d_link(2,4)=0;

topology_obj.plotTopology();

source = 1;
sink = 4;
path1 = [1,2,4];
path2 = [1,3,4];

n_T = 10;
dist_T_path1 = cell(n_T,1);
speed_T_path1 = cell(n_T,1);
t_T_path1 = cell(n_T,1);
energy_T_path1 = cell(n_T,1);
t_T_sum_path1 = zeros(n_T,1);

dist_T_path2 = cell(n_T,1);
speed_T_path2 = cell(n_T,1);
t_T_path2 = cell(n_T,1);
energy_T_path2 = cell(n_T,1);
t_T_sum_path2 = zeros(n_T,1);

step = 1200;
for tt=1:n_T
    T = step*tt;
    [dist_T_path1{tt}, speed_T_path1{tt}, t_T_path1{tt}, energy_T_path1{tt} ] = optimizeSinglePath(source, sink, T, topology_obj, path1);
    t_T_sum_path1(tt) = sum(t_T_path1{tt});
    [dist_T_path2{tt}, speed_T_path2{tt}, t_T_path2{tt}, energy_T_path2{tt} ] = optimizeSinglePath(source, sink, T, topology_obj, path2);
    t_T_sum_path2(tt) = sum(t_T_path2{tt});
end


figure;
set(gca,'FontSize',20);
hold on;
plot(step*[1:n_T]/3600,cell2mat(energy_T_path1)/10e6, '-bo', 'Linewidth', 3);
plot(step*[1:n_T]/3600,cell2mat(energy_T_path2)/10e6, '-m^', 'Linewidth', 3);
hold off;
legend('Path 1', 'Path 2');
xlabel('Delay T (hours)','FontSize', 20, 'FontName', 'Arial');
ylabel('Energy (MJ)');
box on;
grid on;
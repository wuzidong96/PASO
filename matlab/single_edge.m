close all; clear all;
%close all biograph viewer
child_handles = allchild(0);
names = get(child_handles,'Name');
k = find(strncmp('Biograph Viewer', names, 15));
close(child_handles(k))
% # of nodes;
n_node = 2;
% # of links;
n_link = 1;

topology_obj = Topology(n_node);


distance = zeros(n_node,n_node);
distance(1,2) = 50e3; %100km

links = zeros(n_node,n_node);
links(1,2)=1;

topology_obj.links = links;
topology_obj.distance_link = links.*distance;
topology_obj.coef_a_link = 0.*links;
topology_obj.coef_b_link = 1.*links;
topology_obj.coef_c_link = 0.*links; %have no effect
topology_obj.coef_d_link = 20.*links;
topology_obj.plotTopology();

source = 1;
sink = 2;

n_T = 36;
dist_T = cell(n_T,1);
speed_T = cell(n_T,1);
t_T = cell(n_T,1);
energy_T = cell(n_T,1);
t_T_sum = zeros(n_T,1);

step = 600;
for tt=1:n_T
    T = step*tt;
    path = [1,2];
    [dist_T{tt}, speed_T{tt}, t_T{tt}, energy_T{tt} ] = optimizeSinglePath(source, sink, T, topology_obj, path);
    t_T_sum(tt) = sum(t_T{tt});
end


figure;
set(gca,'FontSize',20);
hold on;
plot(step*[1:n_T]/3600,t_T_sum/3600, '-bo', 'Linewidth', 3);
hold off;
xlabel('Delay T (hours)','FontSize', 20, 'FontName', 'Arial');
ylabel('Optimal Travel Time t (hours)');
box on;
grid on;
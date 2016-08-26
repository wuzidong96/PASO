close all; clear all;
%close all biograph viewer
child_handles = allchild(0);
names = get(child_handles,'Name');
k = find(strncmp('Biograph Viewer', names, 15));
close(child_handles(k))
% # of nodes;
n_node = 6;
% # of links;
n_link = 10;

topology_obj = Topology(n_node, n_link);

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
pos_x_node(1)=0.1; pos_y_node(1)=0.5; %source node
pos_x_node(2)=0.5; pos_y_node(2)=0.7;
pos_x_node(3)=1.5; pos_y_node(3)=0.73;
pos_x_node(4)=1; pos_y_node(4)=0.1;
pos_x_node(5)=0.8; pos_y_node(5)=0.4;
pos_x_node(6)=1.9; pos_y_node(6)=0.5;

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

topology_obj.links = links;
topology_obj.distance_link = links.*distance;
topology_obj.crr_link = links;
topology_obj.grade_link = links;

topology_obj.plotTopology();

source = 1;
sink = 6;
T  = 3600;
%path = [1, 2, 5, 3, 6];
 [dist, path] = topology_obj.getShortestPath( source, sink)
[t_opt, energy_opt ] = optimizeSinglePath(source, sink, T, topology_obj, path)
%[x_opt, t_opt, energy_opt ] = optimizeGlobelNetwork(source, sink, T, topology_obj)


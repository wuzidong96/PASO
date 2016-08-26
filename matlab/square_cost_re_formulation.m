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
% pos_x_node = zeros(n_node,1);
% pos_y_node = zeros(n_node,1);
%pos_z_node = zeros(n_node,1);

% % the network area [0, 100km] * [0, 100km] * [0, 500m] 
% x_max = 100e3;
% y_max = 100e3;
% z_max = 500;
% 
% pos_x_node = x_max*rand(n_node,1);
% pos_y_node = y_max*rand(n_node,1);
% pos_z_node = z_max*rand(n_node,1);

% scale = 100e3; %the scale, all postions are normerlized according to scale
% pos_x_node(1)=0.1; pos_y_node(1)=0.5*2; %source node
% pos_x_node(2)=0.5; pos_y_node(2)=0.7*2;
% pos_x_node(3)=1.5; pos_y_node(3)=0.73*2;
% pos_x_node(4)=1; pos_y_node(4)=0.1*2;
% pos_x_node(5)=0.8; pos_y_node(5)=0.4*2;
% pos_x_node(6)=1.9; pos_y_node(6)=0.5*2;
% 
% pos_x_node = scale*pos_x_node;
% pos_y_node = scale*pos_y_node;
% 
% topology_obj.position_node = [pos_x_node,pos_y_node];

% 
% distance = zeros(n_node,n_node);
% for ii=1:n_node
%     for jj=1:n_node
%         dis = sqrt((pos_x_node(ii)-pos_x_node(jj))^2+(pos_y_node(ii)-pos_y_node(jj))^2);
%         distance(ii,jj)=dis;
%     end
% end

distance = ones(n_node,n_node);

links = zeros(n_node,n_node);
links(1,2) = 1;
links(1,3) = 1;
links(2,4) = 1;
links(3,4) = 1;


topology_obj.links = links;
topology_obj.distance_link = links.*distance;

topology_obj.coef_a_link = zeros(n_node,n_node).*links;
topology_obj.coef_b_link = ones(n_node,n_node).*links;
topology_obj.coef_c_link = zeros(n_node,n_node).*links; %have no effect
topology_obj.coef_d_link = zeros(n_node,n_node).*links;

coefa = topology_obj.coef_a_link;
coefb = topology_obj.coef_b_link;
coefc = topology_obj.coef_c_link;
coefd = topology_obj.coef_d_link;


% problem input parameters
T = 2;
source = 1;
sink = 4;

cvx_begin
    variable x(topology_obj.n_node,topology_obj.n_node);
    variable xi;
    minimize(sum(sum(x.*topology_obj.distance_link)));
    subject to
        x >= 0; %speed m/s
        xi >= 0;
        %flow balance equation
        for vv=1:topology_obj.n_node
            sum(x(vv,:).*topology_obj.links(vv,:)) ...
            - sum(x(:,vv).*topology_obj.links(:,vv)) == xi*(double(vv == source) - double (vv == sink));
        end
        
        delay = 0;
        for ii=1:topology_obj.n_node
            for jj=1:topology_obj.n_node
                if(topology_obj.links(ii,jj) == 0)
                    x(ii, jj) == 0;
                else
                    delay = delay + topology_obj.distance_link(ii,jj).*inv_pos(x(ii,jj));
                end
            end
        end
        delay <= T;
cvx_end

x_opt = x.*topology_obj.links;
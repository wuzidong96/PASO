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

links = zeros(n_node, n_node);
links(1,2)=1;
links(1,3)=1;
links(2,4)=1;
links(3,4)=1;
topology_obj.links = links;
topology_obj.distance_link = 100*links;
% 
% distance = 100*rand(n_node,n_node);
% 
% links = distance >= 10;
% for ii=1:n_node
%     links(ii:end,ii) = 0;
% end
% topology_obj.links = links;
% topology_obj.distance_link = links.*distance;

speed_min = 10*ones(n_node,n_node);
speed_max = 100*ones(n_node,n_node);
topology_obj.speed_min_link = topology_obj.links.*speed_min;
topology_obj.speed_max_link = topology_obj.links.*speed_max;

% 
% %coefa = 10*1e-5*rand(n_node,n_node).*links;
% coefa = zeros(n_node, n_node).*links;
% coefb = 10*1e-3*rand(n_node,n_node).*links;
% %coefb = rand*links;
% %coefc = 5*1e-1*rand(n_node,n_node).*links; %have no effect
% coefc = zeros(n_node, n_node).*links;
% coefd = 10*1e-2*rand(n_node,n_node).*links;
% %coefd = rand*links;
% 
% 
% topology_obj.coef_a_link = coefa;
% topology_obj.coef_b_link = coefb;
% topology_obj.coef_c_link = coefc;
% topology_obj.coef_d_link = coefd;

topology_obj.coef_a_link = zeros(n_node, n_node);
topology_obj.coef_b_link = zeros(n_node, n_node);
topology_obj.coef_c_link = zeros(n_node, n_node);
topology_obj.coef_d_link = zeros(n_node, n_node);

topology_obj.coef_a_link(1,2)= 1/1000;
topology_obj.coef_a_link(2,4)= topology_obj.coef_a_link(1,2);
topology_obj.coef_a_link(1,3)= 1/1000;
topology_obj.coef_a_link(3,4)= topology_obj.coef_a_link(1,3);

topology_obj.coef_b_link(1,2)= -100/1000;
topology_obj.coef_b_link(2,4)= topology_obj.coef_a_link(1,2);
topology_obj.coef_b_link(1,3)= -80/1000;
topology_obj.coef_b_link(3,4)= topology_obj.coef_a_link(1,3);

topology_obj.coef_c_link(1,2)= 2500/1000;
topology_obj.coef_c_link(2,4)= topology_obj.coef_a_link(1,2);
topology_obj.coef_c_link(1,3)= 1600/1000;
topology_obj.coef_c_link(3,4)= topology_obj.coef_a_link(1,3);


topology_obj.plotTopology();

source = 1;
sink = n_node;
topology_obj.plot_total_fuel_time_function(1,2);
topology_obj.plot_total_fuel_time_function(1,3);
[x_ax1, y1_ax1, y2_ax1] = topology_obj.plot_new_weight_with_delay_price_function(1,2);
[x_ax2, y1_ax2, y2_ax2] = topology_obj.plot_new_weight_with_delay_price_function(1,3);

figure;
plot(x_ax1, y2_ax1-y2_ax2);

figure;
plot(x_ax1, y1_ax1-y1_ax2);

% tic;
% lambda_vec = 0:0.05:10;
% total_weight = zeros(length(lambda_vec),1);
% total_time = zeros(length(lambda_vec),1);
% old_path = [];
% do_find_a_jump = 0;
% for nn=1:length(lambda_vec)
%     lambda = lambda_vec(nn);
%     if(mod(lambda,1) <= 1e-10)
%         lambda
%     end
%     [total_weight(nn), new_path, new_time] = topology_obj.getShortestPathWithNewWeight(source, sink, lambda);
%     
%     if(~isempty(new_path))
%         total_time(nn) = sum(sum(new_time));
%     else
%         return;
%     end
%     
%     if(nn>1 && ~isequal(old_path, new_path))
%         display('find a jump!');
%         display(lambda);
%         display(old_path);
%         display(new_path);
%         do_find_a_jump = 1;
%     end
%     old_path = new_path;
% end
% toc;
% 
% if(do_find_a_jump == 1)
%     break;
% end
% 
% 
% figure;
% set(gca,'FontSize',20);
% hold on;
% plot(lambda_vec, total_time, 'linewidth', 3);
% xlabel('$\lambda$','FontSize', 20, 'Interpreter', 'latex');
% ylabel('$\delta(\lambda)$','FontSize', 20, 'Interpreter', 'latex');
% hold off;
% grid on;
% box on;


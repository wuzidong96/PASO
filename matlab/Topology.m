classdef Topology < handle
    %TOPOLOGY Class for transportation network topology
    
    properties (SetAccess = public, GetAccess = public)
        n_node;
        links; % link topology links(i,j) = 1 (0) means there is (not) a link from node i to node j.
        position_node; %the 2D coordinates of n_node, a n_node-by-2 matrixs (units: miles)
        distance_link; % n_node-by-n_node matrix (units: miles)

        speed_min_link; % minimal speed, n_node-by-n_node matraix (units: miles per hour)
        speed_max_link; % maximal speed, n_node-by-n_node matraix (units: miles per hour)
        
        %coef_a_link(ii,jj) = a, coef_b_link(ii,jj) = b, coef_c_link(ii,jj) = c,coef_d_link(ii,jj) = d,
        %means that the fuel-rate-speed fuction for link (ii,jj) is f(x)=ax^3 + bx^2 + cx + d
        %where  x (units: miles per hour) and f(x) (units: gallon per hour).
        coef_a_link; %n_node-by-n_node matrix (units: gallon-hour^2/mile^3)
        coef_b_link; %n_node-by-n_node matrix (units: gallon-hour/mile^2)
        coef_c_link; %n_node-by-n_node matrix (units: gallon per mile)
        coef_d_link; %n_node-by-n_node matrix (units: gallon per hour)
    end
    
    methods
        
        function  obj = Topology(n_node)
            %constructor function
            obj.n_node = n_node;
            obj.links = zeros(obj.n_node);
            obj.position_node = zeros(obj.n_node, 2);
            obj.distance_link = zeros(obj.n_node,obj.n_node);
            obj.speed_min_link = zeros(obj.n_node,obj.n_node);
            obj.speed_max_link = zeros(obj.n_node,obj.n_node);
            obj.coef_a_link = zeros(obj.n_node,obj.n_node);
            obj.coef_b_link = zeros(obj.n_node,obj.n_node);
            obj.coef_c_link = zeros(obj.n_node,obj.n_node);
            obj.coef_d_link = zeros(obj.n_node,obj.n_node);
        end
        
        %some useful functions 
        
        %edge-based fuel rate function f(x)=ax^3 + bx^2 + cx + d
        % power_speed_function(obj, i, j, v) is the fuel rate (units: gallon per hour) for
        % edge (i,j) with speed v (units: mile per hour)
        function ret = fuel_rate_speed_function(obj, edge_tail, edge_head, speed)
            if(obj.links(edge_tail, edge_head) ~= 1)
                error('not an edge');
            end
            if(speed < -1e-10)
                error('negative speed');
            end
            a = obj.coef_a_link(edge_tail, edge_head);
            b = obj.coef_b_link(edge_tail, edge_head);
            c = obj.coef_c_link(edge_tail, edge_head);
            d = obj.coef_d_link(edge_tail, edge_head);
            ret = a*speed^3 + b*speed^2 + c*speed + d;
        end
        
        %edge-based total fuel consumption function with respect to travel
        %time,  c(t) = f(D/t)*t where t (untis: hour) and c(t) (units:
        %gallon)
        function ret = total_fuel_time_function(obj, edge_tail, edge_head, travel_time)
            if(obj.links(edge_tail, edge_head) ~= 1)
                error('not an edge');
            end
            if(travel_time <= -1e-10)
                error('negative travel time');
            end
            dist = obj.distance_link(edge_tail,edge_head);
            fuel_rate = obj.fuel_rate_speed_function(edge_tail, edge_head, dist/travel_time);
            ret = fuel_rate*travel_time;
        end
        
        
        %re-defined weight of each edge, including the fuel cost and the
        %delay cost
        %lambda is the price per unit of delay
        % w(lambda) = min_{t in the rage} [c(t) + lambda*t]
        % TODO: improve the effiency according to derivative
        function [ret_weight, ret_time] = new_weight_with_delay_price_function(obj, edge_tail, edge_head, lambda)
            if(obj.links(edge_tail, edge_head) ~= 1)
                error('not an edge');
            end
            if(lambda < -1e-10)
                error('negative lambda');
            end
            
            dist = obj.distance_link(edge_tail,edge_head);
            speed_min = obj.speed_min_link(edge_tail,edge_head);
            speed_max = obj.speed_max_link(edge_tail,edge_head);
            t_min = dist/speed_max;
            t_max = dist/speed_min;
            t_vec = t_min:0.01:t_max;
            new_weight = zeros(length(t_vec),1);
            for nn = 1:length(t_vec)
                travel_time = t_vec(nn);
                total_fuel_cost = obj.total_fuel_time_function(edge_tail, edge_head, travel_time);
                new_weight(nn) = total_fuel_cost + lambda*travel_time;
            end
            [ret_weight, idx] = min(new_weight);
            ret_time = t_vec(idx);
        end
        
        %improve the effiency according to derivative
        function [ret_weight, ret_time] = new_weight_with_delay_price_function_derivative(obj, edge_tail, edge_head, lambda)
            if(obj.links(edge_tail, edge_head) ~= 1)
                error('not an edge');
            end
            if(lambda < -1e-10)
                error('negative lambda');
            end
            
            dist = obj.distance_link(edge_tail,edge_head);
            speed_min = obj.speed_min_link(edge_tail,edge_head);
            speed_max = obj.speed_max_link(edge_tail,edge_head);
            t_min = dist/speed_max;
            t_max = dist/speed_min;
            
            [f_t_min, g_t_min] = obj.new_weight_with_delay_price_function_derivative_base(edge_tail, edge_head, lambda, t_min);
            if(g_t_min >= 0)
                ret_time = t_min;
                ret_weight = f_t_min;
            else % the gradient at t_min is negative
                [f_t_max, g_t_max] = obj.new_weight_with_delay_price_function_derivative_base(edge_tail, edge_head, lambda, t_max);
                if(g_t_max <= 0) %the gradient at t_max is negative
                    ret_time = t_max;
                    ret_weight = f_t_max;
                else %the gradient at t_min is negative and the gradient at t_max is positve
                    %get the zero-gradient point
                    dist = obj.distance_link(edge_tail,edge_head);
                    a = obj.coef_a_link(edge_tail, edge_head);
                    b = obj.coef_b_link(edge_tail, edge_head);
                    c = obj.coef_c_link(edge_tail, edge_head);
                    d = obj.coef_d_link(edge_tail, edge_head);
                    syms x;
                    solx = solve(-2*a*dist^3/x^3 - b*dist^2/x^2 + d + lambda== 0, x, 'real', true );
                    solx_idx = find(double(solx) >= 0,1);
                    solx = solx(solx_idx);
                    if( solx >= t_min && solx <= t_max)
                        ret_time = solx;
                        [ret_weight,~] = obj.new_weight_with_delay_price_function_derivative_base(edge_tail, edge_head, lambda, ret_time);
                    else
                        error('something wrong');
                    end
                end
            end
        end
        
        %this provides the new-weight fuction for given travel time, with a gradient 
        function [f, g] = new_weight_with_delay_price_function_derivative_base(obj, edge_tail, edge_head, lambda, t)
            f = obj.total_fuel_time_function(edge_tail, edge_head, t) + lambda*t;
            dist = obj.distance_link(edge_tail,edge_head);
            a = obj.coef_a_link(edge_tail, edge_head);
            b = obj.coef_b_link(edge_tail, edge_head);
            c = obj.coef_c_link(edge_tail, edge_head);
            d = obj.coef_d_link(edge_tail, edge_head);
            g = -2*a*dist^3/t^3 - b*dist^2/t^2 + d + lambda;
        end
        
        function [x_ax, y_ax] = plot_fuel_rate_speed_function(obj,edge_tail, edge_head)
            if(obj.links(edge_tail, edge_head) ~= 1)
                error('not an edge');
            end
            speed_min = obj.speed_min_link(edge_tail,edge_head);
            speed_max = obj.speed_max_link(edge_tail,edge_head);
            speed_vec = speed_min:0.1:speed_max;
            fuel_rate = zeros(length(speed_vec),1);
            for nn=1:length(speed_vec)
                speed = speed_vec(nn);
                fuel_rate(nn) = obj.fuel_rate_speed_function(edge_tail, edge_head, speed);
            end
            
            figure;
            set(gca,'FontSize',20);
            hold on;
            plot(speed_vec,fuel_rate, '-b', 'Linewidth', 3);
            hold off;
            xlabel('Speed (mph)','FontSize', 20, 'FontName', 'Arial');
            ylabel('Fuel rate (gph)','FontSize', 20, 'FontName', 'Arial');
            title(sprintf('edge (%d,%d)', edge_tail, edge_head),'FontSize', 20, 'FontName', 'Arial');
            box on;
            grid on;
            
            %return the axis values
            x_ax = speed_vec;
            y_ax = fuel_rate;
        end
        
        function [x_ax, y_ax] = plot_total_fuel_time_function(obj,edge_tail, edge_head)
            if(obj.links(edge_tail, edge_head) ~= 1)
                error('not an edge');
            end
            dist = obj.distance_link(edge_tail,edge_head);
            speed_min = obj.speed_min_link(edge_tail,edge_head);
            speed_max = obj.speed_max_link(edge_tail,edge_head);
            t_min = dist/speed_max;
            t_max = dist/speed_min;
            t_vec = t_min:0.01:t_max;
            total_fuel = zeros(length(t_vec),1);
            for nn=1:length(t_vec)
                travel_time = t_vec(nn);
                total_fuel(nn) = obj.total_fuel_time_function(edge_tail, edge_head, travel_time);
            end
            
            figure;
            set(gca,'FontSize',20);
            hold on;
            plot(t_vec, total_fuel, '-b', 'Linewidth', 3);
            hold off;
            xlabel('Travel time (hour)','FontSize', 20, 'FontName', 'Arial');
            ylabel('Total fuel (gallon)','FontSize', 20, 'FontName', 'Arial');
            title(sprintf('edge (%d,%d)', edge_tail, edge_head),'FontSize', 20, 'FontName', 'Arial');
            box on;
            grid on;
            
            %return the axis values
            x_ax = t_vec;
            y_ax = total_fuel;
        end
        
        function [x_ax, y1_ax, y2_ax] = plot_new_weight_with_delay_price_function(obj,edge_tail, edge_head)
            if(obj.links(edge_tail, edge_head) ~= 1)
                error('not an edge');
            end
            lambda_vec = 0:1:1000;
            new_weight = zeros(length(lambda_vec),1);
            opt_travel_time = zeros(length(lambda_vec),1);
            for nn=1:length(lambda_vec)
                lambda = lambda_vec(nn);
                [new_weight(nn), opt_travel_time(nn)] = obj.new_weight_with_delay_price_function(edge_tail, edge_head, lambda);
            end
            figure;
            set(gca,'FontSize',20);
            hold on;
            [ax, p1, p2] = plotyy(lambda_vec, new_weight,lambda_vec,opt_travel_time);
            set(p1, 'Linewidth', 3);
            set(p1, 'Color', 'r');
            set(p2, 'Linewidth', 3);
            set(p2, 'Color', 'b');
            set(ax,'FontSize',12);
            set(ax,{'ycolor'},{'r';'b'});
            hold off;
            ylabel(ax(1), 'New weight','FontSize', 20, 'FontName', 'Arial');
            ylabel(ax(2), 'Optimal travel time (hour)','FontSize', 20, 'FontName', 'Arial');
            xlabel(ax(1),'$\lambda$','FontSize', 20, 'Interpreter', 'latex') % label x-axis
            title(sprintf('edge (%d,%d)', edge_tail, edge_head),'FontSize', 20, 'FontName', 'Arial');
            box on;
            grid on;
            
            %return the axis values
            x_ax = lambda_vec;
            y1_ax = new_weight; 
            y2_ax = opt_travel_time;
        end
        
        function plotAll(obj)
            for ii=1:obj.n_node
                for jj=1:obj.n_node 
                    if(obj.links(ii,jj) == 1)
                        obj.plot_fuel_rate_speed_function(ii,jj);
                        obj.plot_total_fuel_time_function(ii,jj);
                        obj.plot_new_weight_with_delay_price_function(ii,jj);
                    end
                end
            end               
        end
        
        function plotTopology(obj)
%             figure;
%             set(gca,'FontSize',12);
%             hold on;
%             plot(obj.position_node(:,1),obj.position_node(:,2),'ro','MarkerSize', 12);
%             for k=1:obj.n_node
%                 text(obj.position_node(k,1),obj.position_node(k,2),num2str(k),'FontSize',10, 'HorizontalAlignment', 'Center', 'Color', 'r')
%             end 
%             %plot the topology for cellular networks
%             %figure();
%             gplot(obj.links, obj.position_node, '-');
%             xlabel('x-axis');
%             ylabel('y-axis');
%             title(sprintf('%d Nodes',obj.n_node));
%          %   axis equal;
%             grid on;
%             hold off;
            %view(biograph(obj.links.*obj.distance_link,[],'ShowWeights','on'))
            label = cell(obj.n_node,1);
            for ii=1:obj.n_node
                label{ii} = sprintf('%d', ii);
            end
            %weigh is in untis of miles
%            bg = biograph(round(obj.links.*obj.distance_link/1000),label,'ShowWeights','on');
            bg = biograph(round(obj.links.*obj.distance_link),label,'ShowWeights','on');
            %set(bg.nodes, 'Shape','ellipse');
            set(bg.nodes, 'Shape','circle');
            set(bg.nodes, 'FontSize',20);
            set(bg.nodes, 'TextColor',[1 0 0]);
            set(bg.edges, 'LineWidth',2);
            set(bg.edges, 'LineColor', [0 0 1]);
            set(bg, 'EdgeFontSize', 12);
            
            view(bg);
        end
        
        %highlight a path
        function highlightPath(obj, path)
           
            label = cell(obj.n_node,1);
            for ii=1:obj.n_node
                label{ii} = sprintf('%d', ii);
            end
            for ii=1:length(path)
                idx = path(ii);
              %  label{idx} = sprintf('%d (Opt-%d)', idx,ii);
            end
            
            %weigh is in untis of km
            bg = biograph(round(obj.links.*obj.distance_link/1000),label,'ShowWeights','on');
            
             for ii=1:length(path)
                idx = path(ii);
                bg.nodes(idx).Shape='circle';
                bg.nodes(idx).color=[0,1,0];
             end
             
            set(bg.nodes, 'Shape','circle');
            set(bg.nodes, 'FontSize',20);
            set(bg.nodes, 'TextColor',[1 0 0]);
            set(bg.edges, 'LineWidth',2);
            set(bg.edges, 'LineColor', [0 0 1]);
            set(bg, 'EdgeFontSize', 12);
            
            view(bg)
        end
        
        function [dist, path] = getShortestPath(obj, s, t)
            [dist, path, pred] = shortestpath(biograph(obj.links.*obj.distance_link,[],'ShowWeights','on'),s,t);
        end
        
        %get teh shortest path with the new-defined weight
        %lambda is the price per unit of delay
        function [total_weight, path, time] = getShortestPathWithNewWeight(obj, s, t, lambda)
            new_weight = zeros(obj.n_node, obj.n_node);
            time = zeros(obj.n_node, obj.n_node);
            for ii=1:obj.n_node
                for jj=1:obj.n_node
                    if(obj.links(ii,jj) == 1)
                        [new_weight(ii,jj), time(ii,jj)] = obj.new_weight_with_delay_price_function(ii,jj,lambda);
                       % [new_weight(ii,jj), time(ii,jj)] = obj.new_weight_with_delay_price_function_derivative(ii,jj,lambda);
                    end
                end
            end
                    
            [total_weight, path, pred] = shortestpath(biograph(obj.links.*new_weight,[],'ShowWeights','on'),s,t);
            
        end
         function [n_hop, path] = getMinimalHop(obj, s, t)
            [n_hop, path, pred] = shortestpath(biograph(obj.links,[],'ShowWeights','on'),s,t);
        end
        
        function [all_paths_out] = getAllPaths(obj, s, t)
            all_paths = {};
            visited = [];
            %quite strange here! visited is sucessfully modified in each
            %recursion, just like pass by reference, but all_paths are not
            %sucessfully modified accordingly, still like pass by value
            %so I store the all_paths into the output and pass it in the
            %recursion invokation. Anyway, currently, it works!!
            [all_paths_out] = getAllPathsRecursive(obj, s, t, all_paths, visited);
           % all_paths_out = all_paths;
        end
        
        function [all_paths_out] = getAllPathsRecursive(obj, s, t, all_paths, visited)
            % code comes here
            if(s==t)
                visited(end+1) = t;
                disp(visited);
                all_paths{end+1} = visited;
                visited = visited(1:end-1);
                all_paths_out = all_paths;
            else
                %push s
                visited(end+1) = s;
                for ii=1:obj.n_node
                    if(obj.links(s,ii) == 1)
                        %find if ii exists on the visted
                        doExist = 0;
                        for jj=1:length(visited)
                            if(visited(jj) == ii)
                                doExist = 1;
                                break;
                            end
                        end
                        if(doExist == 0) 
                            [all_paths_out] = getAllPathsRecursive(obj, ii,t, all_paths, visited);
                            all_paths = all_paths_out;
                        end
                    end
                end
                %pop s
                visited = visited(1:end-1);
            end   
           % all_paths_out = all_paths;
        end
        
    end
        
end


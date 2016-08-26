classdef Topology < handle
    %TOPOLOGY Class for transportation network topology
  
    
    properties (SetAccess = public, GetAccess = public)
        n_node;
        %n_link;
        links; % link topology links(i,j) = 1 (0) means there is (not) a link from node i to node j.
        position_node; %the 2D coordinates of n_node, a n_node-by-2 matrixs
        distance_link; % n_node-by-n_node matrix
       % crr_link;  %n_node-by-n_node matrix
       % grade_link; %n_node-by-n_node matrix, in terms of degree, i.e., [0, 180]
        coef_a_link; %n_node-by-n_node matrix
        coef_b_link; %n_node-by-n_node matrix
        coef_c_link; %n_node-by-n_node matrix
        coef_d_link; %n_node-by-n_node matrix
        %coef_a_link(ii,jj) = a, coef_b_link(ii,jj) = b, coef_c_link(ii,jj) = c,coef_d_link(ii,jj) = d,
        %means that the power-speed fuction for link (ii,jj) is f(x)=ax^3 + bx^2 + cx + d
    end
    
    methods
        
        function  obj = Topology(n_node)
            %constructor function
            obj.n_node = n_node;
            %obj.n_link = n_link;
            obj.links = zeros(obj.n_node);
            obj.position_node = zeros(obj.n_node, 2);
            obj.distance_link = zeros(obj.n_node,obj.n_node);
%             obj.crr_link = zeros(obj.n_node,obj.n_node);
%             obj.grade_link = zeros(obj.n_node,obj.n_node);
            obj.coef_a_link = zeros(obj.n_node,obj.n_node);
            obj.coef_b_link = zeros(obj.n_node,obj.n_node);
            obj.coef_c_link = zeros(obj.n_node,obj.n_node);
            obj.coef_d_link = zeros(obj.n_node,obj.n_node);
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
            %weigh is in untis of km
            bg = biograph(round(obj.links.*obj.distance_link/1000),label,'ShowWeights','on');
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


classdef ConstructedTopology < handle
    %ConstructedTopology Class for transportation network topology
  
    
    properties (SetAccess = public, GetAccess = public)
        topology_obj; % the orginal underlaying transportation network
        source; %source node in topology_obj
        sink; %sink node in topology_obj
        T; % total time (constinous)
        N; % # of slots to be discretized, the resulted slot length is delta_t = T/N
        delta_t; %slot length, delta_t = T/N
        n_copy_v; %# of constructed nodes (copies) for each node in topology_obj, source/sink has only one copy
        copy_start_v; % node_start_v(ii) is the start index of the copies for node ii in topology_obj, means the minimal arrival time from source to ii
        copy_end_v;  % node_start_v(ii) is the start index of the copies for node ii in topology_obj, means the maximal arrival time such that ii can reach sink in N
        label_node_c; %lables of each node, in the form of idx-org_node-copy_idx, eg '10-2-8' means that the node idx in the constructed graph is 10
                      % which is related to the orignal network node 2 and
                      % the copy indx is 10, means the car reaches node 2
                      % by the end of slot 8
        label_node_c2; % org_node-copy_idx
        n_node_c; %# of constructed node
        links_c; %  links(i,j) = 1 (0) means there is (not) a link from node i to node j.
        cost_link_c; % n_node-by-n_node matrix
    end
    
    methods
        
        function  obj = ConstructedTopology(topology_obj, source, sink, T, N)
            %constructor function
            %construct the graph G^c in Fig. 3 in report
            obj.topology_obj = topology_obj;
            obj.source = source;
            obj.sink = sink;
            obj.T = T;
            obj.N = N;
            obj.delta_t = T/N;
            
            % the # of constructed nodes for each node in the original transportation
            % network
            obj.n_copy_v = zeros(obj.topology_obj.n_node,1);
            obj.copy_start_v = zeros(obj.topology_obj.n_node,1);
            obj.copy_end_v = zeros(obj.topology_obj.n_node,1);
            for ii=1:obj.topology_obj.n_node
                if(ii == obj.source)
                    %source node has only one copy, indexed by 0
                    obj.n_copy_v(ii)=1;
                    obj.copy_start_v(ii) = 0;
                    obj.copy_end_v(ii) = 0;
                elseif (ii == sink)
                    %                     %sink node has only one copy, indexed by N
                    %                     obj.n_copy_v(ii)=1;
                    %                     obj.copy_start_v(ii) = obj.N;
                    %                     obj.copy_end_v(ii) = obj.N;
                    
                    dist_source = topology_obj.getMinimalHop(source, ii);
                    obj.n_copy_v(ii)=N - dist_source + 1;
                    obj.copy_start_v(ii) = dist_source;
                    obj.copy_end_v(ii) = N;
                else
                    %intermidiate node has N-d(v,t)-d(s,v)+1  copiesm, indexed from
                    %d(s,v) to N-d(v,t)
                    dist_source = topology_obj.getMinimalHop(source, ii);
                    dist_sink = topology_obj.getMinimalHop(ii, sink);
                    obj.copy_start_v(ii) = dist_source;
                    obj.copy_end_v(ii) = N - dist_sink;
                    obj.n_copy_v(ii) = (N - dist_sink) - dist_source + 1;
                end
            end
            
            % there exists a virtual node
            obj.n_node_c = sum(obj.n_copy_v)+1;
            obj.label_node_c = cell(obj.n_node_c,1);
            obj.links_c = zeros(obj.n_node_c,obj.n_node_c);
            obj.cost_link_c = zeros(obj.n_node_c,obj.n_node_c);
        end
        
        function constructNodeLabel(obj)
            for ii=1:obj.n_node_c-1
                [org_node, copy_idx] = obj.getOrgNetworkFromIdx(ii);
                obj.label_node_c{ii} = sprintf('%d-%d-%d',ii,org_node,copy_idx);
                obj.label_node_c2{ii} = sprintf('%d(%d)',org_node,copy_idx);
            end
             obj.label_node_c{obj.n_node_c} = sprintf('d''');
             obj.label_node_c2{obj.n_node_c} = sprintf('d''');
        end
        
        function constructLinkAndCost(obj)
            %construct the links from the orignial transportation network
            %and also construct the cost for each link
            for ii=1:obj.n_node_c-1
                [org_node1, copy_idx1] = obj.getOrgNetworkFromIdx(ii);
                for jj=1:obj.n_node_c-1
                    if(jj == ii)
                        continue;
                    end
                    
                    %[org_node1, copy_idx1] = obj.getOrgNetworkFromIdx(ii);
                    [org_node2, copy_idx2] = obj.getOrgNetworkFromIdx(jj);
                    
                    if( obj.topology_obj.links(org_node1, org_node2) == 1 && copy_idx1 < copy_idx2)
                        obj.links_c(ii, jj) = 1;
                        a = obj.topology_obj.coef_a_link(org_node1,org_node2);
                        b = obj.topology_obj.coef_b_link(org_node1,org_node2);
                        c = obj.topology_obj.coef_c_link(org_node1,org_node2);
                        d = obj.topology_obj.coef_d_link(org_node1,org_node2);
                        dist = obj.topology_obj.distance_link(org_node1,org_node2);
                        n_slots = copy_idx2 - copy_idx1;
                        speed = dist/(n_slots*obj.delta_t);
                        power = a*speed^3 + b*speed^2 + c*speed + d;
                        obj.cost_link_c(ii,jj) = (n_slots*obj.delta_t)*power;
                    end
                end
                
                if(org_node1 == obj.sink)
                    obj.links_c(ii, obj.n_node_c) = 1;
                    % as long as the same is ok 
                    obj.cost_link_c(ii,obj.n_node_c) = 10^6;
                end
            end
        end
        
        function plotTopology(obj)
           % view(biograph(obj.links_c.*obj.cost_link_c,[],'ShowWeights','on'))
           %view(biograph(obj.links_c.*obj.cost_link_c,obj.label_node_c,'ShowWeights','off'))
           %weigh is in untis of km
           bg = biograph(round(obj.links_c.*obj.cost_link_c/10^6),obj.label_node_c2,'ShowWeights','on');
           set(bg.nodes, 'Shape','ellipse');
           set(bg.nodes, 'FontSize',20);
           set(bg.nodes, 'TextColor',[1 0 0]);
           set(bg.edges, 'LineWidth',2);
           set(bg.edges, 'LineColor', [0 0 1]);
           set(bg, 'EdgeFontSize', 8);
           view(bg)
        end
        
        
        
         %highlight a path
        function highlightPath(obj, path)
           
%             label = cell(obj.n_node_c,1);
%             for ii=1:obj.n_node_c
%                 label{ii} = sprintf('%d', ii);
%             end
%             for ii=1:length(path)
%                 idx = path(ii);
%               %  label{idx} = sprintf('%d (Opt-%d)', idx,ii);
%             end
%             
            %weigh is in untis of km
            bg = biograph(round(obj.links_c.*obj.cost_link_c/10^6),obj.label_node_c2,'ShowWeights','on');
            
             for ii=1:length(path)
                idx = path(ii);
                bg.nodes(idx).Shape='ellipse';
                bg.nodes(idx).color=[0,1,0];
             end
             
           set(bg.nodes, 'Shape','ellipse');
           set(bg.nodes, 'FontSize',20);
           set(bg.nodes, 'TextColor',[1 0 0]);
           set(bg.edges, 'LineWidth',2);
           set(bg.edges, 'LineColor', [0 0 1]);
           set(bg, 'EdgeFontSize', 8);
            
            view(bg)
        end
        
        
        function [dist, path, path_c] = getShortestPath(obj)
            source_idx = obj.getIdxFromOrgNetwork(obj.source, 0);
            %sink_idx = obj.getIdxFromOrgNetwork(obj.sink, obj.N);
            sink_idx = obj.n_node_c;
            [dist, path_c, pred] = shortestpath(biograph(obj.links_c.*obj.cost_link_c,[],'ShowWeights','on'),source_idx,sink_idx);
            for ii=1:length(path_c)-1
                idx = path_c(ii);
                [org_node, copy_idx] = obj.getOrgNetworkFromIdx(idx);
                path(ii) = org_node;
                fprintf('idx=%d, org_node=%d, copy_idx=%d\n', idx, org_node, copy_idx);
            end
        end
        
        function [idx] = getIdxFromOrgNetwork(obj, org_node, copy_idx)
            if (org_node < 1 || org_node > obj.topology_obj.n_node)
                error('Error org_node');
            end
            
            if( copy_idx < obj.copy_start_v(org_node) || copy_idx > obj.copy_end_v(org_node))
                error('Error copy_idx');
            end
            
            idx = sum(obj.n_copy_v(1:org_node-1)) + (copy_idx - obj.copy_start_v(org_node) + 1);
        end
        
        function [org_node, copy_idx] = getOrgNetworkFromIdx(obj,idx)
            if(idx < 1 || idx > obj.n_node_c-1)
                error('Error idx');
            end
            
            for ii=1:obj.topology_obj.n_node
                n_total = sum(obj.n_copy_v(1:ii));
                if(idx > n_total)
                    continue;
                else
                    org_node = ii;
                    copy_idx = obj.copy_end_v(org_node) - (n_total - idx);
                    break;
                end
            end
        end
        
    end
        
end


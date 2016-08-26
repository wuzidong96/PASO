function [x_opt, t_opt, energy_opt ] = optimizeGlobelNetwork(source, sink, T, topology_obj)
% solve the globel optimization problem, non convex, MIP, very hard t get
% the optimal solution

n_node = topology_obj.n_node;

x = binvar(n_node, n_node, 'full');
t = sdpvar(n_node, n_node, 'full');
Cons = [t > 0; t <= T];

for ii=1:n_node
    for jj=1:n_node 
        if (topology_obj.links(ii,jj) == 0)
            Cons = [Cons; x(ii,jj) == 0;];
            Cons = [Cons; t(ii,jj) == 0;];
        end
    end
end

src_temp = 0;
for ii=1:n_node
    if(topology_obj.links(source,ii) == 1)
        src_temp = src_temp + x(source, ii);
    end
end
Cons = [Cons; src_temp == 1];

sink_temp = 0;
for ii=1:n_node
    if(topology_obj.links(ii,sink) == 1)
        sink_temp = sink_temp + x(ii, sink);
    end
end
Cons = [Cons; sink_temp == 1];

for ii=1:n_node
    if(ii == source || ii == sink)
        continue;
    end
    inflow_temp = 0;
    outflow_temp = 0;
    for jj=1:n_node
        if(topology_obj.links(ii,jj) == 1)
            outflow_temp = outflow_temp + x(ii,jj);
        end
        if(topology_obj.links(jj,ii) == 1)
            inflow_temp = inflow_temp + x(jj,ii);
        end
    end
    Cons = [Cons; outflow_temp == inflow_temp];
end

Cons = [Cons; sum(sum(x.*t)) <= T];

Obj = 0;
for ii=1:n_node
    for jj=1:n_node
        if(topology_obj.links(ii,jj) == 1)
            speed = topology_obj.distance_link(ii,jj)/t(ii,jj);
            Obj = Obj + x(ii,jj)*t(ii,jj)*speed^2; %power-speed function comes here
        end
    end
end

Ops = sdpsettings;
Ops.solver = 'bmibnb';
Ops.bmibnb.maxiter = 10;
% Ops.solver = 'gurobi';
% Ops.showprogress = 1;
 Ops.verbose = 2;
% Ops.allowmilp = 1;
% Ops.savesolverinput = 1;
% Ops.savesolveroutput = 1;
% Ops.gurobi.MIPFocus = 1;
% Ops.gurobi.NodefileStart = 0.01;
% %Ops.gurobi.TimeLimit = 300; % runtime <= 20;
% Ops.gurobi.MIPGap = 0.05; % (UB-LB)/UB <= 0.1;
% Ops.gurobi.MIPGapAbs = 1;  % UB-LB <= 10% C_ub;
% Ops.gurobi.Heuristics = 0.2; % 20% of runtime spent in MIP heuristics.
% Ops.gurobi.Presolve = 2; %agrressive
% Ops.gurobi.Method = 3; %3=concurrent root 

fprintf('Begin to solve\n');
tic;
Diag = solvesdp(Cons, Obj, Ops);
fprintf('Elapsed time to solve: %d\n', toc);

if Diag.problem == 0
    disp('Feasible')
elseif Diag.problem == 1
    disp('Infeasible')
else
    disp('Something else happened')
end

x_opt = value(x);
t_opt = value(t);
energy_opt = value(Obj);

end
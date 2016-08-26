function [dist, speed_opt, t_opt, energy_opt ] = optimizeSinglePath(source, sink, T, topology_obj, path)
% path = (source, v1, v2, ..., sink)

if(path(1) ~= source || path(end) ~= sink)
    fprintf('Wrong Path\n');
    return;
end

for ii=1:length(path)-1
    if(topology_obj.links(path(ii), path(ii+1)) ~= 1)
        fprintf('Not A Path\n');
        return;
    end
end

n_edge = length(path)-1;

t = sdpvar(n_edge,1);
Cons = [t > 0; t <= T; sum(t) <=T];
Obj = 0;

%the following parameters are found Fred L. Mannering's book
% "principles of highway engineering and traffic analysis"
% see example 2.1 in page 12
% rho = 1.2256; %air density kg/m^3
% Cd = 0.38; % drage coefficient unitless
% Af = 2; % frontal area m^2
% a3 = 0.5*rho*Cd*Af %factore for v^3
% G = 100e3; % weight = m*g, large truck, 10ton, N
dist = zeros(n_edge,1);
for ee=1:n_edge
    tail = path(ee);
    head = path(ee+1);
    dist(ee) = topology_obj.distance_link(tail,head);
    speed = dist(ee)/t(ee);
    %crr = topology_obj.crr_link(tail,head);
    %grade = topology_obj.grade_link(tail,head);
    %a1 = (crr*cos(grade/180*pi)+ sin(grade/180*pi))*G
    %a3 = rand();
    %a2 = 1;
    %a0 = 1;
    a = topology_obj.coef_a_link(tail,head);
    b = topology_obj.coef_b_link(tail,head);
    c = topology_obj.coef_c_link(tail,head);
    d = topology_obj.coef_d_link(tail,head);    
    power = a*speed^3 + b*speed^2 + c*speed + d;
    Obj = Obj + t(ee)*power;  %% power-speed function is here
end

Ops = sdpsettings;
%Ops.solver = 'bmibnb';
%Ops.bmibnb.maxiter = 100;
% Ops.solver = 'gurobi';
% Ops.showprogress = 1;
% Ops.verbose = 2;
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

t_opt = value(t);
energy_opt = value(Obj);

speed_opt = zeros(n_edge,1);
for ee=1:n_edge
    tail = path(ee);
    head = path(ee+1);
    speed_opt(ee) = topology_obj.distance_link(tail,head)/t_opt(ee);
end

end
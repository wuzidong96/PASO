function [fuel_opt, t_opt, speed_opt, dual_opt ] = optimizeSinglePath(source, sink, T, topology_obj, path, method)
% path = (source, v1, v2, ..., sink)
% method = 'cvx' then use cvx to solve
% method = 'yalmip' then use yalmip to solve

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

%cvx
if(strcmp(method, 'cvx') == 1)
    cvx_begin
        %set variable 
        variable t(n_edge);
        dual variable lambda;

        %set objective
        Obj = 0;
        dist = zeros(n_edge,1);
        for ee=1:n_edge
            tail = path(ee);
            head = path(ee+1);
            dist = topology_obj.distance_link(tail,head);
            a = topology_obj.coef_a_link(tail,head);
            b = topology_obj.coef_b_link(tail,head);
            c = topology_obj.coef_c_link(tail,head);
            d = topology_obj.coef_d_link(tail,head);    

            %something wrong here!
       %     fuel_rate = a*pow_pos(speed,3) + b*pow_pos(speed,2) + c*speed + d;
         %   fuel_rate = polyval([a,b,c,d],speed);
            fuel = a*dist^3*pow_p(t(ee), -2) + b*dist^2*inv_pos(t(ee)) + c*dist + d*t(ee);
            Obj = Obj + fuel;  
        end
        minimize(Obj);

        %set constraints
        subject to
            lambda : sum(t) <= T;
            for ee=1:n_edge
                tail = path(ee);
                head = path(ee+1);
                dist = topology_obj.distance_link(tail,head);
                speed_min = topology_obj.speed_min_link(tail, head);
                speed_max = topology_obj.speed_max_link(tail, head);
                t_min = dist/speed_max;
                t_max = dist/speed_min;
                t(ee) >= t_min;
                t(ee) <= t_max;
            end
    cvx_end

    fuel_opt = double(Obj);
    t_opt = double(t);
    dual_opt = double(lambda);
    speed_opt = zeros(n_edge,1);
    for ee=1:n_edge
        tail = path(ee);
        head = path(ee+1);
        speed_opt(ee) = topology_obj.distance_link(tail,head)/t_opt(ee);
    end
%yalmip, use fmincon by default
elseif(strcmp(method, 'yalmip'))
    t = sdpvar(n_edge,1);
    Cons = [sum(t) <=T];
    for ee=1:n_edge
        tail = path(ee);
        head = path(ee+1);
        dist = topology_obj.distance_link(tail,head);
        speed_min = topology_obj.speed_min_link(tail, head);
        speed_max = topology_obj.speed_max_link(tail, head);
        t_min = dist/speed_max;
        t_max = dist/speed_min;
        Cons = Cons + [t_min <= t(ee) <= t_max];
    end

    Obj = 0;

    for ee=1:n_edge
        tail = path(ee);
        head = path(ee+1);
        dist = topology_obj.distance_link(tail,head);
        speed = dist/t(ee);
        a = topology_obj.coef_a_link(tail,head);
        b = topology_obj.coef_b_link(tail,head);
        c = topology_obj.coef_c_link(tail,head);
        d = topology_obj.coef_d_link(tail,head);    
        power = a*speed^3 + b*speed^2 + c*speed + d;
        Obj = Obj + t(ee)*power;  %% power-speed function is here
    end

    Ops = sdpsettings;
    % Ops.solver = 'bmibnb';
    % Ops.bmibnb.maxiter = 10e5;
    % Ops.solver = 'gurobi';

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
    fuel_opt = value(Obj);

    speed_opt = zeros(n_edge,1);
    for ee=1:n_edge
        tail = path(ee);
        head = path(ee+1);
        speed_opt(ee) = topology_obj.distance_link(tail,head)/t_opt(ee);
    end
    %cannot get the dual now!!!
    dual_opt = 0;
else
    error('wrong method');
end

end
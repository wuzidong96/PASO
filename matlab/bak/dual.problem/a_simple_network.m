clear all; close all;
t = 1:0.1:5;
c1 = 12./t;
c2 = 18./t;

T = 4;

lambda_vec = 0:0.001:5;
for nn=1:length(lambda_vec)
    lambda = lambda_vec(nn);
    f1 = c1 + lambda*t;
    f2 = c2 + lambda*t;
    [f1_min, i1_min] = min(f1);
    [f2_min, i2_min] = min(f2);
    t1_min(nn) = t(i1_min);
    t2_min(nn) = t(i2_min);
    dual_f1(nn) = -lambda*T + f1_min;    
    dual_f2(nn) = -lambda*T + f2_min;
end

[dual_f1_max, i1_max] = max(dual_f1)
lambda1_max = lambda_vec(i1_max)

[dual_f2_max, i2_max] = max(dual_f2)
lambda2_max = lambda_vec(i2_max)

figure;
hold on;
plotyy(lambda_vec, dual_f1, lambda_vec, t1_min);
hold off
title('path 1');
grid on;
box on;

figure;
hold on;
plotyy(lambda_vec, dual_f2, lambda_vec, t2_min);
hold off
grid on;
box on;
title('path 2');

clear all; close all;
t = 1:0.1:5;
ce = 12./t;

lambda1 = 0;
lambda2 = 0.1;
lambda3 = 0.2;

f1 = ce + lambda1*t;
f2 = ce + lambda2*t;
f3 = ce + lambda3*t;

[f1_min, i1] = min(f1)
[f2_min, i2] = min(f2)
[f3_min, i3] = min(f3)

t1_min = t(i1)
t2_min = t(i2)
t3_min = t(i3)


figure;
hold on;
plot(t,f1,'b');
plot(t,f2,'r');
plot(t,f3,'g');
legend('lambda=0', 'lambda=0.1', 'lambda=0.2');
hold off;
grid on;
box on;


T = 4;

lambda_vec = 0:0.001:15;
for nn=1:length(lambda_vec)
    lambda = lambda_vec(nn);
    f = ce + lambda*t;
    [f_min, i_min] = min(f);
    t_min(nn) = t(i_min);
    dual_f(nn) = -lambda*T + f_min;
end

[dual_f_max, i_max] = max(dual_f)
dual_max = lambda_vec(i_max)

figure;
hold on;
plotyy(lambda_vec, dual_f, lambda_vec, t_min);
hold off
grid on;
box on;

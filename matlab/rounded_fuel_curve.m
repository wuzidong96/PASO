%rounded curve to approximate a continuous fuel consumption function

clear all; close all;

t = 1:0.001:4;
c = 110./t;

V = 20;
n_max = 4;
d = min(floor(c/V)+1, n_max);

d_min = min(d);
d_max = max(d);
t_idx = zeros(d_max-d_min+1,1);
for nn=1:length(t_idx)
    [~, t_idx(nn)] = find(d == nn+d_min-1,1);
end


%scale it back
d = V*d;



figure;
set(gca,'FontSize',20);
hold on;
plot(t, c, '-b', 'linewidth', 3);
plot(t, d, '--r', 'linewidth', 3);
plot(t(t_idx), d(t_idx), 'go', 'linewidth', 3, 'Markersize', 12);
for nn=1:length(t_idx)
    if(t_idx(nn)==1)
        x_offset = 0.33;
    else
        x_offset =0;
    end
    text(t(t_idx(nn))+x_offset, d(t_idx(nn))-8, sprintf('(%.1f, %.0f)',t(t_idx(nn)), d(t_idx(nn))/V), ...
         'Fontsize', 20, 'HorizontalAlignment', 'center', 'color', 'k');
end
xlabel('$t_e$','FontSize', 20, 'Interpreter', 'latex');
ylabel('$c_e(t_e)$','FontSize', 20, 'Interpreter', 'latex');
legend('Original curve', 'Quantized curve', 'Representative points');
%title(sprintf('$V=%.2f, N=%d$', V, n_max),'FontSize', 20, 'Interpreter', 'latex');
hold off;
grid on;
box on;
export_fig('fig/rounded_fuel_curve', '-pdf','-transparent','-nocrop'); 



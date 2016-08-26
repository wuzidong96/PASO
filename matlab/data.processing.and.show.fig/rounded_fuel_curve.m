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
font_size = 24;
line_width = 4;
hold on;
[AX,H1,H2] = plotyy(t, c, t, d);
set(AX,{'ycolor'},{'b';'r'})  % Left color red, right color blue...
set(H1, 'linewidth', line_width);
set(H1, 'linestyle', '-');
set(H1, 'color', 'b');
set(H2, 'linewidth', line_width);
set(H2, 'linestyle', '--');
set(H2, 'color', 'r');
set(AX(1), 'YTick',[20 40 60 80 100 120]);
set(AX(2), 'YTick',[20 40 60 80 100 120]);
set(AX(2), 'YTickLabel',[1 2 3 4 5 6]);
set(AX(1), 'Fontsize', font_size);
set(AX(2), 'Fontsize', font_size);
xlim(AX(1),[1,4]);
ylim(AX(1), [20,120]);
ylim(AX(2), [20,120]);
xlabel(AX(1),'$t_e$','FontSize', font_size, 'Interpreter', 'latex');
ylabel(AX(1), '$c_e(t_e)$','FontSize', font_size, 'Interpreter', 'latex');
ylabel(AX(2), '$\tilde{c}_e(t_e)$','FontSize', font_size, 'Interpreter', 'latex');
legend('Original curve', 'Quantized curve', 'Representative points');
title(sprintf('$V=%.2f, N=%d$', V, n_max),'FontSize', font_size, 'Interpreter', 'latex');

H3 = plot(t(t_idx), d(t_idx), 'Parent', AX(1),'DisplayName','Original curve');
set(H3, 'linestyle', 'd');
set(H3, 'color', 'g');
set(H3, 'linewidth', line_width);
set(H3, 'marker', 'o');
set(H3,  'Markersize', 18);

%put legend
legend([H1;H2;H3], 'Original curve', 'Quantized curve', 'Representative points');

%put text
for nn=1:length(t_idx)
    if(t_idx(nn)==1)
        x_offset = 0.33;
    else
        x_offset =0;
    end
    text(t(t_idx(nn))+x_offset, d(t_idx(nn))-8, sprintf('(%.1f, %.0f)',t(t_idx(nn)), d(t_idx(nn))/V), ...
         'Fontsize', 20, 'HorizontalAlignment', 'center', 'color', 'k');
end
hold off;
box on;
export_fig('fig/rounded_fuel_curve', '-pdf','-transparent','-nocrop'); 



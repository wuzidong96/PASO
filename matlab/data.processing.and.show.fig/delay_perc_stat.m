%% get the simple average result
close all; clear all;
%plot it here
data = csvread('data/delay_perc.csv');

delay_increase_perc = data(:,1);
fuel_reduction = data(:, 2)*(-1)*100;

figure;
font_size = 18;
line_width = 2;
set(gca,'FontSize',font_size);
h=plot(delay_increase_perc, fuel_reduction, '-bo', 'Linewidth', line_width);
xlabel('Deadline Increase (%)','FontSize', font_size, 'FontName', 'Arial');
ylabel('Fuel Reduction (%)','FontSize', font_size, 'FontName', 'Arial');
set(gca,'XTick',delay_increase_perc(1):10:delay_increase_perc(end));
%set(h, 'fontsize', 18);
box on;
grid on;
export_fig('fig/delay_perc', '-pdf','-transparent','-nocrop');


%% get the boxplot result with more information
close all; clear all;

all_fuel_reduction = []
for perc=0:10:100
    data = csvread(sprintf('data/delay-perc/vector_%d.txt', perc));
    fuel_reduction = data*(-1)*100;
    all_fuel_reduction = [all_fuel_reduction, fuel_reduction];
end

figure;
font_size = 18;
line_width = 2;
set(gca,'FontSize',font_size);
bh=boxplot(all_fuel_reduction, 'notch','on', 'Labels',0:10:100);
set(bh,'linewidth',line_width);
set(gca,'FontSize',font_size);
h = findobj(gca, 'type', 'text');
set(h, 'FontSize', font_size);
%set(h,'VerticalAlignment', 'Middle');
xlabel('Deadline Increase (%)','FontSize', font_size, 'FontName', 'Arial');
ylabel('Fuel Reduction (%)','FontSize', font_size, 'FontName', 'Arial');
%set(gca,'XTick',0:10:100);
%set(h, 'fontsize', 18);
ylim([0,30]);
box on;
grid on;
export_fig('fig/delay_perc_boxplot', '-pdf','-transparent','-nocrop');

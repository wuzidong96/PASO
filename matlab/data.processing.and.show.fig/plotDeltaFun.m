clear all; close all;
all_data = csvread('data/delta_fun_4_22.csv');
lambda = all_data(:,1);
delta = all_data(:,2);

%idx for T=40
lambda_T_40 = lambda(449)
delta_T_40 = delta(449)

lambda_small = lambda(lambda >= 11 & lambda <= 12);
delta_samll = delta(lambda >= 11 & lambda <= 12);

max_lambda = 22;
idx = [lambda <= max_lambda];


figure1 = figure;
font_size = 22.4;
line_width = 3;
set(gca,'FontSize',font_size);
hold on;
plot(lambda(idx), delta(idx), '-b', 'Linewidth', line_width);
stem(lambda_T_40,delta_T_40, ':r', 'linewidth', line_width, 'markersize', 10);
plot(0:0.01:lambda_T_40,delta_T_40*ones(size(0:0.01:lambda_T_40)), ':r', 'linewidth', line_width);
text(lambda_T_40+0.5,delta_T_40+1.2, sprintf('(%.2f,40)', lambda_T_40) ,'FontSize', 18, 'FontName', 'Arial', 'HorizontalAlignment', 'center');
hold off;
xlabel('$\lambda$','FontSize', font_size, 'FontName', 'Arial', 'Interpreter', 'latex');
ylabel('$\delta(\lambda)$','FontSize', font_size, 'FontName', 'Arial','Interpreter', 'latex');
xlim([0,15]);
ylim([35,55]);
box on;
grid on;


% Create axes
axes2 = axes('Parent',figure1,...
    'Position',[0.519642857142857 0.492857142857143 0.351785714285714 0.390476190476191],...
    'FontSize',18);
hold(axes2,'all');

% Create plot
plot(lambda_small,delta_samll,'Parent',axes2,...
    'DisplayName','delta_samll vs lambda_small', ...
    'linewidth', 3);
box on;
grid on;


% Create ellipse
annotation(figure1,'ellipse',...
     [0.68459375 0.222186975862321 0.0755624999999999 0.0658499234303216],...
    'LineWidth',2,...
    'Color',[1 0 0]);

% Create arrow
annotation(figure1,'arrow',[0.7 0.6375],...
    [0.301380952380952 0.440476190476191],'LineWidth',2,'Color',[1 0 0]);



%export_fig(sprintf('fig/delta_fun'), '-pdf','-transparent','-nocrop');
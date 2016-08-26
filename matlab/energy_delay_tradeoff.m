close all; clear all;

D = 100000; %100km
speed_kph = 10:100; % in km/h  
speed = (1/3.6).*speed_kph;
t = D./speed; %travel time, in seconds
t_hour = t./3600; %travel time, in hours;
power = 20*speed.^2; % in watt
energy = t.*power; % in Joule
energy_mj = energy/10^6; % in MJ (megajoule)
%gasoline_energy_denstiy = 32.4; % in MJ/L
%gasoline_volume = energy_mj/gasoline_energy_denstiy; %in L (litre)

figure;
%set(gca,'FontSize',20);
%hold on;
[ax, p1, p2] = plotyy(speed_kph,t_hour,speed_kph,energy_mj);
set(p1, 'Linewidth', 3);
set(p1, 'Color', 'r');
set(p2, 'Linewidth', 3);
set(p2, 'Color', 'b');
set(ax,'FontSize',12);
set(ax,{'ycolor'},{'k';'k'}) 

%plot(speed_kph,t_hour, '-r', 'Linewidth', 3);
%plot(speed_kph,power/10e3, '-b', 'Linewidth', 3);
%plot(speed_kph,energy_mj, '-g', 'Linewidth', 3);
%plot(speed_kph,gasoline_volume, '-g', 'Linewidth', 3);

%hold off;
%legend('Travel Time/Delay (Hour)', 'Energy (MJ)');
%legend('Travel Time/Delay (Hour)', 'Power (kW)', 'Energy (MJ)');
%legend('Travel Time/Delay (Hours)', 'Gasolin Volume (Litres)');
%xlabel('Speed (km/h)','FontSize', 20, 'FontName', 'Arial');
ylabel(ax(1),'Travel Time/Delay (Hours)','FontSize', 12,'Color', 'r') % label left y-axis
ylabel(ax(2),'Energy (MJ)','FontSize', 12, 'Color', 'b' ) % label right y-axis
xlabel(ax(1),'Speed (km/h)','FontSize', 12) % label x-axis
grid off;
box on;

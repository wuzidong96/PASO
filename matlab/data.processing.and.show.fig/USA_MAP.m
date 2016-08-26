clear all; close all;
%get the five central lat and lon
lat1 = (50.0+45.0)/2.0;
lat2 = (45.0+40.0)/2.0;
lat3 = (40.0+35.0)/2.0;
lat4 = (35.0+30.0)/2.0;
lat5 = (30.0+25.0)/2.0;

lon1 = (-100.0-95.0)/2.0;
lon2 = (-95.0-90.0)/2.0;
lon3 = (-90.0-85.0)/2.0;
lon4 = (-85.0-80.0)/2.0;
lon5 = (-80.0-75.0)/2.0;
lon6 = (-75.0-70.0)/2.0;

central_lats(1)= lat1;
central_lats(2)= lat2;
central_lats(3)= lat3;
central_lats(4)= lat4;
central_lats(5)= lat5;
central_lats(6)= lat1;
central_lats(7)= lat2;
central_lats(8)= lat3;
central_lats(9)= lat4;
central_lats(10)= lat5;
central_lats(11)= lat1;
central_lats(12)= lat2;
central_lats(13)= lat3;
central_lats(14)= lat4;
central_lats(15)= lat2;
central_lats(16)= lat3;
central_lats(17)= lat4;
central_lats(18)= lat5;
central_lats(19)= lat2;
central_lats(20)= lat3;
central_lats(21)= lat4;
central_lats(22)= lat2;

central_lons(1)= lon1;
central_lons(2)= lon1;
central_lons(3)= lon1;
central_lons(4)= lon1;
central_lons(5)= lon1;
central_lons(6)= lon2;
central_lons(7)= lon2;
central_lons(8)= lon2;
central_lons(9)= lon2;
central_lons(10)= lon2;
central_lons(11)= lon3;
central_lons(12)= lon3;
central_lons(13)= lon3;
central_lons(14)= lon3;
central_lons(15)= lon4;
central_lons(16)= lon4;
central_lons(17)= lon4;
central_lons(18)= lon4;
central_lons(19)= lon5;
central_lons(20)= lon5;
central_lons(21)= lon5;
central_lons(22)= lon6;

lat_v = 30:5:45;
lon_v = -120:5:-70;

figure;
hold on;
latlim = [25 50];
lonlim = [-125 -65];

ax = usamap(latlim,lonlim);
%ax = usamap('conus');
set(ax, 'Visible', 'off');
setm(gca, 'fontsize', 15);
states = shaperead('usastatelo', 'UseGeoCoords', true);
names = {states.Name};
indexConus = 1:numel(states);
stateColor = [0.5 1 0.5];
oceanColor = [.5 .7 .9];
geoshow(ax, states(indexConus),'FaceColor', [0.5 1.0 0.5])
setm(ax, 'Frame', 'off', 'Grid', 'off',...
    'FFaceColor','black')
for i=1:22
    textm(central_lats(i), central_lons(i), sprintf('%d',i), 'Fontsize', 20, 'color', 'red', 'HorizontalAlignment', 'center');
end

for i=1:length(lat_v)
    lon_v_temp = linspace(-127,-65, 200);
    linem(lat_v(i).*ones(size(lon_v_temp)), lon_v_temp , '-b', 'LineWidth',2);
end
for i=1:length(lon_v)
    lat_v_temp  = linspace(25, 50, 200);
    linem(lat_v_temp, lon_v(i).*ones(size(lat_v_temp)), '-b', 'LineWidth',2);
end
hold off;
export_fig(sprintf('fig/usa_map'), '-pdf','-transparent','-nocrop');
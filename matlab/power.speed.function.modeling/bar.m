T=1:10
E=exp(1./T); % Define a dummy set of data
figure;
plot(T,E);
addTopXAxis('expression', '10-argu', 'xLabStr', 'z')
% Add a top axis
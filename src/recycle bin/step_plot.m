neurons_range       = 10:5:100;
trainset_sizes      = 100:50:2000;
[X, Y] = meshgrid(trainset_sizes, neurons_range);

figure
surf(X,Y,perf);

figure;
hold on;
for i = floor(m/2):m
    plot(neurons_range, squeeze(perf(:, i)));
end
ylim([0 1]);

figure
perff = mean(perf,2);
plot(neurons_range, perff);
x = 10:10:150;

figure;
hold on;
for i = floor(m/2):m
plot(x, squeeze(perf(:, i)));
end

figure
perff = mean(perf,2);
plot(x, perff);
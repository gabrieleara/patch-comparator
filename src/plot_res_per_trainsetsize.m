clear;

load('results.mat');

pattern = results.pattern;
with = pattern.with_filtering;
without = pattern.without_filtering;

m = length(pattern.undersampling);
n = length(pattern.trainset_sizes);

figure;
%subplot(1,2,1);
hold on;
for i = 1:n
    fprintf('i = %d, Trainset_size %d\n', i, pattern.trainset_sizes(i));
    for j = 1:m
        net = with(j,i);
        fprintf('\t j = %d, Best error: %d\n', j, net.best_error);
        % plot(net.neurons_range, net.mean_error);
        
        fig = plotroc(net.t, net.best_net(net.x));
        pause(0.5);
        close(fig);
    end
    pause(1);
end
% 
% subplot(1,2,2);
% hold on;
% for i = 1:m
%     for j = 1:n
%         net = without(i,j);
%         plot(net.neurons_range, net.mean_error);
%     end
% end
% ylim([0 1]);
% 
% pause;

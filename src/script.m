best_networks = train_networks(trainset, 'pattern', 'lab');
pattern = best_networks.pattern;
t = trainset.outputs;
t = t';
t = full(ind2vec(gadd(t,1)));
x = trainset.inputs.lab';
y = pattern.net(x);

%%

figure
plotconfusion(t,y);
figure
plotroc(t,y);
pattern.extra_data
perf = pattern.extra_data.mean_performances;
[~, m] = size(perf);
step_plot;
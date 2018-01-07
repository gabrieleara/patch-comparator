if ~exist('trainset', 'var')
   load('fast_eval_simple.mat'); 
end

%results = train_networks(trainset, {'fit'; 'pattern'}, 'spectra', true);

results = train_networks(trainset, {'fit'; 'pattern'}, 'lab', true);

save('results.mat', 'results');
%pattern = results.pattern;

%%
%{
x = pattern.extra_data.best_x;
t = pattern.extra_data.best_t;
y = pattern.extra_data.best_y;

%%

figure
plotconfusion(t,y);
pause;
figure
plotroc(t,y);
pause;
pattern.extra_data
perf = pattern.extra_data.mean_performances;
[~, m] = size(perf);
step_plot;
%}
function main(trainset, fname, interactive)

if nargin < 2
    fname = '../results.mat';
end

if nargin < 3
    interactive = false;
end

params.trainset_sizes   = 75:75:1500;   % 25:75:250;
params.neurons_range    = 2:1:20;      % 5:5:25;
params.num_training     = 15;

params.undersampling = 1;
params = generate_spectra_plotsdata(params);

[res, in, out]  = test_spectra(trainset, params);
best_net        = plot_results(res, in, out, params, interactive);

results.spectra{params.undersampling}   = res;
inputs.spectra{params.undersampling}    = in;
outputs.spectra{params.undersampling}   = out;
best_nets.spectra{params.undersampling} = best_net;

for i = 5:15:50
    params.undersampling = i;
    params = generate_spectra_plotsdata(params);
    
    [res, in, out]  = test_spectra(trainset, params);
    best_net        = plot_results(res, in, out, params, interactive);
    
    results.spectra{params.undersampling}   = res;
    inputs.spectra{params.undersampling}    = in;
    outputs.spectra{params.undersampling}   = out;
    best_nets.spectra{params.undersampling} = best_net;
end

params = generate_lab_plotsdata(params);
[res, in, out] = test_lab(trainset, params);
best_net = plot_results(res, in, out, params, interactive);

results.lab     = res;
inputs.lab      = in;
outputs.lab     = out;
best_nets.lab   = best_net;

% Sparse doesn't work for cells
% results.spectra     = sparse(results.spectra);
% inputs.spectra      = sparse(in.spectra);
% outputs.spectra     = sparse(out.spectra);
% best_nets.spectra   = sparse(best_nets.spectra);

% [res, in, out] = test_lab_final(trainset, params, best_dim)
% plot_results(res, in, out, params, interactive);

save(fname, 'results', 'inputs', 'outputs', 'best_nets');

end

function params = generate_spectra_plotsdata(params)
params.title            = ['Testing spectra with undersampling = ', mat2str(params.undersampling), '...'];

params.plotA.title      = ['Plotting error rates on the whole knowledge base\nusing spectra and undersampling = ', mat2str(params.undersampling), '...\nPress any key to close and continue...\n'];
params.plotA.xlabel     = 'Dimension of the hidden layer';
params.plotA.ylabel     = 'Training set size';
params.plotA.zlabel     = 'Mean error rate on the training set';

params.plotA.fname      = ['../fig/spectra_und', mat2str(params.undersampling), '_A.fig'];

params.plotB.title      = ['Plotting error rates on the whole knowledge base\nfor different training set sizes\nusing spectra and undersampling = ', mat2str(params.undersampling),'...\nPress any key to close and continue...\n'];
params.plotB.xlabel     = 'Training set size';
params.plotB.ylabel     = 'Best error rate on the whole knowledge base';

params.plotB.fname      = ['../fig/spectra_und', mat2str(params.undersampling), '_B.fig'];

params.plotC.title      = ['Plotting ROC analysis for the best network obtained\nusing spectra and undersampling = ', mat2str(params.undersampling),'...\nPress any key to close and continue...\n'];

params.plotC.fname      = ['../fig/spectra_und', mat2str(params.undersampling), '_C.fig'];
end

function params = generate_lab_plotsdata(params)
params.title            = 'Testing labs with various sizes...';

params.plotA.title      = 'Plotting mean error rates on the training set using labs...\nPress any key to close and continue...\n';
params.plotA.xlabel     = 'Dimension of the hidden layer';
params.plotA.ylabel     = 'Training set size';
params.plotA.zlabel     = 'Mean error rate on the training set';

params.plotA.fname      = '../fig/lab_A.fig';

params.plotB.title      = 'Plotting error rates on the whole knowledge base\nfor different training set sizes using labs...\nPress any key to close and continue...\n';
params.plotB.xlabel     = 'Training set size';
params.plotB.ylabel     = 'Best error rate on the whole knowledge base';

params.plotB.fname      = '../fig/lab_B.fig';

params.plotC.title      = 'Plotting ROC analysis for the best network obtained using labs...\nPress any key to close and continue...\n';

params.plotC.fname      = '../fig/lab_C.fig';
end


function [res, in, out] = test_spectra(trainset, params)
[in, out] = select_input(trainset.inputs, trainset.outputs, 'spectra', Inf, params.undersampling, false);

res = eval_networks(in, out, params);
end

function [res, in, out] = test_lab(trainset, params)
[in, out] = select_input(trainset.inputs, trainset.outputs, 'lab', Inf);

res = eval_networks(in, out, params);
end

function [res, in, out] = test_lab_final(trainset, params, dim)
[in, out] = select_input(trainset.inputs, trainset.outputs, 'lab', dim);

res = eval_networks(in, out, params);
end

function res = eval_networks(in, out, params)

trainset_sizes  = params.trainset_sizes;
neurons_range   = params.neurons_range;
num_training    = params.num_training;

waitbar_total   = length(trainset_sizes);
waitbar_partial = 0;
waitbar_h       = waitbar(0, params.title);
screenSize      = get(0, 'ScreenSize');
movegui(waitbar_h,[screenSize(3)/2 - 150, screenSize(4)/2 + 104]);

for i = length(trainset_sizes):-1:1
    train_size = trainset_sizes(i);
    
    idxs = randsample(1:length(out), train_size, false);
    
    inputs  = in(idxs, :);
    outputs = out(idxs, :);
    
    trained_data(i) = ...
                train_net(inputs, outputs, neurons_range, num_training, 'pattern');
    
    % Updating waitbar content, it will abort any operation if the
    % waitbar has been closed.
    waitbar_partial = waitbar_partial+1;
    waitbar_update(waitbar_partial/waitbar_total, waitbar_h);
end

close(waitbar_h);

res = trained_data;

end

function [best_net, best_dim] = plot_results(res, in, out, params, interactive)

%% Plot A

x = in';
tind = out';

for i = length(params.trainset_sizes):-1:1
    for j = length(params.neurons_range):-1:1
        net = res(i).best_N_net{j};
        y = net(x);
        yind = vec2ind(y);
        best_error(i,j) = sum(tind ~= yind) / numel(tind);
    end
    
end

%for i = length(params.trainset_sizes):-1:1
%    mean_error(i, :) = res(i).mean_error;
%end

fprintf('\n\n');
fprintf(params.plotA.title);

fig = figure;
[X, Y] = meshgrid(params.neurons_range, params.trainset_sizes);
%surf(X, Y, mean_error);
surf(X, Y, best_error);
zlim([0 1]);
xlabel(params.plotA.xlabel);
ylabel(params.plotA.ylabel);
zlabel(params.plotA.zlabel);

if ~exist('../fig', 'dir')
    mkdir('../fig');
end

savefig(fig,params.plotA.fname);
if interactive
    pause;
end

if ishandle(fig)
    close(fig);
end


%% Plot B

x = in';
tind = out';

best_error = [];

for i = length(params.trainset_sizes):-1:1
    net = res(i).best_net;
    y = net(x);
    yind = vec2ind(y);
    best_error(i) = sum(tind ~= yind) / numel(tind);
end

fprintf('\n\n');
fprintf(params.plotB.title);

fig = figure;
plot(params.trainset_sizes, best_error);
ylim([0 1]);
xlabel(params.plotB.xlabel);
ylabel(params.plotB.ylabel);

savefig(fig,params.plotB.fname);
if interactive
    pause;
end

if ishandle(fig)
    close(fig);
end

%% Plot C

[~,i] = min(best_error);
net = res(i).best_net;
y = net(x);
t = full(ind2vec(tind));

fprintf('\n\n');
fprintf(params.plotC.title);

fig = plotroc(t,y);

savefig(fig,params.plotC.fname);
if interactive
    pause;
end


if ishandle(fig)
    close(fig);
end

best_dim = params.trainset_sizes(i);
best_net = net;

end
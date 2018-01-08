%function [bestN, best_net, best_performance, mean_performances, best_trainsize, best_x, best_t, best_y] = ...
function [trained_data] = ...
        train_net(inputs, outputs, neurons_range, num_training, nettype, trainset_sizes)

%EVALUATE_MLP	Evaluates the best MLP network size N for the given problem.
%
%   bestN = EVALUATE_MLP(inputs, outputs, neurons_range, num_training)
%       returns the best network size inside neurons_range for the given
%       problem. To do so, it trains num_traning different networks for
%       each network size.
%
%   [bestN, mean_performances] = EVALUATE_MLP(___)
%       returns both the best network size and an array of performance
%       evalutations, one for each network size. Values in performances are
%       obtained by averaging performance evaluations of each trained
%       networks of the same size.
%
%   [bestN, mean_performances, mean_regressions] = EVALUATE_MLP(___)
%       returns the best network size, an array of performance
%       evalutations and mean regression values, one for each network size.
%       Values in regressions are obtained by averaging regression
%       evaluations of each trained networks of the same size.
%
%   [___, performances] = EVALUATE_MLP(___)
%       returns also all the performances of each network that has been
%       trained.
%
%   [___, performances, regressions] = EVALUATE_MLP(___)
%       returns also all the regressions of each network that has been
%       trained.
%
%   NOTICE: input and output samples shall be one sample per row.
%
%   See also EVALUATE, EVALUATE_RBF.
%

% Variables used to update the waitbar
waitbar_total   = length(neurons_range)*num_training*length(trainset_sizes);
waitbar_partial = 0;
waitbar_h = waitbar(0, ['Training ' nettype ' networks...']);

% x are inputs, t are targets, one per column.
x = inputs';
t = outputs';

trained_data = [];

trained_data.best_net           = [];
trained_data.bestN              = -1;
trained_data.best_performance   = Inf;

neuro

if strcmp(nettype, 'pattern')
    % The generalized add because classes for me go from 0 to 5 
    num_labels = max(t);
    t = full(ind2vec(t));
    
    %t = full(ind2vec(gadd(t,1)));
    
    % Preallocation
    trained_data.areas_uc = zeros(length(neurons_range), length(trainset_sizes), num_training);
end

trained_data.x          = x;
trained_data.t          = t;


[~,m] = size(x);

if strcmp(nettype,'pattern')
    % The generalized add because classes for me go from 0 to 5 
    num_labels = max(t);
    t = full(ind2vec(t));
    
    %t = full(ind2vec(gadd(t,1)));
    
    % Preallocation
    areas_uc = zeros(length(neurons_range), length(trainset_sizes), num_training);
end

% Preallocation
performances = zeros(length(neurons_range), length(trainset_sizes), num_training);

% Placeholders for outputs
bestN               = -1;
best_net            = [];
best_performance    = inf;

xx = cell(length(trainset_sizes), 1);
tt = cell(length(trainset_sizes), 1);
ttind = cell(length(trainset_sizes), 1);

for k = 1:length(trainset_sizes)
    train_size = trainset_sizes(k);

    % Extract randomly a subset of the training set
    idxs = randsample(1:m, train_size, false);
    xx{k} = x(:, idxs);
    tt{k} = t(:, idxs);
    
    if strcmp(nettype,'pattern')
        ttind{k} = vec2ind(tt{k});
    end
end



% i = index of the number neurons in the current network
for i = 1:length(neurons_range)
    
    neurons_number = neurons_range(i);
    
    % Initializating the network
    net = init_net(neurons_number, nettype);
    
    for k = 1:length(trainset_sizes)
        
        train_size = trainset_sizes(k);
        
        x_ = xx{k};
        t_ = tt{k};
        
        if strcmp(nettype,'pattern')
            tind = ttind{k};
        end
    
        % j = counter of different trainings with the same network size
        for j = 1:num_training

            % Updating waitbar content, it will abort any operation if the
            % waitbar has been closed.
            waitbar_partial = waitbar_partial+1;
            waitbar_update(waitbar_partial/waitbar_total, waitbar_h);

            % Training the Network
            [net] = train(net, x_, t_);

            % Testing the Network
            y = net(x_);

            % Performance is evaluated on the whole training set
            if strcmp(nettype,'pattern')
                yind = vec2ind(y);
                performance = sum(tind ~= yind)/numel(tind); % Error rate
                
                % Notice: this doesn't take care of the fact that an output
                % "close" to the target may be "good" with respect to a
                % completely different one
                
                area_under_curve = 0;
                for posc = 1:num_labels
                    [~,~,~,auc] = perfcurve(t_,y,posc);
                    area_under_curve = area_under_curve + auc;
                end
                
                areas_uc(i, k, j) = area_under_curve;
                
                if performance < best_performance
                    bestN               = neurons_number;
                    best_trainsize      = train_size;
                    best_net            = net;
                    best_performance    = performance;
                    best_x              = x_;
                    best_t              = t_;
                    best_y              = y;
                    best_auc            = area_under_curve;
                end
            else
                performance = perform(net, t_, y);
                
                if performance < best_performance
                    bestN               = neurons_number;
                    best_trainsize      = train_size;
                    best_net            = net;
                    best_performance    = performance;
                    best_x              = x_;
                    best_t              = t_;
                    best_y              = y;
                end
            end

            % Saving data
            performances(i, k, j)  = performance;
        end
    end
end

% Obtaining mean performances for each network size and training size
mean_performances   = mean(performances, 3);

close(waitbar_h);

end


function net = init_net(neurons_number, nettype)
% INIT_NET Initializes a network to be trained in evaluate_mlp.
%
%   See also EVALUATE_MLP.

% TODO: Choose training function.
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainscg';

% Initialization
switch nettype
    case 'fit'
        net = fitnet(neurons_number, trainFcn);
    case 'pattern'
        net = patternnet(neurons_number, trainFcn);
    otherwise
        error('Unsupported network type!');
end

net.input.processFcns   = {'removeconstantrows','mapminmax'};

% Dividing the data
net.divideFcn   = 'dividerand';         % Divide data randomly
net.divideMode  = 'sample';             % Divide up every sample
net.divideParam.trainRatio  = 70/100;
net.divideParam.valRatio    = 15/100;
net.divideParam.testRatio   = 15/100;

% Disabling both prints on command line and window to show up
net.trainParam.showWindow       = false;
net.trainParam.showCommandLine  = false;

% TODO: Choose a Performance Function
% 'mae'          - Mean absolute error performance function.
% 'mse'          - Mean squared error performance function.
% 'sae'          - Sum absolute error performance function.
% 'sse'          - Sum squared error performance function.
% 'crossentropy' - Cross-entropy performance.
% 'msesparse'    - Mean squared error performance function with L2 weight and sparsity regularizers.
net.performFcn = 'crossentropy';  % Cross-Entropy

end
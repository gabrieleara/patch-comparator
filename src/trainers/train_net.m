function [bestN, best_net, best_performance, mean_performances] = ...
        train_net(inputs, outputs, neurons_range, num_training, nettype)

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
waitbar_total   = length(neurons_range)*num_training;
waitbar_partial = 0;
waitbar_h = waitbar(0, ['Training ' nettype ' networks...']);

% x are inputs, t are targets, one per column.
x = inputs';
t = outputs';

if strcmp(nettype,'pattern')
    % The generalized add because classes for me go from 0 to 5 
    t = full(ind2vec(gadd(t,1)));
end

% Preallocation
performances = zeros(length(neurons_range), num_training);

% Placeholders for outputs
bestN               = -1;
best_net            = [];
best_performance    = inf;

% i = index of the number neurons in the current network
for i = 1:length(neurons_range)
    
    neurons_number = neurons_range(i);
    
    % Initializating the network
    net = init_net(neurons_number, nettype);
    
    % j = counter of different trainings with the same network size
    for j = 1:num_training
        
        % Updating waitbar content, it will abort any operation if the
        % waitbar has been closed.
        waitbar_partial = waitbar_partial+1;
        waitbar_update(waitbar_partial/waitbar_total, waitbar_h);
        
        % Training the Network
        [net] = train(net, x, t);

        % Testing the Network
        y = net(x);
        
        % Performance is evaluated on the whole training set
        performance = perform(net, t, y);
        
        % Saving data
        performances(i, j)  = performance;
        
        if performance < best_performance
            bestN               = neurons_number;
            best_net            = net;
            best_performance    = performance;
        end
    end
end

% Obtaining mean performances for each network size
mean_performances   = mean(performances, 2);

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
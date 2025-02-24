%function [bestN, best_net, best_performance, mean_performances, best_trainsize, best_x, best_t, best_y] = ...
function [trained_data] = ...
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

neurons_len = length(neurons_range);

% Variables used to update the waitbar
waitbar_total   = neurons_len * num_training;
waitbar_partial = 0;
waitbar_h       = waitbar(0, ['Training ' nettype ' networks...']);

% x are inputs, t are targets, one per column.
x = inputs';
t = outputs';

trained_data = [];

trained_data.nettype        = nettype;
trained_data.neurons_range  = neurons_range;
trained_data.x              = x;
trained_data.t              = t;

trained_data.bestN      = -1;
trained_data.best_net   = [];
trained_data.best_perf  = Inf;

trained_data.best_N_net     = cell(neurons_len, 1);

if strcmp(nettype, 'pattern')
    num_labels      = max(t);
    tind            = t;
    t               = full(ind2vec(t));
    
    trained_data.t      = t;
    trained_data.tind   = tind;
    
    trained_data.best_error = Inf;
    trained_data.best_auc   = 0;
    
    % Preallocation
    errors      = inf(neurons_len, num_training);
    areas_uc    = inf(neurons_len, num_training);
end

% Preallocation
performances = inf(neurons_len, num_training);

% i = index of the number neurons in the current network
for i = 1:neurons_len
    
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
        performances(i,j)  = performance;

        % Additional computations for pattern recognition
        if strcmp(nettype,'pattern')
            % Notice: this doesn't take care of the fact that an output
            % "close" to the target may be "good" with respect to a
            % completely different one
            
            yind        = vec2ind(y);
            error_rate  = sum(tind ~= yind) / numel(tind);

            area_under_curve = 0;
            
            for posc = 1:num_labels
                [~,~,~,auc]         = perfcurve(tind,yind,posc);
                area_under_curve    = area_under_curve + auc;
            end
            
            area_under_curve            = area_under_curve / num_labels;
            
            areas_uc(i,j)  = area_under_curve;
            errors(i,j)    = error_rate;

            if error_rate < trained_data.best_error
                % Saving best data
                trained_data.bestN      = neurons_number;
                trained_data.best_net   = net;
                trained_data.best_perf  = performance;
                trained_data.best_error = error_rate;
                trained_data.best_auc   = area_under_curve;
            end
            
            if error_rate <= min(errors(i, :))
                trained_data.best_N_net{i} = net;
            end
        else
            if performance < trained_data.best_perf
                % Saving best data
                trained_data.bestN      = neurons_number;
                trained_data.best_net   = net;
                trained_data.best_perf  = performance;
            end
            
            if performance <= min(performances(i, :))
                trained_data.best_N_net{i} = net;
            end
        end
    end
end

% Obtaining mean performances for each network size and training size
trained_data.mean_perf = mean(performances, 2);

if strcmp(nettype,'pattern')
    trained_data.mean_auc   = mean(areas_uc, 2);
    trained_data.mean_error = mean(errors, 2);
end

close(waitbar_h);

end


function net = init_net(neurons_number, nettype)
% INIT_NET Initializes a network to be trained in evaluate_mlp.
%
%   See also EVALUATE_MLP.

% Choose training function.
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

% Choose a Performance Function
% 'mae'          - Mean absolute error performance function.
% 'mse'          - Mean squared error performance function.
% 'sae'          - Sum absolute error performance function.
% 'sse'          - Sum squared error performance function.
% 'crossentropy' - Cross-entropy performance.
% 'msesparse'    - Mean squared error performance function with L2 weight and sparsity regularizers.
if strcmp(nettype, 'fit')
    net.performFcn = 'mse';
else
    net.performFcn = 'crossentropy';
end

end
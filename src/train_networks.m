function [best_networks] = train_networks(trainset, nettype, traintype, deterministic)
%TRAIN_NETWORKS Summary of this function goes here
%   Detailed explanation goes here
if nargin < 3
    traintype = 'spectra';
end

if nargin < 4
    deterministic = false;
end

best_networks	= [];

nettype = cellstr(nettype);

[m,~] = size(nettype);

params = [];
params.neurons_range    = 10:10:150;
params.num_training     = 25;
params.trainset_sizes   = 100:50:1000;

for idx = 1:m
    if deterministic
        s = rng();
        rng(1234);
    end
    
    % TODO: add more data
    
    inputs  = select_input(trainset.inputs, traintype);
    outputs = trainset.outputs;

    [bestN, net, best_performance, mean_performances, best_trainsize] = ...
        train_net(inputs, outputs, ...
            params.neurons_range, ...
            params.num_training, ...
            nettype{idx}, ...
            params.trainset_sizes);

    extra_data = [];
    extra_data.bestN                = bestN;
    extra_data.best_trainsize       = best_trainsize;
    extra_data.mean_performances    = mean_performances;
    
    net_elem = create_net_elem(nettype, net, best_performance, extra_data);
    best_networks.(nettype{idx}) = net_elem;

    if deterministic
        rng(s);
    end
    
end

end

function [net_elem] = create_net_elem(netname, net, performance, extra_data)

net_elem = [];
net_elem.netname        = netname;
net_elem.net            = net;
net_elem.performance    = performance;
net_elem.extra_data     = extra_data;

end

function inputs = select_input(inputs,traintype, filter)
%SELECT_INPUT Summary of this function goes here
%   Detailed explanation goes here

inputs = inputs.(traintype);

if strcmp(traintype, 'spectra') && nargin > 2
    inputs_ = inputs;
    
    [n,m] = spectra;
    
    for i = 1:filter:
    
end

end
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
params.neurons_range    = 50:5:200;
params.num_training     = 50;
params.trainset_size    = 500; % TODO: extend to use also multiple trainset_sizes

for idx = 1:m
    if deterministic
        s = rng();
        rng(1234);
    end
    
    % TODO: add moar data
    
    inputs  = select_input(trainset.inputs, traintype);
    outputs = trainset.outputs;

    [bestN, net, best_performance, mean_performances] = ...
        train_net(inputs, outputs, ...
            params.neurons_range, ...
            params.num_training, ...
            nettype{idx});

    extra_data = [];
    extra_data.bestN               = bestN;
    extra_data.mean_performances   = mean_performances;
    
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

function inputs = select_input(inputs,traintype)
%SELECT_INPUT Summary of this function goes here
%   Detailed explanation goes here

inputs = inputs.(traintype);

end
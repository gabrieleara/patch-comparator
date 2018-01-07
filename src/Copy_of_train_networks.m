function [results] = train_networks(trainset, nettype, traintype, deterministic)
%TRAIN_NETWORKS Summary of this function goes here
%   Detailed explanation goes here
if nargin < 3
    traintype = 'spectra';
end

if nargin < 4
    deterministic = false;
end

results	= [];
results.trainset = trainset;

nettype = cellstr(nettype);

[m,~] = size(nettype);

params = [];
params.neurons_range    = 10:5:60;
params.num_training     = 25;
params.trainset_sizes   = 100:50:500;
params.unders           = 5:5:50;

% Quick evaluation: remove!
%{
params = [];
params.neurons_range    = 10:30:100;
params.num_training     = 3;
params.trainset_sizes   = 100:50:200;
params.unders           = 15:5:25;
%}


% Variables used to update the waitbar
waitbar_total   = m * length(params.unders) * length(params.trainset_sizes);
waitbar_partial = 0;
waitbar_h       = waitbar(0, 'Performing various trainings on different inputs...');

screenSize = get(0, 'ScreenSize');
movegui(waitbar_h,[screenSize(3)/2 - 187, screenSize(4)/2 + 104]);

for nettype_idx = 1:m
    
    if deterministic
        s = rng();
        rng(1234);
    end
    
    type_ = nettype{nettype_idx};
    
    nettype_data = [];
    nettype_data.nettype        = type_;
    nettype_data.undersampling  = params.unders;
    nettype_data.trainset_sizes = params.trainset_sizes;
    
    % Going backwards to preallocate struct matrix
    for unders_idx = length(params.unders):-1:1
        unders_ = params.unders(unders_idx);
    
        for trainset_idx = length(params.trainset_sizes):-1:1
            size_ = params.trainset_sizes(trainset_idx);
            
            % Updating waitbar content, it will abort any operation if the
            % waitbar has been closed.
            waitbar_partial = waitbar_partial+1;
            waitbar_update(waitbar_partial/waitbar_total, waitbar_h);
            
            % Filtering on
            % true = filtering on
            [inputs,outputs]  = select_input(trainset.inputs, trainset.outputs, traintype, size_, unders_, true);

            trained_data = ...
                train_net(inputs, outputs, params.neurons_range, params.num_training, type_);

            with_filtering(unders_idx, trainset_idx) = trained_data;

            % Filtering off
            % false = filtering off
            [inputs,outputs]  = select_input(trainset.inputs, trainset.outputs, traintype, size_, unders_, false);

            trained_data = ...
                train_net(inputs, outputs, params.neurons_range, params.num_training, type_);

            without_filtering(unders_idx, trainset_idx) = trained_data;
        end
    end
    
    nettype_data.with_filtering    = with_filtering;
    nettype_data.without_filtering = without_filtering;
    
    clear with_filtering without_filtering;
    
    results.(type_) = nettype_data;
    
    if deterministic
        rng(s);
    end
    
end

close(waitbar_h);
fprintf('Wow, it really completed!?');

end
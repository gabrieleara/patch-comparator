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

%{
params = [];
params.neurons_range    = 10:5:100;
params.num_training     = 25;
params.trainset_sizes   = 100:50:2000;
params.unders           = 5:5:50;
%}

% Quick evaluation: remove!
params = [];
params.neurons_range    = 10:30:100;
params.num_training     = 3;
params.trainset_sizes   = 100:50:200;
params.unders           = 15:5:25;



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

function [inputs,outputs] = select_input(inputs, outputs, traintype, train_size, unders, filter_)
%SELECT_INPUT Summary of this function goes here
%   Detailed explanation goes here

inputs  = inputs.(traintype);

[n, ~]  = size(inputs);
if train_size < n
    % Extract randomly a subset of the training set
    idxs = randsample(1:n, train_size, false);
    
    inputs  = inputs(idxs, :);
    outputs = outputs(idxs, :);
end

if strcmp(traintype, 'spectra') && nargin > 5 && filter_
    [m,n] = size(inputs);
    
    spectra = inputs(:, 1:n/2);
    perturbations = inputs(:, n/2+1:end);
    
    n = n/2;
    
    filtered_spectra    = zeros(m,n);
    filtered_pert       = zeros(m,n);
    
    w = 3;
    b = (1/w) * ones(1,w);
    a = 1;
    
    delay       = mean(grpdelay(b,a));
    filt_idxs   = delay*2+1:n;
    
    % wave_idxs = delay+1:length(wavelengths)-delay;
    % wave_ = wavelengths(wave_idxs);
    
    for i = 1:m
        filtered_spectra(i, :)  = filter(b,a, spectra(i, :));
        filtered_pert(i, :)     = filter(b,a, perturbations(i, :));
    end
    
    filt_s = filtered_spectra(:, filt_idxs);
    filt_p = filtered_pert(:, filt_idxs);
    
    inputs = [filt_s filt_p];
end

if strcmp(traintype, 'spectra') && nargin > 4 && unders > 1
    [m,n] = size(inputs);
    
    inputs_ = zeros(m, (floor(n/2 / unders)+1)*2);
    
    j = 1;
    for i = 1:unders:n/2
        inputs_(:, j) = inputs(:, i);
        j = j+1;
    end
    
    for i = n/2+1:unders:n
        inputs_(:, j) = inputs(:, i);
        j = j+1;
    end
    
    inputs = inputs_;
end

end
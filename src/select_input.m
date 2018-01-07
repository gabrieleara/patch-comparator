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
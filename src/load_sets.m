function [spectra, wavelengths, perturbations] = load_sets(arg1)

datafolder  = '../data/';
dataset     = strcat(datafolder, 'original_data.mat'); % dataset_filtered.mat

vars        = load(dataset, 'spectra', 'wavelengths');

% I now have 1232 spectra each with 421 values in a matrix called spectra
% and 421 wavelengths, one for each value of a spectrum in wavelengths:
%
% spectra       [1232 x 421]
% wavelengths   [421x1]
spectra     = vars.spectra;
wavelengths = vars.wavelengths;

perturbations   = strcat(datafolder, 'perturbations.mat');

Nperturbations = 0;

if nargin < 1
    if exist(perturbations, 'file')
        % Load from file
        perturbations   = load(perturbations);
        perturbations   = perturbations.perturbations;
    else
        Nperturbations  = 8;
    end 
else
    Nperturbations = arg1;
end
    

if Nperturbations
    perturbations       = generate_noise(spectra, Nperturbations);
end

end
function main(fromfile)

% load('../data/dataset_filtered.mat');

datafolder = '../data/';

dataset = strcat(datafolder, 'mod_dataset.mat'); % dataset_filtered.mat

loaded_variables = load(dataset, 'spectra', 'wavelengths');

spectra = loaded_variables.spectra;
wavelengths = loaded_variables.wavelengths;

% I now have 1232 spectra each with 421 values in a matrix called
%
% spectra [1232 x 421]

% And 421 wavelengths, one for each value of a spectrum in
%
% wavelengths [421x1]

% I need to generate 10 perturbated signals for each spectrum, I want them
% specified as
%                Nspectra Npert Nwavelengths
% perturbations = [1232 x 10 x 421]

[Nspectra, Nwavelengths] = size(spectra);
Nperturbations = 10;

if nargin > 0 && fromfile
    perturbationset = strcat(datafolder, 'perturbations.mat');
    
    perturbations = load(perturbationset);
    perturbations = perturbations.perturbations;
else
    perturbations = zeros(Nspectra, Nperturbations, Nwavelengths);

    for pertIdx = 1:Nperturbations
        db = pertIdx * 5 - 4;

        for spectrumIdx = 1:Nspectra

            perturbatedSig = awgn(spectra(spectrumIdx, :), db);

            perturbations(spectrumIdx, pertIdx, :) = perturbatedSig;
        end

    end
end

clear datafolder dataset perturbationset fromfile loaded_variables perturbatedSig db pertIdx spectrumIdx;

%%

fig = similarity_prompt(spectra, perturbations);

end

%% This section has been used to figure out how to handle perturbated signals

% Obtaining the 10 perturbations colors
% [xyz, rgb, lab, valid] = spectra2color(perturbatedSig(:, :, 1).');

% subplot(2, 2, 1);
% patch([0 1 1 0], [1 1 0 0], originalColor(:).');
% subplot(2, 2, 3);
% plot(wavelengths, spectra(:, 1));    
% 
% for i = 1:Nperturbations
%     j = Nperturbations -i +1;
%     
%     subplot(2, 2, 2);
%     patch([0 1 1 0], [1 1 0 0], rgb(:, j).');
%     subplot(2, 2, 4);
%     plot(wavelengths, perturbations(j, :, 1));
%     waitforbuttonpress
% end
% 
% close



%% This section has been used to figure out what happens when a perturbated
%  signal is not RGB-compatible, and how to possibly handle it

% j = 1;
% while(min(valid) > 0)
%     for i = 1:Nperturbations
%         perturbations(i, :, j) = awgn(spectra(:,1).', i * 5 - 4);
%         db = db * -5;
%     end
%     
%     [xyz, rgb, lab, valid] = spectra2color(perturbations(:, :, 1).');
% end
% 
% [~, j] = min(valid);
% 
% subplot(2, 2, 1);
% patch([0 1 1 0], [1 1 0 0], originalColor(:).');
% subplot(2, 2, 3);
% plot(wavelengths, spectra(:, 1));
% 
% rgb(rgb > 1) = 1;
% rgb(rgb < 0) = 0;
% 
% subplot(2, 2, 2);
% patch([0 1 1 0], [1 1 0 0], rgb(:, j).');
% subplot(2, 2, 4);
% plot(wavelengths, perturbations(j, :, 1));
% waitforbuttonpress
% 
% 
% close





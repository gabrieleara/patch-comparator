function perturbations = generate_noise(spectra, Nperturbations)

[Nspectra, Nwavelengths] = size(spectra);

% Preallocation
perturbations = zeros(Nspectra, Nperturbations, Nwavelengths);

% Precomputing labs to speed up performances
[~, ~, labs] = spectra2color(spectra);

a =      2.509;
b =      0.2639;

for pertIdx = 1:Nperturbations
    v = Nperturbations - pertIdx + 1;
    
    db  = a*exp(b*v);
    
    % This was meant to speed up, but heavier colors seem to suffer from
    % heavier noises, so I try to use a "color per color" approach
%     perturbatedSig = awgn(spectra, db);
%     for spectrumIdx = 1:Nspectra
%         perturbations(spectrumIdx, pertIdx, :) = perturbatedSig(spectrumIdx, :);
%     end

    % This is the alternative approach
    for spectrumIdx = 1:Nspectra
        
        % This is used to be more aggressive on lighter colors and less
        % aggressive on darker ones
        lab = squeeze(labs(:, spectrumIdx));
        actualdb = db * 1 / ((lab(1) / 100)^0.75);
        
        perturbatedSig = awgn(spectra(spectrumIdx, :), actualdb);
        perturbations(spectrumIdx, pertIdx, :) = perturbatedSig;
    end
end

end
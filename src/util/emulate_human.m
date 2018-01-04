function emulate_human(spectra, perturbations, fname, deltaeversion)
%EMULATE_HUMAN Summary of this function goes here
%   Detailed explanation goes here

[Nspectra, Nperturbations, ~] = size(perturbations);

Npairs  = Nspectra * Nperturbations;
pairs   = -ones(Npairs, 2);
ratings = -ones(Npairs, 1);

waitbar_total   = Npairs;

Npairs  = 0;

[~, ~, spectra_labs, spectra_valid] = spectra2color(spectra);

waitbar_partial = 0;
waitbar_h = waitbar(0, 'Emulating a very quick human...');

for i = 1:Nspectra
    spectrum_lab    = spectra_labs(:, i);
    valid           = spectra_valid(i);
    
    if valid
        for j = 1:Nperturbations
            [~, ~, pert_lab, valid] = pert2color(perturbations, i, j);
            
            % Updating waitbar content, it will abort any operation if the
            % waitbar has been closed.
            waitbar_partial = waitbar_partial+1;
            waitbar_update(waitbar_partial/waitbar_total, waitbar_h);
            
            if valid
                if nargin < 4
                    deltae = delta_e(spectrum_lab, pert_lab);
                else
                    deltae = delta_e(spectrum_lab, pert_lab, deltaeversion);
                end

                Npairs = Npairs+1;
                pairs(Npairs, :)    = [i j];
                ratings(Npairs)     = deltae2rating(deltae);
            end
        end
        
    end
end

close(waitbar_h);

idxs = ratings > -0.0001;

ratings = ratings(idxs);
pairs   = pairs(idxs, :);

save(fname, ...
        'spectra', 'perturbations', ...
        'ratings', 'pairs');

end


function rating = deltae2rating(deltae)
if deltae < 1.2
    rating = 5;
elseif deltae < 2.2
    rating = 4;
elseif deltae < 3.8
    rating = 3;
elseif deltae < 10
    rating = 2;
elseif deltae < 15
    rating = 1;
else
    rating = 0;
end
end
function [xyz, rgb, lab, valid] = pert2color(perturbations, spectrum_idx, pert_idx)

[xyz, rgb, lab, valid] = spectra2color(perturbations(spectrum_idx, pert_idx, :));

end


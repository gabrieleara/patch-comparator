function [xyz, rgb, lab, valid] = spectrum2color(spectra,idx)

[xyz, rgb, lab, valid] = spectra2color(spectra(idx, :));

end


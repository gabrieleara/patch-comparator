function [xyz, rgb, lab, valid] = spectra2color(spectra)

init_patch_library;

spectra = squeeze(spectra);

[m,n] = size(spectra);

if m~=length(d65)
    if n == length(d65)
        spectra = spectra.';
        n = m;
    else
        error('Wrong spectra dimension!');
    end
end

xyz = zeros(3,n);

xyz(1, :) = (xFcn .* d65) * spectra;
xyz(2, :) = (yFcn .* d65) * spectra;
xyz(3, :) = (zFcn .* d65) * spectra;

xyz = xyz / kNorm;

lab = xyz2lab(xyz');

lab = lab';

rgb = xyz2rgb(xyz');

rgb = rgb';

less = rgb < 0;
more = rgb > 1;

valid = not(max(less, [], 1) > 0 | max(more, [], 1) > 0);

end
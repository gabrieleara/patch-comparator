function [xyz, rgb, lab, valid] = spectrum2colorFiltered(spectrum, idxs)

persistent d65 xFcn yFcn zFcn kNorm;

if isempty(d65)
    init_patch_library;
end

spectrum = squeeze(spectrum)';

[~,n] = size(spectrum);

xyz = zeros(3,n);

xyz(1, :) = (xFcn(idxs) .* d65(idxs)) * spectrum;
xyz(2, :) = (yFcn(idxs) .* d65(idxs)) * spectrum;
xyz(3, :) = (zFcn(idxs) .* d65(idxs)) * spectrum;

kNorm_ = yFcn(idxs) * d65(idxs)';
xyz = xyz / kNorm_;

lab = xyz2lab(xyz');

lab = lab';

rgb = xyz2rgb(xyz');

rgb = rgb';

less = rgb < 0;
more = rgb > 1;

valid = not(max(less, [], 1) > 0 | max(more, [], 1) > 0);

end
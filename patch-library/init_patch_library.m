[d65, xFcn, yFcn, zFcn, kNorm] = init();



function [light, xFcn, yFcn, zFcn, kNorm] = init()

MINIMUM_LAMBDA = 380;
MAXIMUM_LAMBDA = 800;

% Initializing the light

[lambda, D65] = illuminant('d65');
light = D65(lambda >= MINIMUM_LAMBDA & lambda <= MAXIMUM_LAMBDA);



% Initializing the three color matching functions

[lambda, xFcn, yFcn, zFcn] = colorMatchFcn('1931_full');
idxs = lambda >= MINIMUM_LAMBDA & lambda <= MAXIMUM_LAMBDA;

xFcn = xFcn(idxs);
yFcn = yFcn(idxs);
zFcn = zFcn(idxs);

% Calculating the normalization factor
kNorm = yFcn * light;

% Results are all row vectors
light = light.';
% xFcn = xFcn.';
% yFcn = yFcn.';
% zFcn = zFcn.';

end
clear;
load('fast_eval_simple.mat');

spectrum = spectra(126, :);
pert = squeeze(perturbations(126,7,:));
w = 3;
b = (1/w) * ones(1,w);
a = 1;

undersample = 15;

delay = mean(grpdelay(b,a));

clear spectra perturbations trainset;

filtered = filter(b,a,spectrum);

%{

filtered = filter(b,a,spectrum);
filtered_idxs = 1:length(wavelengths)-delay;

filt_ = filtered(delay+1:end);
spectrum_ = spectrum(filtered_idxs);
wave_ = wavelengths(filtered_idxs);
filt__ = filt_(delay+1:end);
wave__ = wave_(delay+1:end);
spectrum__ = spectrum_(delay+1:end);

plot(wavelengths, spectrum);
hold on;
plot(wave__, spectrum__);
plot(wave__, filt__);

pause;

close;

filtered = filter(b,a,pert);

filt_ = filtered(delay+1:end);
pert_ = pert(filtered_idxs);
wave_ = wavelengths(filtered_idxs);
filt__ = filt_(delay+1:end);
wave__ = wave_(delay+1:end);
pert__ = pert_(delay+1:end);

plot(wavelengths, spectrum);
hold on;
plot(wave__, pert__);
plot(wave__, filt__);
%}

clear
load('fast_eval_simple.mat');
w = 3;
b = (1/w) * ones(1,w);
a = 1;
undersample = 15;
delay = mean(grpdelay(b,a));
[m,n] = size(spectra);
filtered = zeros(m,n);
for i=1:m
filtered(i, :) = filter(b,a,spectra(i, :));
end
wave_idxs = delay+1:length(wavelengths)-delay;
filt_idxs = delay*2+1:length(wavelengths);
filt_ = filtered(:, filt_idxs);
wave_ = wavelengths(wave_idxs);











wave_idxs = delay+1:length(wavelengths)-delay;
filt_idxs = delay*2+1:length(wavelengths);


filt_ = filtered(filt_idxs);
wave_ = wavelengths(wave_idxs);

plot(wavelengths, spectrum);
hold on;
plot(wave_, filt_);

unders = 1:undersample:length(filt_idxs);
filt__ = filt_(unders);
wave__ = wave_(unders);
plot(wave__, filt__, 'o');

pertf = filter(b,a, pert);
pertf_ = pertf(filt_idxs);
pertf__ = pertf_(unders);

figure
hold on;
plot(wavelengths, pert);
plot(wave__, pertf__);


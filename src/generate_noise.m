function perturbation = generate_noise(wavelengths, color, spectrum, snr, addsub)

to_filter = true;

switch color
    case 'v'
        MIN_LAMBDA = 380;
        MAX_LAMBDA = 455;
    case 'b'
        MIN_LAMBDA = 455;
        MAX_LAMBDA = 492;
    case 'g'
        MIN_LAMBDA = 492;
        MAX_LAMBDA = 577;
    case 'y'
        MIN_LAMBDA = 577;
        MAX_LAMBDA = 597;
    case 'o'
        MIN_LAMBDA = 597;
        MAX_LAMBDA = 620;
    case 'r'
        MIN_LAMBDA = 620;
        MAX_LAMBDA = 800;
    case 'w'
        MIN_LAMBDA = wavelengths(1);
        MAX_LAMBDA = wavelengths(end);
        
        to_filter = false;
    otherwise
        error('Invalid color specified');
end

if to_filter

    MID_GAUSS = (MAX_LAMBDA + MIN_LAMBDA) / 2;
    norm = normpdf(wavelengths,MID_GAUSS,(MAX_LAMBDA-MIN_LAMBDA)/2);

    max_norm = max(norm);
    norm = norm / max_norm;
else
    norm = ones(1, length(wavelengths)).';
end

% plot(wavelengths, norm);
% ylim([0 1]);

power = sum(spectrum.^2)/length(wavelengths);
norm = norm.'*power; % TODO: probably remove

noise = awgn(zeros(1, length(norm)), 1);

if to_filter
    noise = norm .* noise / 10 + norm;
else
    noise = norm .* noise / 10;
end

perturbation = spectrum + addsub * noise * snr;


figure;
subplot(1,2,1);
hold on;

plot(wavelengths, spectrum);
plot(wavelengths, noise);
plot(wavelengths, perturbation)

hold off;

subplot(1,2,2);
hold on;
[~, rgb1, lab1, ~] = spectra2color(spectrum.');
patch([0 1 1 0], [1 1 0 0], rgb1.')

[~, rgb3, lab3, ~] = spectra2color(perturbation.');
patch([-1 0 0 -1], [1 1 0 0], rgb3.')

deltae = delta_e(lab1, lab3)

hold off;

end

%{
perturbation = (spectrum + otherspectrum * snr1) * snr2;

figure;
subplot(1,2,1);
hold on;

plot(wavelengths, spectrum);
plot(wavelengths, otherspectrum);
plot(wavelengths, perturbation)

hold off;

subplot(1,2,2);
hold on;
[~, rgb1, lab1, ~] = spectra2color(spectrum.');
patch([0 1 1 0], [1 1 0 0], rgb1.')

[~, rgb2, lab2, ~] = spectra2color(otherspectrum.');
patch([1 2 2 1], [1 1 0 0], rgb2.')

[~, rgb3, lab3, ~] = spectra2color(perturbation.');
patch([-1 0 0 -1], [1 1 0 0], rgb3.')

deltae = delta_e(lab1, lab3)

hold off;


end
%}
%{
zeros_ = zeros(1, length(wavelengths));

perturbation = awgn(zeros_, 25 * snr);

perturbation = perturbation.*spectrum;

figure;
subplot(1,2,1);
hold on;

plot(wavelengths, spectrum);
plot(wavelengths, perturbation);

perturbation = spectrum + perturbation;

plot(wavelengths, perturbation)

hold off;

subplot(1,2,2);
hold on;
[~, rgb1, lab1, ~] = spectra2color(spectrum.');
patch([0 1 1 0], [1 1 0 0], rgb1.')

[~, rgb2, lab2, ~] = spectra2color(perturbation.');
patch([1 2 2 1], [1 1 0 0], rgb2.')

deltae = delta_e(lab1, lab2)

hold off;

end
%}
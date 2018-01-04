function trainset = generate_trainset(fin, fout)

if ~exist(fin, 'file')
    error('File does not exist!');
end

vars = load(fin, 'spectra', 'perturbations', 'ratings', 'pairs');

[~, ~, Nwavelengths] = size(vars.perturbations);

Npairs = length(vars.pairs);

waitbar_total   = Npairs;
waitbar_partial = 0;
waitstr = sprintf('Generating a trainset to be saved in %s...', fout);
waitbar_h = waitbar(0, waitstr);
set(findall(waitbar_h,'type','text'),'Interpreter','none');

if Npairs < 2
    error('Pairs variable invalid!');
end

inputs = [];

inputs.spectra  = zeros(Npairs, 2 * Nwavelengths);
inputs.xyz      = zeros(Npairs, 6);
inputs.lab      = zeros(Npairs, 6);
inputs.rgb      = zeros(Npairs, 6);

outputs         = zeros(Npairs, 1);
outputs(1:end)  = vars.ratings;

for i = 1:Npairs
    
    % Updating waitbar content, it will abort any operation if the
    % waitbar has been closed.
    waitbar_partial = waitbar_partial+1;
    waitbar_update(waitbar_partial/waitbar_total, waitbar_h);
    
    spectrum_idx    = vars.pairs(i, 1);
    pert_idx        = vars.pairs(i, 2);
    
    spectrum        = squeeze(vars.spectra(spectrum_idx, :));
    perturbation    = squeeze(vars.perturbations(spectrum_idx, pert_idx, :));

    inputs.spectra(i, 1:Nwavelengths) = spectrum;
    inputs.spectra(i, Nwavelengths+1:end) = perturbation;
    
    [xyz, rgb, lab] = spectra2color(spectrum);
    
    inputs.xyz(i, 1:3) = xyz;
    inputs.lab(i, 1:3) = lab;
    inputs.rgb(i, 1:3) = rgb;
    
    [xyz, rgb, lab] = spectra2color(perturbation);
    
    inputs.xyz(i, 4:6) = xyz;
    inputs.lab(i, 4:6) = lab;
    inputs.rgb(i, 4:6) = rgb;
end

close(waitbar_h);

trainset = [];

trainset.inputs     = inputs;
trainset.outputs    = outputs;

save(fout, 'trainset');

end
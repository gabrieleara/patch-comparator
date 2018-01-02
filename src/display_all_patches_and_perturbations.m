function display_all_patches_and_perturbations(spectra, perturbations)

[Nspectra, Nperturbations, ~] = size(perturbations);

fig = figure;
hold on;

for i = 1:Nspectra
    k = mod(i-1, 16);
    
    if ~ishandle(fig)
        fig = figure;
        hold on;
    end
    
    [~, rgb] = spectrum2color(spectra, i);
    patch([0 1 1 0],[k k k+1 k+1], rgb.');
    
    for j = 1:Nperturbations
        [~, rgb, ~, valid] = pert2color(perturbations, i, j);
        
        if valid
            patch([j j+1 j+1 j], [k k k+1 k+1], rgb.');
        end
    end
    
    if k == 15
       pause(0.1); 
    end
end

hold off;
end
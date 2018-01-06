inputs = trainset.inputs.('spectra');
filter = 5;
[m,n] = size(inputs);

inputs_ = zeros(m, (floor(n/2 / filter)+1)*2);

j = 1;
for i = 1:filter:n/2
    inputs_(:, j) = inputs(:, i);
    j = j+1;
end

for i = n/2+1:filter:n
    inputs_(:, j) = inputs(:, i);
    j = j+1;
end

inputs = inputs_;
clear inputs_;
function tf = check_string(str, patterns)

str         = cellstr(str);
patterns    = cellstr(patterns);
[m, ~]      = size(patterns);

tf          = zeros(m,1);

for i = 1:m
    pattern = patterns{i};
    
    if length(pattern) < 1
        tf(i) = false;
    else
        tf_ = contains(str, pattern, 'IgnoreCase', true);

        [tf_, idx] = max(tf_);
        
        if tf_ < 1
            tf(i) = 0;
        else
            tf(i) = idx;
        end
    end
end

end


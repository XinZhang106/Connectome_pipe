function normed_ar = z_score_norm(inputarray)
[~, col] = size(inputarray);
if (col~=1)
    error('Input must be n*1 array!\n');
end
meanar = mean(inputarray);
stdar = std(inputarray);
normed_ar = (inputarray-meanar)/stdar;
end
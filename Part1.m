%% ===Unfirom Distributed RV===
M = [4, 6, 8];
N = 20;  

% Preallocate
fixed_dict_x = cell(length(M),1);
fixed_len_x = zeros(length(M),1);
huffman_dict_x = cell(length(M),1);
huffman_len_x = zeros(length(M),1);
H_x = zeros(length(M),1);

coded_fixed_x = cell(1, length(M));
coded_huff_x  = cell(1, length(M));
total_fixed_x = zeros(1, length(M));
total_huff_x  = zeros(1, length(M));
loss_x        = zeros(1, length(M));


for i = 1:length(M)
    p = 1/M(i);
    prob_x = ones(M(i),1) * p;
    
    [fixed_dict_x{i}, fixed_len_x(i), huffman_dict_x{i}, huffman_len_x(i), H_x(i)] = codebooks_gen(prob_x);
end

for i = 1:length(M)
    sequence = randi([1 M(i)], 1, N);
    [coded_fixed_x{i}, coded_huff_x{i}, total_fixed_x(i), total_huff_x(i), loss_x(i)] = ...
        codebooks_test(fixed_dict_x{i}, huffman_dict_x{i}, sequence);
    
    fprintf('M=%d: Fixed=%d bits, Huffman=%d bits, Loss=%d\n', ...
        M(i), total_fixed_x(i), total_huff_x(i), loss_x(i));
    fprintf('M=%d: Entropy=%.2f, FixedAvgLen=%d, HuffmanAvgLen=%.2f, Loss=%d\n', ...
        M(i), H_x(i), fixed_len_x(i), huffman_len_x(i), loss_x(i));
end
%% ===Functions===
function [fixed_dict, fixed_length, huffman_dict, huffman_length, entropy]=codebooks_gen(probs)
    M=length(probs);
    symbols=1:M;
    [huffman_dict,huffman_length] = huffmandict(symbols,probs);
    entropy=-sum(probs.*log2(probs));
    fixed_length=ceil(log2(M));
    fixed_codebook_x = dec2bin(0:M-1, fixed_length);
    fixed_dict_cell = cell(M,2);
    for i = 1:M
        fixed_dict_cell{i,1} = i;                          % symbol
        fixed_dict_cell{i,2} = fixed_codebook_x(i,:);     % codeword
    end
    fixed_dict=fixed_dict_cell;
end

function [coded_fixed, coded_huff, total_fixed, total_huff, loss] = codebooks_test(fixed_dict, huffman_dict, sequence)
    coded_fixed_cell = cell(1, length(sequence));
    for j = 1:length(sequence)
        idx = cell2mat(fixed_dict(:,1)) == sequence(j);  % safer
        coded_fixed_cell{j} = fixed_dict{idx,2};
    end

    coded_fixed = [coded_fixed_cell{:}];
    total_fixed = length(coded_fixed);
    
    coded_huff = huffmanenco(sequence, huffman_dict);
    total_huff = length(coded_huff);
    
    fixed_len = size(fixed_dict{1,2},2);
    decoded_fixed = zeros(1, length(sequence));
    for j = 1:length(sequence)
        code = coded_fixed((j-1)*fixed_len + 1 : j*fixed_len);
        idx = find(strcmp(fixed_dict(:,2), code));
        decoded_fixed(j) = fixed_dict{idx,1};
    end
    
    decoded_huff = huffmandeco(coded_huff, huffman_dict);
    
    if isequal(decoded_fixed, sequence) && isequal(decoded_huff, sequence)
        loss = 0;
    else
        loss = 1;
    end
end
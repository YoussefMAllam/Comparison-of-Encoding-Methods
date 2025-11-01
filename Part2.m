%% ===Part 2.1===
N=20;
prob_y=[0.5 0.5^2 0.5^3 0.5^4 0.5^5 0.5^5];
sequence = randi([1 length(prob_y)], 1, N);

[fixed_dict_y, fixed_len_y, huffman_dict_y, huffman_len_y, H_y] = codebooks_gen(prob_y);
[coded_fixed_y, coded_huff_y, total_fixed_y, total_huff_y, loss_y] = ...
        codebooks_test(fixed_dict_y, huffman_dict_y, sequence);
fprintf('Y: Fixed=%d bits, Huffman=%d bits, Loss=%d\n', ...
    total_fixed_y, total_huff_y, loss_y);
fprintf('Y: Entropy=%.2f, FixedAvgLen=%d, HuffmanAvgLen=%.2f, Loss=%d\n', ...
     H_y, fixed_len_y, huffman_len_y, loss_y);

%% ===Part 2.2===
prob_z=[0.05 0.1 0.3 0.25 0.15 0.15];
sequence = randi([1 length(prob_z)], 1, N);
[fixed_dict_z, fixed_len_z, huffman_dict_z, huffman_len_z, H_z] = codebooks_gen(prob_z);
[coded_fixed_z, coded_huff_z, total_fixed_z, total_huff_z, loss_z] = ...
        codebooks_test(fixed_dict_z, huffman_dict_z, sequence);
fprintf('Z: Fixed=%d bits, Huffman=%d bits, Loss=%d\n', ...
    total_fixed_z, total_huff_z, loss_z);
fprintf('Z: Entropy=%.2f, FixedAvgLen=%d, HuffmanAvgLen=%.2f, Loss=%d\n', ...
     H_z, fixed_len_z, huffman_len_z, loss_z);
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
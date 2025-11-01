[huffmanstream, decoded_huff, asci_huff, huff_size, huff_compress]=Huffman_Text_Compression('Sample Text (2).txt');
%% Huffman Text Compression
function [huffmanStream, decodedText, asciiSizeBits, huffSizeBits, compressionPercent] = Huffman_Text_Compression(inputFile)
    % Read and clean input text
    raw = fileread(inputFile);
    allowed = ['A':'Z', 'a':'z', '1':'9', ' ', ',', '.']; % allowed characters
    textData = raw(ismember(raw, allowed));                % filter out everything else

    if isempty(textData)
        error('Input file is empty after cleaning or contains no allowed characters.');
    end

    % Determine symbols and probabilities (use sorted order for consistency)
    symbols = unique(textData(:));     
    M = numel(symbols);
    freq = zeros(M,1);
    for i = 1:M
        freq(i) = sum(textData == symbols(i));
    end
    prob = freq / sum(freq);
    % === Plot Symbol PMF ===
    [probSorted, idxSort] = sort(prob, 'descend');
    symbolsSorted = symbols(idxSort);
    
    figure;
    bar(probSorted);
    set(gca, 'XTick', 1:numel(symbolsSorted), 'XTickLabel', symbolsSorted);
    xtickangle(90); % Rotate labels for readability
    title('Symbol Probability Mass Function (PMF)');
    xlabel('Symbols');
    ylabel('Probability');
    grid on;


    % Build Huffman dictionary using numeric symbols 1..M
    dict = huffmandict(1:M, prob);

    % Map characters to indices and encode
    [~, loc] = ismember(textData, symbols);   
    huffmanStream = huffmanenco(loc, dict);

    % Save Huffman binary
    huffFile = [inputFile(1:end-4), '_huffman.bin'];
    fid = fopen(huffFile, 'wb');
    if fid ~= -1
        fwrite(fid, huffmanStream, 'ubit1');
        fclose(fid);
    end

    % ASCII 8-bit baseline encoding (for comparison)
    asciiCodes = uint8(textData);
    binAscii = dec2bin(asciiCodes, 8).';         
    asciiStream = binAscii(:).' - '0';          

    asciiFile = [inputFile(1:end-4), '_ascii.bin'];
    fid = fopen(asciiFile, 'wb');
    if fid ~= -1
        fwrite(fid, asciiStream, 'ubit1');
        fclose(fid);
    end

    % Sizes and compression percent
    asciiSizeBits = numel(asciiStream);
    huffSizeBits  = numel(huffmanStream);
    compressionPercent = (1 - huffSizeBits / asciiSizeBits) * 100;

    % Decode Huffman
    decodedIdx = huffmandeco(huffmanStream, dict);    % numeric indices
    decodedChars = symbols(decodedIdx);               % returns char vector
    decodedText = char(decodedChars);                 % ensure char array

    % Save decoded text
    decodedFile = [inputFile(1:end-4), '_huffman_decoded.txt'];
    fid = fopen(decodedFile, 'w');
    if fid ~= -1
        fwrite(fid, decodedText);
        fclose(fid);
    end

    % Validation and report
    if isequal(decodedText(:).', textData(:).')
        disp('Huffman decoded text matches the original text.');
    else
        disp('Huffman decoded text differs from original text!');
    end

    fprintf('\n--- Huffman Compression Report ---\n');
    fprintf('Cleaned input length (chars): %d\n', numel(textData));
    fprintf('ASCII Size (bits):           %d\n', asciiSizeBits);
    fprintf('Huffman Size (bits):         %d\n', huffSizeBits);
    fprintf('Compression (vs ASCII):      %.2f%%\n', compressionPercent);
    fprintf('Decoded text saved:          %s\n', decodedFile);
    fprintf('Binary files saved:          %s, %s\n\n', huffFile, asciiFile);
end
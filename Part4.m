[fanostream, decoded_fano, asci_fano, fano_size, fano_compress]=Fano_Text_Compression('Sample Text (2).txt');
%% Fano Text Compression (static Fano)
function [fanoStream, decodedText, asciiSizeBits, fanoSizeBits, compressionPercent] = Fano_Text_Compression(inputFile)
    % Read and clean input text
    raw = fileread(inputFile);
    allowed = ['A':'Z', 'a':'z', '1':'9', ' ', ',', '.']; % allowed characters
    textData = raw(ismember(raw, allowed));                % filter out everything else

    if isempty(textData)
        error('Input file is empty after cleaning or contains no allowed characters.');
    end

    % Determine symbols and probabilities (sorted descending when building Fano)
    symbols = unique(textData(:));
    M = numel(symbols);
    counts = zeros(M,1);
    for k = 1:M
        counts(k) = sum(textData == symbols(k));
    end
    probs = counts / sum(counts);

    % Edge case: single symbol
    if M == 1
        codeMap = containers.Map(symbols, {'0'});
        % encode
        fanoStream = repmat(0, 1, numel(textData)); % all zeros
    else
        % Sort descending by probability for Fano algorithm
        [pSorted, idxSort] = sort(probs, 'descend');
        symSorted = symbols(idxSort);

        % init dict: cell Mx2 {symbol, codeString}
        dict = cell(M,2);
        for i = 1:M
            dict{i,1} = symSorted(i);  % store char as cell element
            dict{i,2} = '';
        end

        % Recursively assign codes
        dict = fanoAssign(dict, pSorted, 1, M);

        % Create map symbol->code (keys are char values)
        % Ensure keys are char (not strings)
        keyCells = cellfun(@(c) c, dict(:,1), 'UniformOutput', false);
        codeCells = dict(:,2);
        codeMap = containers.Map(keyCells, codeCells);

        % Encode text to bitstream
        codesCell = cell(1, numel(textData));
        for k = 1:numel(textData)
            ch = textData(k);
            % codeMap key must match type: use the char scalar
            codeStr = codeMap(ch);
            codesCell{k} = codeStr;
        end
        % flatten to numeric bits
        fanoStream = [];
        for k = 1:numel(codesCell)
            bitsChar = codesCell{k};
            fanoStream = [fanoStream, bitsChar - '0']; %#ok<AGROW>
        end
    end

    % Save Fano binary file
    fanoFile = [inputFile(1:end-4), '_fano.bin'];
    fid = fopen(fanoFile, 'wb');
    if fid ~= -1
        fwrite(fid, fanoStream, 'ubit1');
        fclose(fid);
    end

    % ASCII baseline (8-bit)
    asciiCodes = uint8(textData);
    binAscii = dec2bin(asciiCodes, 8);
    asciiStream = reshape(binAscii.' - '0', 1, []);
    asciiFile = [inputFile(1:end-4), '_ascii.bin'];
    fid = fopen(asciiFile, 'wb');
    if fid ~= -1
        fwrite(fid, asciiStream, 'ubit1');
        fclose(fid);
    end

    % Sizes & compression
    asciiSizeBits = numel(asciiStream);
    fanoSizeBits   = numel(fanoStream);
    compressionPercent = (1 - fanoSizeBits / asciiSizeBits) * 100;

    % Build reverse map for decoding: codeStr -> symbol
    codeKeys = dict(:,2);
    symVals  = dict(:,1);
    reverseMap = containers.Map(codeKeys, symVals);

    % Decode by incremental buffer matching
    decodedChars = char.empty(1,0);
    buffer = '';
    for i = 1:length(fanoStream)
        buffer = [buffer, num2str(fanoStream(i))];   % append '0' or '1'
        if isKey(reverseMap, buffer)
            sym = reverseMap(buffer); % cell containing char
            decodedChars(end+1) = sym; %#ok<AGROW>
            buffer = '';
        end
    end
    if ~isempty(buffer)
        warning('Leftover bits in decoding buffer (possible code error).');
    end
    decodedText = char(decodedChars);

    % Save decoded text
    decodedFile = [inputFile(1:end-4), '_fano_decoded.txt'];
    fid = fopen(decodedFile, 'w');
    if fid ~= -1
        fwrite(fid, decodedText);
        fclose(fid);
    end

    % Validate and report
    if isequal(decodedText, textData)
        disp('Fano decoded text matches the cleaned input.');
    else
        disp('Fano decoded text differs from cleaned input!');
    end

    fprintf('\n--- Fano Compression Report ---\n');
    fprintf('Cleaned input length (chars): %d\n', numel(textData));
    fprintf('ASCII Size (bits):           %d\n', asciiSizeBits);
    fprintf('Fano Size (bits):            %d\n', fanoSizeBits);
    fprintf('Compression (vs ASCII):      %.2f%%\n', compressionPercent);
    fprintf('Decoded text saved:          %s\n', decodedFile);
    fprintf('Binary files saved:          %s, %s\n\n', fanoFile, asciiFile);
end

%% Recursive Fano Assignment
function dict = fanoAssign(dict, prob, lo, hi)
    % dict: cell Nx2 {symbol, code}, prob: descending-sorted probabilities
    if lo >= hi
        return;
    end

    total = sum(prob(lo:hi));
    acc = 0;
    split = lo;
    while split <= hi
        acc = acc + prob(split);
        if acc >= total/2
            split = split + 1;
            break;
        else
            split = split + 1;
        end
    end

    if split <= lo
        split = lo + 1;
    elseif split > hi+1
        split = hi;
    end

    % append bits
    for i = lo:split-1
        dict{i,2} = [dict{i,2}, '0'];
    end
    for i = split:hi
        dict{i,2} = [dict{i,2}, '1'];
    end

    if split-1 > lo
        dict = fanoAssign(dict, prob, lo, split-1);
    end
    if hi > split
        dict = fanoAssign(dict, prob, split, hi);
    end
end

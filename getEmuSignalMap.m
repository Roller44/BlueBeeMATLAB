function emuSignalMap = getEmuSignalMap(OSR)
    
    persistent BlueBeeMap
    if isempty(BlueBeeMap)
        BlueBeeMap = BlueBeeMapGenerator();
    end
    emuSignalMap = zeros(OSR * 16, 16);

    for sym_ith = 1:1:16
        chips = BlueBeeMap(sym_ith, :)';
        emuSignalMap(:, sym_ith) = bleWaveformGenerator(chips, OSR);
    end

    % Normalization so that the power of each signal is 1
    for sym_ith = 1:1:size(emuSignalMap, 2)
        tmp = emuSignalMap(:, sym_ith);
        emuSignalMap(:, sym_ith) = tmp / sqrt(sum(abs(tmp.^2), 1)/size(tmp, 1));
    end

end

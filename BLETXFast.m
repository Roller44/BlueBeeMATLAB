function [txWaveform, txSyms, numPkt] = BLETXFast(txBits, OSR)

    persistent BlueBeeMap
    persistent emuSignalMap

    persistent chipLenBLE
    persistent SHR
    persistent PHR
    persistent numBitPerPHYPayload
    persistent numBytePerPHYPayload

    if isempty(BlueBeeMap)
        BlueBeeMap = BlueBeeMapGenerator();
    end

    if isempty(emuSignalMap)
        emuSignalMap = getEmuSignalMap(OSR);
    end

    if isempty(chipLenBLE)
        chipLenBLE = 16;
    end
    
    if isempty(numBitPerPHYPayload)
        % This setting aligns with that in ZigBee, in which each ZigBee
        % packet's PHY payload contains 96 bits (i.e., 24 symbols).
        numBitPerPHYPayload = 96;
        numBytePerPHYPayload = numBitPerPHYPayload / 8;
    end

    if isempty(SHR)
        % Synchronization header (SHR)

        % Preamble is 4 octets, all set to 0.
        preamble = zeros(4 * 8, 1);

        % Start-of-frame delimiter (SFD)
        SFD = [1 1 1 0 0 1 0 1]'; % value from standard (see Fig. 68, IEEE 802.15.4, 2011 Revision)

        SHR = [preamble; SFD];
    end

    if isempty(PHR)
        % PHY Header (PHR)
        reservedValue = 0;
        PHR = [int2bit(numBytePerPHYPayload, 7, false); reservedValue];
    end

    % Start to generate waveforms
    numPkt = ceil(length(txBits) / numBitPerPHYPayload);
    
    if mod(length(txBits), numBitPerPHYPayload) > 0
        numPadBits = numBitPerPHYPayload * numPkt - length(txBits);
        txBits = [txBits, zeros(1, numPadBits)];
    end

    txBits = reshape(txBits, [numBitPerPHYPayload, numPkt]);

    numSymPerPkt = (length(SHR) + length(PHR) + numBitPerPHYPayload) / 4;
    numSampPerSym = OSR * 16;
    txSyms = zeros(numSymPerPkt, numPkt);
    numSampPerPkt = numSymPerPkt * numSampPerSym;
    xWaveform = zeros(numSampPerPkt, numPkt);

    for ithPkt = 1:1:numPkt

        % PHY protocol data unit:
        PPDU = [SHR; PHR; txBits(:, ithPkt)];

        % pre-allocate matrix for performance
        chips = zeros(chipLenBLE, length(PPDU) / 4);
        
        waveformTmp = zeros(numSampPerSym, numSymPerPkt);
        for idx = 1:length(PPDU) / 4
            % Bit to symbol mapping
            currBits = PPDU(1 + (idx - 1) * 4:idx * 4);
            symbol = bit2int(currBits, 4, false);
            txSyms(idx, ithPkt) = symbol;

            % Symbol to chip mapping
            waveformTmp(:, idx) = emuSignalMap(:, symbol+1); % +1 for 1-based indexing
            
        end

        txWaveform(:, ithPkt) = waveformTmp(:);
    end
    txWaveform = [txWaveform; zeros(OSR/2, size(txWaveform, 2))];

%     %++++++++++++++++++++++++++++
%     numMsg = length(messages);
%     chips = zeros(1, 16 * numMsg);
%     for ith = 1: 1: numMsg
%        chips(1, 16*(ith-1)+1: 16*(ith)) = BlueBeeMap(messages(1,ith),:);
%     end
%     
%     % BLEBits = chips(1:2:end);
%     sps = 100;
%     txWaveform = bleWaveformGenerator(chips', sps);
%     [num_smpl, ~] = size(txWaveform);
%     txWaveform = [zeros(1, sps), reshape(txWaveform, [1, num_smpl]), zeros(1, sps)];
end
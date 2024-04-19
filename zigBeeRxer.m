function [rxBits, rxSyms] = zigBeeRxer(rxSignal, OSR, numPkt)

    persistent chipLenZigBee
    persistent chipMapPhase
    persistent numBitPerPHYPayload

%     numPkt = size(rxSignal, 2);
%     numBitPerPkt = 96; % According to WEBee, each ZigBee packet's PHY payload contains 96 bits (i.e., 24 symbols).
%     rxBits = zeros(numBitPerPkt, numPkt);

    if isempty(chipLenZigBee)
        chipLenZigBee = 32;
    end

    if isempty(numBitPerPHYPayload)
        % This setting aligns with that in ZigBee, in which each ZigBee
        % packet's PHY payload contains 96 bits (i.e., 24 symbols).
        numBitPerPHYPayload = 96;
        % numBytePerPHYPayload = numBitPerPHYPayload / 8;
    end
    rxBits = zeros(numBitPerPHYPayload, numPkt);

    if mod(size(rxSignal(:, 1), 1), OSR) > 0
        numPadSampPerSig = OSR - mod(size(rxSignal(:, 1), 1), OSR);
        rxSignal = [rxSignal; zeros(numPadSampPerSig, numPkt)];
    end

    rxSignal = rxSignal(1:OSR/2:end-OSR/2, :);

    if isempty(chipMapPhase)
        chipMapPhase = [0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0;
         0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0;
         0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0;
         0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0;
         0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1;
         0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1;
         0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0;
         0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0;
         0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1;
         0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1;
         0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1;
         0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1;
         0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0;
         0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0;
         0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1;
         0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1];
    end

    phaseShifts = angle(rxSignal(2:1:size(rxSignal, 1), :) .* conj(rxSignal(1:1:size(rxSignal, 1)-1, :)));

    phaseShifts = phaseShifts > 0;

    if mod(size(phaseShifts, 1), chipLenZigBee) > 0
        numPadChips = chipLenZigBee - mod(size(phaseShifts, 1), chipLenZigBee);
        padChips = zeros(numPadChips, numPkt);
        phaseShifts = [phaseShifts; padChips];
    end

    rxSyms = zeros(size(phaseShifts, 1) / chipLenZigBee / 4, numPkt);
    for ithPkt = 1:1:numPkt

        bits = zeros(4, size(phaseShifts, 1) / chipLenZigBee);

        for idx = 1:1:(size(phaseShifts, 1) / chipLenZigBee)

            % Chip to symbol mapping
            thisChip = phaseShifts(1 + (idx - 1) * chipLenZigBee:idx * chipLenZigBee, ithPkt);

            % find the chip sequence that looks the most like the received (minimum number of bit errors)
            [~, symbol] = min(sum(xor(thisChip', chipMapPhase), 2));
            symbol = symbol - 1; % -1 for 1-based indexing

            rxSyms(idx, ithPkt) = symbol;

            % Symbol to bit mapping
            bits(:, idx) = int2bit(symbol, 4, false);
        end

        %% Remove headers
        bits = bits(:);
        preambleLen = 4 * 8; % 4 octets
        SFDLen = 8; % 1 octet
        PHRLen = 8; % 1 octet
        offset = preambleLen + SFDLen + PHRLen;
        rxBits(:, ithPkt) = bits(1 + offset:end);
    end
end

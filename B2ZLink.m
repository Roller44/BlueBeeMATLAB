function [rxBits, rxSyms, txSyms] = B2ZLink(txBits, SNR, isCHIdeal)
    OSR = 100;

    [txWaveform, txSyms, numPkt] = BLETX(txBits, OSR);

    if isCHIdeal
        rxWaveform = txWaveform;
    else
        rxWaveform = awgn(txWaveform, SNR, 'measured');
    end

    [rxBits, rxSyms] = zigBeeRxer(rxWaveform, OSR, numPkt);
    rxBits = reshape(rxBits, 1, size(rxBits, 1) * size(rxBits, 2));
    rxSyms = reshape(rxSyms, 1, size(rxSyms, 1) * size(rxSyms, 2));
    txSyms = reshape(txSyms, 1, size(txSyms, 1) * size(txSyms, 2));
end
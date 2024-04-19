function [errorRateBits, errorRateSyms] = run(numBits, SNR)

txBits = randi([0, 1], 1, numBits);
[rxBits, rxSyms, txSyms] = B2ZLink(txBits, SNR, false);
errorRateBits = 1 - length(find(txBits==rxBits(1:1:length(txBits)))) ./ length(txBits);
errorRateSyms = 1 - length(find(txSyms == rxSyms)) / length(txSyms);

disp(['SNR = ', num2str(SNR), ' BER = ', num2str(errorRateBits), ' and SER = ', num2str(errorRateSyms), '.'])

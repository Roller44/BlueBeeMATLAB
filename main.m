clear all;
clc;

numBits = 10^5;
SNRList = -10:2:30;

errorRateBits = zeros(1, length(SNRList));
errorRateSyms = zeros(1, length(SNRList));

%% Run the simulation
for ith = 1:1:length(SNRList)
    SNR = SNRList(1, ith);
    [errorRateBits(1, ith), errorRateSyms(1, ith)] = run(numBits, SNR);
end

%% Plot results
figure;
plot(SNRList, errorRateBits, '-^');
xlabel('SNR (dB)');
ylabel('Bit error rate');

figure;
plot(SNRList, errorRateBits, '-^');
xlabel('SNR (dB)');
ylabel('Symbol error rate');
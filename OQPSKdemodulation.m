function bits = OQPSKdemodulation( waveform )

%% Receive-side oversampling
len1 = length(waveform);
samp_waveform = zeros();
j = 1;
for i=1:2:len1
    samp_waveform(j) = waveform(i);
    j = j + 1;
    
end

samp_waveform = [samp_waveform, 0];

  chipLen = 32;
  % See Table 73 in IEEE 802.15.4,  2011 revision
  chipMap = ...
     [1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0;
      1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0;
      0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0;
      0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1;
      0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0 0 0 1 1;
      0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1 1 1 0 0;
      1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1 1 0 0 1;
      1 0 0 1 1 1 0 0 0 0 1 1 0 1 0 1 0 0 1 0 0 0 1 0 1 1 1 0 1 1 0 1;
      1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1;
      1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1;
      0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1;
      0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0;
      0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 0;
      0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0 1 0 0 1;
      1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0 1 1 0 0;
      1 1 0 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0 1 1 1 0 0 0];
 
%% OQPSK demodulation
len1 = length(samp_waveform);
% calculate phase shift
for n = 2:len1
    bs1(n-1) = angle(samp_waveform(n) * conj(samp_waveform(n-1)));
end
% quantization
for i = 1:length(bs1)
    if bs1(i) > 0
        bs1(i) = 1;
    else
        bs1(i) = 0;
    end
end
bs1 = bs1';
% construct matrix to save received symbol
bits = zeros(4, length(bs1)/chipLen);

for idx = 1:length(bs1)/chipLen
  
  %% Chip to symbol mapping
  thisChip = bs1(1+(idx-1)*chipLen:idx * chipLen);
  
  % find the chip sequence that looks the most like the received (minimum number of bit errors)
  [~, symbol] = min(sum(xor(thisChip', chipMap), 2));
  symbol = symbol - 1; % -1 for 1-based indexing
 
  %% Symbol to bit mapping
  bits(:, idx) = de2bi(symbol, 4); % de2bi 将十进制转换成二进制向量
end


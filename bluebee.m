clear all
clc

%% parameter
sps = 4;                             % Samples per symbol, BLE
errorRate = zeros();                 % construct a errorRate matrix
i = 1;
timeconsume = zeros();               % construct a transmission_time matrix

%% 循环遍历每个SNR，计算在当前SNR下的误比特率
for EbNo = 0:1:20
    snrVec = EbNo - 10*log10(sps); % Caculate signal to noise
    error = 0; % 计数错误比特个数
    right = 0; % 计数正确比特个数
    t1 = clock; % 设置传输开始时间点
    % 每次遍历ble发送1000个symbol
    for times = 1:10000
        [message,ds] = BLEGenerator; 
        % 每个symbol重复发送15次
        for sameM = 1:15
            txWaveform = bleWaveformGenerator(ds,sps); % generate the BLE waveform
            
            rxWaveform = awgn(txWaveform,snrVec); % awgn channel
            
            bits = OQPSKdemodulation(rxWaveform); % OQPSK demodulation
            bits = bits';
        end
        % 检查接收到的每个symbol是否与发送的symbol相同
        if message == bits
            right = right + 1;
        else
            error = error + 1;
        end
    end
    t2 = clock; % 设置传输结束时间点
    timeconsume(:,i) = etime(t2,t1); % 计算两个时间点的时间差
    errorRate(1,i) = error / 150000; % 计算误比特率
    i = i + 1;
end

%%
figure(1)
k = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
set(gca, 'xlim', [0,21], 'xtick', (0:1:21));
set(gca, 'ylim', [0,1.0], 'ytick', (0:0.1:1.0));
plot(k,errorRate(1,:),'r-o') 
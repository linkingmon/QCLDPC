% QCLDPC performance analysis

% check the path of the Base graph: 
clear all;
bspath = 'C:\Program Files\MATLAB\R2019a\toolbox\5g\5g\+nr5g\+internal\+ldpc\baseGraph';

% parameters
Es = 1;                             % energy per symbol
max_iter = 15;                      % max iteration count
bgn = 1;                            % bbase graph number
C = 1000;                           % minimun simulation times per SNR
K = 22*32;                          % message length
thres = 100;                        % minimun error count per SNR
code_rate = 1/2;                    % code rate
snrdb = [0:0.2:2.6];                % SNR for simultion (in dB)
ber_res = zeros(2,length(snrdb));   % saving BER(bit error rate)
rng(0);                             % set random seed
err_limit = 10e-6;                  % minimun error rate
running = true;

% initailize QCLDPC PCM(partiy check matrix)
[LDPCParityCheckMatrix, B] = getPCM(bgn, K, code_rate, bspath);

% LDPC encode & decoder setting
encldpc = comm.LDPCEncoder(LDPCParityCheckMatrix);
mydecldpc = mydecoder(LDPCParityCheckMatrix, max_iter);

% simulate per SNR
for jj = 1:length(snrdb)

snr = 10^(snrdb(jj)/10);

% apply PSK modulator and demodulator
pskModulator = comm.PSKModulator(...
'ModulationOrder', 4,... 
'BitInput', true, ...
'PhaseOffset', pi / 4, ...
'SymbolMapping', 'Custom', ...
'CustomSymbolMapping', [0 2 3 1]);
pskDemodulator = comm.PSKDemodulator(...
'ModulationOrder', 4, ...
'BitOutput', true, ...
'PhaseOffset', pi /4 , ...
'SymbolMapping', 'Custom', ...
'CustomSymbolMapping', [0 2 3 1], ...
'DecisionMethod', 'Approximate log-likelihood ratio', ...
'Variance', Es/snr);
chan = comm.AWGNChannel(...
'NoiseMethod', 'Variance',...
'Variance', Es/snr);

% Get the constellation 
cacheBitInput = pskModulator.BitInput;
pskModulator.BitInput = false;
constellation = pskModulator((0:pskModulator.ModulationOrder-1)');
release(pskModulator);
pskModulator.BitInput = cacheBitInput;

error_cnt = 0;
time_cnt = 0;

% iterate C times
for ii = 1:C
    message = randi([0, 1], K, 1);
    ldpcEncOut = encldpc(message);
    modOut = pskModulator(ldpcEncOut);
    chanOut = chan(modOut);
    demodOut = pskDemodulator(chanOut);
    tic;
    ldpcDecOut = mydecldpc.decodeSP(demodOut')';
    time_cnt = time_cnt + toc;
    error_cnt = error_cnt + sum(message ~= ldpcDecOut, 'all');
end

% iterate to minimun error count
num = 0;
while error_cnt < thres
    num = num + 1;
    message = randi([0, 1], K, 1);
    ldpcEncOut = encldpc(message);
    modOut = pskModulator(ldpcEncOut);
    chanOut = chan(modOut);
    demodOut = pskDemodulator(chanOut);
    ldpcDecOut = mydecldpc.decodeSP(demodOut')';
    error_cnt = error_cnt + sum(message ~= ldpcDecOut, 'all');
    if error_cnt / K / (C+num) < err_limit
        running = false;
        break;
    end
end

% calculate BER & show
ber_res(1,jj) = error_cnt / K / (C+num);
fprintf("(MAT) BER is %.5f at snr %0.1fdB spending %03.2fs\n", ber_res(1,jj), snrdb(jj), time_cnt);

if ~running
    break;
end

end

function [PCM, P] = getPCM(bgn, info_length, code_rate, bspath)
    % Check the size & calculate lifting size
    % Base graph 1 is 46 * 68
    % Base graph 2 is 42 * 52 
    if bgn == 1
        if mod(info_length, 22) ~= 0
            error("InValid data length %d, it must be mutiple of 22 for base graph 1", info_length)
        end
        Zc = info_length / 22;
    elseif bgn == 2
        if mod(info_length, 10) ~= 0
            error("InValid data length %d, it must be mutiple of 10 for base graph 2", info_length)
        end
        Zc = info_length / 10;
    else
        error("InValid index: No base graph number %d", bgn)
    end
    
    % load base graph
    persistent bgs
        if isempty(bgs)
            bgs = coder.load(bspath);
        end
    
    % Get lifting set number
    ZSets = {[2  4  8  16  32  64 128 256],... % Set 1
             [3  6 12  24  48  96 192 384],... % Set 2
             [5 10 20  40  80 160 320],...     % Set 3
             [7 14 28  56 112 224],...         % Set 4
             [9 18 36  72 144 288],...         % Set 5
             [11 22 44  88 176 352],...        % Set 6
             [13 26 52 104 208],...            % Set 7
             [15 30 60 120 240]};              % Set 8
        
    for setIdx = 1:8
        if any(Zc==ZSets{setIdx})
            break;
        end
    end

        switch bgn
            case 1
                switch setIdx
                    case 1
                        V = bgs.BG1S1;
                    case 2
                        V = bgs.BG1S2;
                    case 3
                        V = bgs.BG1S3;
                    case 4
                        V = bgs.BG1S4;
                    case 5
                        V = bgs.BG1S5;
                    case 6
                        V = bgs.BG1S6;
                    case 7
                        V = bgs.BG1S7;
                    otherwise % 8
                        V = bgs.BG1S8;
                end
                switch code_rate
                    case 1/2
                        V = V(1:24, 1:46);
                    case 2/3
                        V = V(1:13, 1:35);
                    case 2/5
                        V = V(1:35, 1:57);
                    case 1/3
                        V = V;
                    otherwise
                        error("Not supporting code rate")
                end
            otherwise % bgn = 2
                switch setIdx
                    case 1
                        V = bgs.BG2S1;
                    case 2
                        V = bgs.BG2S2;
                    case 3
                        V = bgs.BG2S3;
                    case 4
                        V = bgs.BG2S4;
                    case 5
                        V = bgs.BG2S5;
                    case 6
                        V = bgs.BG2S6;
                    case 7
                        V = bgs.BG2S7;
                    otherwise % 8
                        V = bgs.BG2S8;
                end
                switch code_rate
                    case 1/2
                        V = V(1:12, 1:22);
                    case 1/3
                        V = V(1:22, 1:32);
                    case 1/5
                        V = V;
                    otherwise
                        error("Not supporting code rate")
                end
        end
    
    % Get shift values matrix & construct PCM
    P = nr5g.internal.ldpc.calcShiftValues(V,Zc);
    
    % construct Full PCM
    [row, col] = size(P);
    PCM = zeros(row*Zc, col*Zc);
    for ii = 1 : row
        for jj = 1 : col
            if P(ii,jj) ~= -1
                row_from = (ii-1)*Zc + 1;
                row_to = ii*Zc;
                col_from = (jj-1)*Zc + 1;
                col_to = jj*Zc;
                PCM(row_from:row_to, col_from:col_to) = circshift(eye(Zc), P(ii,jj), 2);
            end
        end
    end

    PCM = sparse(PCM);
end
    
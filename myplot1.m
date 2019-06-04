% plot the BER-SNR curve

% load ber data
SP = load('BER/SP.mat');
MS = load('BER/MS.mat');
NMS = load('BER/NMS.mat');
max_len = max([length(SP.ber_res) length(MS.ber_res) length(NMS.ber_res)]);

% padding 0 to the same length
SP.ber_res = [SP.ber_res zeros(1,max_len-length(SP.ber_res))];
MS.ber_res = [MS.ber_res zeros(1,max_len-length(MS.ber_res))];
NMS.ber_res = [NMS.ber_res zeros(1,max_len-length(NMS.ber_res))];

% plot BER - SNR
snrdb = (0:0.2:(0.2*max_len-0.2));
figure;
plot(snrdb, SP.ber_res, '--s', 'color', 'r', 'LineWidth', 2);
hold on;
plot(snrdb, MS.ber_res, '--o', 'color', 'g', 'LineWidth', 2);
plot(snrdb, NMS.ber_res, '--p', 'color', 'b', 'LineWidth', 2);
legend('Sum product', 'Min-Sum', 'Normalized MS(0.75)');
set(gca, 'YScale', 'log')
title('BER - SNR');
ylabel('BER');
xlabel('SNR [dB]');
xlim([0,4])
ylim([10^(-6),1]);
hold off;
saveas(gcf, './figure/myplot1.png')

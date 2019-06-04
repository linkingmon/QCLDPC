% plot the BER-SNR curve

% load ber data
MS = load('BER/MS.mat');
LMS = load('BER/LMS.mat');
max_len = max([length(MS.ber_res) length(LMS.ber_res)]);

% padding 0 to the same length
MS.ber_res = [MS.ber_res zeros(1,max_len-length(MS.ber_res))];
LMS.ber_res = [LMS.ber_res zeros(1,max_len-length(LMS.ber_res))];

% plot BER - SNR
snrdb = (0:0.2:(0.2*max_len-0.2));
figure;
plot(snrdb, LMS.ber_res, '--', 'color', 'r', 'LineWidth', 2);
hold on;
plot(snrdb, MS.ber_res, '--', 'color', 'g', 'LineWidth', 2);
legend('Layered MS', 'Min-Sum');
set(gca, 'YScale', 'log')
title('BER - SNR');
ylabel('BER');
xlabel('SNR [dB]');
xlim([0,4])
ylim([10^(-6),1]);
hold off;
saveas(gcf, './figure/myplot2.png')

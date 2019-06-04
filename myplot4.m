% plot the BER-SNR curve of NMS & Layered-NMS

% load ber data
NMS = load('BER/NMS.mat');
NMSq1 = load('BER/NMSqq51.mat');
NMSq2 = load('BER/NMSqq52.mat');
NMSq3 = load('BER/NMSqq53.mat');
max_len = max([length(NMS.ber_res) length(NMSq1.ber_res) length(NMSq2.ber_res) length(NMSq3.ber_res)]);

% padding 0 to the same length
NMS.ber_res = [NMS.ber_res zeros(1,max_len-length(NMS.ber_res))];
NMSq1.ber_res = [NMSq1.ber_res zeros(1,max_len-length(NMSq1.ber_res))];
NMSq2.ber_res = [NMSq2.ber_res zeros(1,max_len-length(NMSq2.ber_res))];
NMSq3.ber_res = [NMSq3.ber_res zeros(1,max_len-length(NMSq3.ber_res))];

% plot BER - SNR
snrdb = (0:0.2:(0.2*max_len-0.2));
figure;
plot(snrdb, NMS.ber_res, '--', 'color', 'g', 'LineWidth', 2);
hold on;
plot(snrdb, NMSq1.ber_res, '--', 'color', 'r', 'LineWidth', 2);
plot(snrdb, NMSq2.ber_res, '--', 'color', 'b', 'LineWidth', 2);
plot(snrdb, NMSq3.ber_res, '--', 'color', 'black', 'LineWidth', 2);
legend('double', 'fixed(5,1)', 'fixed(5,2)', 'fixed(5,3)');
set(gca, 'YScale', 'log')
title('BER - SNR (NMS(0.75))');
ylabel('BER');
xlabel('SNR [dB]');
xlim([0,4])
ylim([10^(-8),1]);
hold off;
saveas(gcf, './figure/myplot4.png')
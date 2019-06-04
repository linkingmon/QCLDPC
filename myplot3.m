% plot the BER-SNR curve of SP & Layered-SP

% load ber data
SP = load('BER/SP.mat');
LSP = load('BER/LSP.mat');
max_len = max([length(SP.ber_res) length(LSP.ber_res)]);

% padding 0 to the same length
SP.ber_res = [SP.ber_res zeros(1,max_len-length(SP.ber_res))];
LSP.ber_res = [LSP.ber_res zeros(1,max_len-length(LSP.ber_res))];

% plot BER - SNR
snrdb = (0:0.2:(0.2*max_len-0.2));
figure;
plot(snrdb, LSP.ber_res, '--', 'color', 'r', 'LineWidth', 2);
hold on;
plot(snrdb, SP.ber_res, '--', 'color', 'g', 'LineWidth', 2);
legend('Layered SP', 'SP');
set(gca, 'YScale', 'log')
title('BER - SNR');
ylabel('BER');
xlabel('SNR [dB]');
xlim([0,4])
ylim([10^(-8),1]);
hold off;
saveas(gcf, './figure/myplot3.png')

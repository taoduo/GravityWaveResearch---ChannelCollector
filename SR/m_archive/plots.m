% plot the parameters vs. powers with cutoff as legends
semilogx(opt_10(:, 1), opt_10(:, 2), opt_15(:, 1), opt_15(:, 2), ...
    opt_20(:, 1), opt_20(:, 2), 'LineWidth', 1.5)
xlabel('Power(W)', 'FontSize', 20)
xlim([0.5, 200])
ylabel('Transmission', 'FontSize', 20)
legend('10Hz', '15Hz', '20Hz')
grid on;
xt = get(gca, 'XTick');
set(gca, 'FontSize', 20);

% plot the model comparisons
% plot(flat_10(:, 1), flat_10(:, 5), pl_10(:, 1), pl_10(:, 4))
% xlabel('Power(W)')
% ylabel('\Omega_{\alpha}')
% legend('opt\_flat', 'opt\_powerlaw')


% construct_uk_bias_nelson_nikolov.m
% Constructs UK output gap bias series from Nelson & Nikolov (2001), Table 3
% Real-time measurement error: y_t^final - y_t^realt (average by period)
% Sample: 1965 Q1 - 1995 Q4 (124 quarters)
%
% Sign convention: measurement error = final - real-time = y*_perceived - y*_true
% This is exactly ystarbias in Beck & Wieland. No sign flip needed.

clear; clc;

%% --- Period definitions (quarter indices into 1-124) ---
% 1965Q1 = index 1, 1995Q4 = index 124

periods = [
    1,  20;   % 1965Q1 - 1969Q4  (20 quarters)
    21, 44;   % 1970Q1 - 1975Q4  (24 quarters)
    45, 60;   % 1976Q1 - 1979Q4  (16 quarters)
    61, 84;   % 1980Q1 - 1985Q4  (24 quarters)
    85, 100;  % 1986Q1 - 1989Q4  (16 quarters)
    101, 124; % 1990Q1 - 1995Q4  (24 quarters)
];

% Average measurement error from Table 3 (Nelson & Nikolov 2001)
bias_means = [1.25; 4.72; 10.61; 3.74; 8.10; 3.02];

T = 124;

%% --- Smooth interpolation ---
% Assign each period's mean to its midpoint quarter, then interpolate linearly.

n_periods = size(periods, 1);
midpoints = round((periods(:,1) + periods(:,2)) / 2);  % midpoint index of each period

% Build interpolation nodes: midpoints + flat extensions at boundaries
xq = (1:T)';
xi = midpoints;
yi = bias_means;

% Linear interpolation between midpoints; flat beyond first/last midpoint
ystarbias = interp1(xi, yi, xq, 'linear', 'extrap');

% Clamp extrapolated tails to nearest period mean (flat, not diverging)
ystarbias(xq < xi(1))   = yi(1);
ystarbias(xq > xi(end)) = yi(end);

%% --- Verification ---
fprintf('=== UK Output Gap Bias Series ===\n');
fprintf('Total quarters: %d (1965Q1-1995Q4)\n\n', T);

period_labels = {'1965Q1-1969Q4', '1970Q1-1975Q4', '1976Q1-1979Q4', ...
                 '1980Q1-1985Q4', '1986Q1-1989Q4', '1990Q1-1995Q4'};

fprintf('%-20s  Target    Actual\n', 'Period');
fprintf('%s\n', repmat('-', 1, 42));
for p = 1:n_periods
    idx = periods(p,1):periods(p,2);
    fprintf('%-20s  %6.2f    %6.2f\n', period_labels{p}, bias_means(p), mean(ystarbias(idx)));
end

fprintf('\nPeak bias: %.2f pp at quarter %d\n', max(ystarbias), find(ystarbias == max(ystarbias), 1));
fprintf('Min  bias: %.2f pp at quarter %d\n', min(ystarbias), find(ystarbias == min(ystarbias), 1));

%% --- Plot ---
quarters = (1965 + (0:T-1)/4)';  % decimal year axis

figure;
plot(quarters, ystarbias, 'b-', 'LineWidth', 2); hold on;

% Mark period means as horizontal reference lines
colors = lines(n_periods);
for p = 1:n_periods
    idx = periods(p,1):periods(p,2);
    plot(quarters(idx), repmat(bias_means(p), size(idx)), '--', ...
         'Color', colors(p,:), 'LineWidth', 1.2);
end

yline(0, 'k:', 'LineWidth', 1);
xlabel('Year');
ylabel('Output gap bias (pp)');
title('UK Real-Time Output Gap Mismeasurement (Nelson & Nikolov 2001, Table 3)');
legend(['Smoothed series', period_labels], 'Location', 'northwest', 'FontSize', 8);
grid on;
xlim([1965, 1996]);

%% --- Save ---
dates = (1965 + (0:T-1)'/4);
T_out = table(dates, ystarbias, 'VariableNames', {'Date', 'Bias'});
writetable(T_out, 'UK_output_gap_bias_1965_1995.csv');
fprintf('\nSaved: UK_output_gap_bias_1965_1995.csv\n');

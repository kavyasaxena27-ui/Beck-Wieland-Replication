% Construct stylized UK output gap bias 1965-1995
% Based on Nelson & Nikolov (2001) Table C

T = 124;  % 1965 Q1 to 1995 Q4
ystarbias = zeros(T, 1);

% Key periods and their mean biases
periods = [
    1,   20,  4.84;   % 1965-1969
    21,  40,  1.25;   % 1970-1974
    41,  44,  4.72;   % 1975
    45,  60,  10.61;  % 1976-1979 (PEAK!)
    61,  80,  3.75;   % 1980-1984
    81,  100, 7.24;   % 1985-1989
    101, 124, 3.02;   % 1990-1995
];

% Create series with smooth transitions
for i = 1:size(periods, 1)
    t_start = periods(i, 1);
    t_end = periods(i, 2);
    bias_mean = periods(i, 3);
    
    % Assign mean to this period
    ystarbias(t_start:t_end) = bias_mean;
    
    % Smooth transition to next period (if not last)
    if i < size(periods, 1)
        % Linear transition over 4 quarters (1 year)
        t_trans_start = t_end - 3;
        t_trans_end = t_end;
        next_bias = periods(i+1, 3);
        
        transition = linspace(bias_mean, next_bias, 4);
        ystarbias(t_trans_start:t_trans_end) = transition;
    end
end

% Plot to check
figure;
time = (1965:0.25:1994.75)';
plot(time, ystarbias, 'b-', 'LineWidth', 2);
hold on;
plot([1976 1976], ylim, 'r--', 'LineWidth', 1);  % Mark 1976-79 peak
plot([1979 1979], ylim, 'r--', 'LineWidth', 1);
xlabel('Year');
ylabel('Potential Output Bias (pp)');
title('UK Output Gap Bias 1965-1995 (Nelson & Nikolov 2001)');
text(1977.5, 11, 'Peak Period', 'FontSize', 12, 'Color', 'r');
grid on;

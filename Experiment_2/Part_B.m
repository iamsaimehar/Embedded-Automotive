clc;
clear;
close all;

%% ===============================
%      TPMS WARNING DETECTION
% ================================

%% SIMULATION SETTINGS
Fs = 100;                % sampling frequency (Hz)
T  = 20;                 % simulation time (s)
t  = 0:1/Fs:T;

%% ===============================
% 1. TRUE TIRE PRESSURE PROFILE
% ===============================

P_nominal = 220;         % kPa (recommended pressure)
P_low     = 150;         % final leak pressure
leak_start = 8;          % leak begins at 8 sec

P = P_nominal*ones(size(t));

% gradual leak
P(t > leak_start) = linspace(P_nominal, P_low, sum(t > leak_start));


%% ===============================
% 2. PRESSURE SENSOR MODEL
% ===============================

Sensitivity = 0.02;      % V/kPa
Offset      = 0.5;       % V

noise = 0.02*randn(size(t));   % electrical noise

% Temperature drift
Temp = 25 + 10*sin(0.2*t);
drift_coeff = 0.001;
drift = drift_coeff*(Temp-25);

% Sensor output
Vout = Sensitivity*P + Offset + noise + drift;


%% ===============================
% 3. ADC MODEL (12-bit)
% ===============================

ADC_bits = 12;
Vref = 5;

ADC_counts = round((Vout/Vref)*(2^ADC_bits-1));
Vadc = (ADC_counts/(2^ADC_bits-1))*Vref;


%% ===============================
% 4. MCU PRESSURE ESTIMATION
% ===============================

P_est = (Vadc - Offset)/Sensitivity;


%% ===============================
% 5. FILTERING (remove noise)
% ===============================

window = 20;                       % moving average
P_filt = movmean(P_est, window);


%% ===============================
% 6. WARNING DETECTION LOGIC
% ===============================

% --- 80% rule (industry standard)
threshold = 0.8 * P_nominal;

below_threshold = P_filt < threshold;

% --- 2 second confirmation delay
delay_time = 2;                    
delay_samples = delay_time * Fs;

warning = movsum(below_threshold, delay_samples) >= delay_samples;


%% ===============================
% 7. DISPLAY MESSAGE
% ===============================

if any(warning)
    fprintf('\n⚠️  LOW TIRE PRESSURE WARNING TRIGGERED\n');
    first_time = t(find(warning,1));
    fprintf('Warning detected at time = %.2f seconds\n\n', first_time);
else
    fprintf('Pressure Normal\n');
end


%% ===============================
% 8. PLOTS
% ===============================

figure('Position',[200 100 900 700])

subplot(4,1,1)
plot(t,P,'LineWidth',2)
ylabel('True Pressure (kPa)')
title('Actual Tire Pressure')
grid on

subplot(4,1,2)
plot(t,Vout,'r')
ylabel('Sensor Voltage (V)')
title('Sensor Output (Noise + Drift)')
grid on

subplot(4,1,3)
plot(t,P_filt,'b','LineWidth',2)
hold on
yline(threshold,'r--','Threshold')
ylabel('Estimated Pressure (kPa)')
title('Filtered Pressure & Threshold')
legend('Estimated','Threshold')
grid on

subplot(4,1,4)
stairs(t,warning,'k','LineWidth',2)
ylim([0 1.2])
ylabel('Warning')
xlabel('Time (s)')
title('TPMS Warning Signal (1 = LOW Pressure)')
grid on
clc;
clear;
close all;

%% PARAMETERS
Fs = 100;                 % Sampling frequency (Hz)
T = 20;                   % Simulation time (s)
t = 0:1/Fs:T;

P_nominal = 220;          % Normal tire pressure (kPa)
P_low = 160;              % Leak pressure
leak_start = 8;           % Leak begins at 8 sec

%% PRESSURE PROFILE (simulate leak)
P = P_nominal * ones(size(t));
P(t > leak_start) = linspace(P_nominal, P_low, sum(t > leak_start));

%% SENSOR MODEL
Sensitivity = 0.02;       % V/kPa
Offset = 0.5;             % V

noise = 0.02 * randn(size(t));     % electrical noise

%% TEMPERATURE DRIFT MODEL
Temp = 25 + 10*sin(0.1*t);         % varying temperature
drift_coeff = 0.001;               % V/°C
drift = drift_coeff*(Temp-25);

%% SENSOR OUTPUT VOLTAGE
Vout = Sensitivity*P + Offset + noise + drift;

%% ADC CONVERSION
ADC_bits = 12;
Vref = 5;

ADC_counts = round((Vout/Vref)*(2^ADC_bits-1));
Vadc = (ADC_counts/(2^ADC_bits-1))*Vref;

%% RECONSTRUCT PRESSURE (MCU side)
P_est = (Vadc - Offset)/Sensitivity;

%% TPMS WARNING LOGIC
threshold = 180;      % kPa

warning = P_est < threshold;

%% PLOTS
figure;

subplot(3,1,1)
plot(t,P,'LineWidth',2)
ylabel('Pressure (kPa)')
title('True Tire Pressure')

subplot(3,1,2)
plot(t,Vout,'r')
ylabel('Sensor Voltage (V)')
title('Sensor Output with Noise & Drift')

subplot(3,1,3)
plot(t,P_est,'b','LineWidth',2)
hold on
yline(threshold,'r--','Threshold')
stairs(t,warning*threshold,'k','LineWidth',1.5)
ylabel('Estimated Pressure (kPa)')
xlabel('Time (s)')
title('TPMS Detection Logic')
legend('Estimated','Threshold','Warning')
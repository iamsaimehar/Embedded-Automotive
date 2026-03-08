% The DHT11 outputs a digital value corresponding to the integer part of
% the temperature in degrees Celsius. This model simulates that behaviour.

% Temperature range (0°C to 50°C, step 1°C)
T = 0:1:50;

% Digital output: integer part of temperature
digital_out = floor(T);   % DHT11 resolution is 1°C

% Plot characteristic
figure;
plot(T, digital_out, 'bo-', 'LineWidth', 1.5);
xlabel('Temperature (°C)');
ylabel('Digital Output (counts)');
title('DHT11 Temperature Sensor Characteristic');
grid on;
axis([-5 55 -1 55]);

% Optional: Function to convert temperature to DHT11 digital value
% (useful for simulation in a larger system)
digital_value = @(temp) floor(temp);

% Example: At 23.7°C, the DHT11 would output 23
fprintf('At 23.7°C, DHT11 output: %d\n', digital_value(23.7));
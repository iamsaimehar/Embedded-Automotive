clc;
clear all;
close all;

sensor_data = xlsread('LM35_Dataset.xlsx');
temp = sensor_data(:, 1); % Input Temperature (Sensed from Environment) = x
volts = sensor_data(:, 2) % Sensor Output in Volts = y

figure,
plot(temp, volts, 'r*-');
grid on;
xlabel('Temperature');
ylabel('Volts');

% For adding a straight line use y = mx + c
% Where y = output and x = input of the temperature sensor
% Here, x and y are known and m and c parameters are unknown
% We use polyfit function to get the parameter values of m and c, given the
% x and y data
func = polyfit(temp, volts, 1) % 1 used to define straight line

% Here, m = 10.0001 and c = 0.7523
% So, the temperature sensor model is:
% y = mx + c => y = 10.0001x + 0.7523
% We can now predict the value the sensor will produce at some unknown
% temperature x
x = 8.25;
y = 10.0001 * x + 0.7523;

% The value will be 83.2531 volts when the sensed temperature is 8.25
% celsius
hold on;
plot(x, y, 'b*');
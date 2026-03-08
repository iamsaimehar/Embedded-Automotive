% Coefficients (standard values)
R0 = 100; % Resistance in ohms
A = 3.9083e-3; % Linear coefficient
B = -5.775e-7; % Quadratic coefficient (negative for slight nonlinearity)
C = -4.183e-12; % Sub-zero correction coefficient

% Function to compute PT100 resistance for a given temperature T (°C)
function R = pt100_resistance(T)
R0 = 100;
A = 3.9083e-3;
B = -5.775e-7;
C = -4.183e-12;

if T >= 0 % For temperatures >= 0°C, use the quadratic equation
   R = R0 * (1 + A*T + B*T^2);
else % For sub-zero temperatures, add the C term to model the extra curvature
   R = R0 * (1 + A*T + B*T^2 + C*(T-100)*T^3);
end
end

% Function to compute temperature from a given resistance R (for T >= 0) 
% This solves the quadratic equation R = R0(1 + A*T + B*T^2)
function T = pt100_temperature(R)
R0 = 100;
A = 3.9083e-3;
B = -5.775e-7;
% Quadratic formula: R = R0(1 + A*T + B*T^2)
T = (-A + sqrt(A^2 - 4*B*(1 - R/R0))) / (2*B);
end

% Generate temperature vector from -200°C to 850°C
T = -200:1:850;

% Compute resistance for each temperature using arrayfun
R = arrayfun(@pt100_resistance, T);

% Plot the characteristic curve
plot(T, R,"r*") % Red asterisks for each data point
xlabel('Temperature (°C)')
ylabel('Resistance (Ohms)')
title('PT100 Characteristic Curve')
grid on
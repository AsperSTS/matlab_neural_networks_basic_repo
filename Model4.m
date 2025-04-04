%{
    MODELO CANCER
%}

%data = csvread('dataset4_Cancer.csv');
T = readtable('dataset4_Cancer.csv');
data = table2array(T);

% Verificar dimensiones de los datos cargados
[num_samples, num_columns] = size(data);
disp(['Número de muestras: ', num2str(num_samples)]);
disp(['Número de columnas: ', num2str(num_columns)]);

% Separar características y clases
X = data(:, 2:57)'; % Datos de entrenamiento
t = data(:, 1)';   % Clases

% Verificar que X y t tienen el mismo número de muestras
[~, samples_X] = size(X);
samples_t = length(t);
disp(['Muestras en X: ', num2str(samples_X)]);
disp(['Muestras en t: ', num2str(samples_t)]);

if samples_X ~= samples_t
    error('El número de muestras en X y t no coincide');
end
[X_norm, ps] = mapminmax(X);

% Crear la red neuronal usando la sintaxis actualizada
RN = feedforwardnet([20,15,10]);  % Red feedforward con capas ocultas de 5 y 3 neuronas

% Correct transfer function configuration
RN.layers{1}.transferFcn = 'tansig';    % First hidden layer
RN.layers{2}.transferFcn = 'tansig';    % Second hidden layer
RN.layers{3}.transferFcn = 'softmax';   % For multi-class classification

% Configurar algoritmo de entrenamiento
RN.trainFcn = 'trainlm';%'trainbr';

% Configuración del entrenamiento
RN.trainParam.epochs = 50;      % Número máximo de épocas
RN.trainParam.goal = 0.001;%1e-5;        % Error objetivo
%RN.trainParam.max_fail = 20;       % Máximo número de fallos en validación
% todo el conjunto para entrenamiento
RN.divideParam.trainRatio = 1;
RN.divideParam.valRatio = 0;
RN.divideParam.testRatio = 0;

% Entrenamiento de la red
[RNE, tr] = train(RN, X_norm, t);

% Simulación con los datos de entrenamiento
y = sim(RNE, X_norm);

% Cálculo del error
error_cuadratico = perform(RNE, y, t);
m = length(t);
aciertos = 0;
for i=1:m
    if(round(y(i))==t(i))
        aciertos = aciertos+1;
    end
end
porcentaje = (aciertos/m)*100;

% Mostrar resultados
disp(['Error cuadrático medio: ', num2str(error_cuadratico)]);
disp(['Precisión de clasificación: ', num2str(porcentaje), '%']);

% Graficar evolución del entrenamiento - usamos la función figure para evitar conflictos
figure;
% Usamos la función built-in de MATLAB calificándola con "builtin"
builtin('plot', tr.epoch, tr.perf, 'b-', tr.epoch, tr.vperf, 'g-', tr.epoch, tr.tperf, 'r-');
legend('Entrenamiento', 'Validación', 'Test');
xlabel('Épocas');
ylabel('Error Cuadrático Medio');
title('Evolución del Entrenamiento');



% Guardar el modelo entrenado
save('modelo4_Cancer.mat', 'RNE');
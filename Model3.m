%{
    MODELO FERTILIDAD
    DATASET: 10 COLUMNAS, 100 FILAS

    CLASES:
    - SEKER: 1
    - BARBUNYA: 2
    - BOMBAY: 3
    - CALI: 4
    - HOROZ: 5
    - SIRA: 6
    - DERMASON: 7
%}
T = readtable('dataset3_Beans.csv');
data = table2array(T);

% Verificar dimensiones de los datos cargados
[num_samples, num_columns] = size(data);
disp(['Número de muestras: ', num2str(num_samples)]);
disp(['Número de columnas: ', num2str(num_columns)]);

% Separar características y clases
X = data(:, 1:16)'; % Transponer para que cada columna sea una muestra
t = data(:, 17)';   % Vector de clases

% Verificar que X y t tienen el mismo número de muestras
[~, samples_X] = size(X);
samples_t = length(t);
disp(['Muestras en X: ', num2str(samples_X)]);
disp(['Muestras en t: ', num2str(samples_t)]);

if samples_X ~= samples_t
    error('El número de muestras en X y t no coincide');
end
[X_norm, ps] = mapminmax(X);

% Crear la red neuronal
RN = feedforwardnet([8, 8, 5]);
% Configuracion de activación y entrenamiento
RN.layers{1}.transferFcn = 'tansig';
RN.layers{2}.transferFcn = 'tansig';
RN.layers{3}.transferFcn = 'softmax';
RN.trainFcn = 'trainbr';
% parametros de entrenamiento
RN.trainParam.epochs = 1000;
RN.trainParam.goal = 0.001;
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

% Redondear las salidas para clasificación
y_class = round(y);

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
save('modelo3_Beans.mat', 'RNE');
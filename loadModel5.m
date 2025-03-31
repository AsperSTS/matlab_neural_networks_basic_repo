% Cargar el modelo entrenado
load('modelo5_Circles.mat', 'RNE');

% Cargar nuevos datos para probar el modelo
nuevos_datos = csvread('dataset5_Circles.csv'); % Asegúrate de que este archivo existe

% Separar características de los nuevos datos
X_nuevos = nuevos_datos(:, 1:2)';
t = nuevos_datos(:, 3)'; % Columna con etiquetas reales

% Normalizar los nuevos datos usando la misma estructura de preprocesamiento (ps)
[X_nuevos_norm, ps] = mapminmax(X_nuevos);

% Simular la red neuronal
y = sim(RNE, X_nuevos_norm);

% Calcular precisión
m = length(t);
aciertos = 0;
for i=1:m
    if(round(y(i))==t(i))
        aciertos = aciertos+1;
    end
end
porcentaje = (aciertos/m)*100;

% Mostrar resultados
fprintf('Total de datos: %d\n', m);
fprintf('Predicciones correctas: %d\n', aciertos);
fprintf('Precisión de clasificación: %.2f%%\n', porcentaje);

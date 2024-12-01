#!/bin/bash

# 1. Instalar las dependencias de Serverless (npm)
echo "Instalando dependencias de Serverless..."
npm i -D serverless-dotenv-plugin

# 2. Instalar las dependencias de Python (pip)
echo "Instalando dependencias de Python..."
pip install -r requirements.txt

# 3. Cargar las variables de entorno desde el archivo .env
echo "Cargando variables de entorno desde el archivo .env..."
source .env

# 4. Ejecutar Serverless para desplegar las tablas DynamoDB con el stage desde las variables de entorno
echo "Desplegando las tablas DynamoDB con Serverless..."
sls deploy --stage $STAGE

# 5. Ejecutar el script de Python para generar los datos
echo "Ejecutando el script de Python para generar los datos..."
python3 main.py

echo "Proceso de generación de datos completado."

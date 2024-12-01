#!/bin/bash

# 1. Instalar las dependencias de Serverless (npm)
echo "Instalando dependencias de Serverless..."
npm i -D serverless-dotenv-plugin

# 2. Instalar las dependencias de Python (pip)
echo "Instalando dependencias de Python..."
pip install -r requirements.txt

# 3. Ejecutar el script de Python
echo "Ejecutando el script de Python para generar los datos..."
python3 main.py

echo "Proceso de generación de datos completado."

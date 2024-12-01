#!/bin/bash

# 1. Instalar Serverless globalmente
echo "Instalando Serverless globalmente..."
sudo npm i -g serverless

# 2. Ejecutar sls login (esto abrirá una ventana del navegador para loguearte en Serverless)
echo "Iniciando sesión en Serverless..."
sls login

# 3. Instalar las dependencias de Serverless (localmente en el proyecto)
echo "Instalando dependencias de Serverless en el proyecto..."
npm i -D serverless-dotenv-plugin

# 4. Instalar las dependencias de Python (pip)
echo "Instalando dependencias de Python..."
pip install -r requirements.txt

# 5. Crear el archivo .env automáticamente con las variables necesarias

if [ ! -f .env ]; then
    echo "Creando archivo .env..."

    # Solicitar valores del archivo .env
    read -p "Ingrese el nombre de la organización (ORG_NAME): " org_name
    read -p "Ingrese el ARN del rol de IAM (ROLE_ARN): " role_arn
    read -p "Ingrese el stage (STAGE, por ejemplo, dev, prod): " stage

    # Crear el archivo .env con los valores proporcionados
    echo "ORG_NAME=$org_name" > .env
    echo "ROLE_ARN=$role_arn" >> .env
    echo "STAGE=$stage" >> .env

    echo ".env creado con las siguientes variables:"
    cat .env
else
    echo ".env ya existe. No se hará ninguna modificación."
fi

# 6. Configurar las credenciales de AWS automáticamente
echo "Por favor, pega las credenciales de AWS cuando se te solicite."

# Solicitar las credenciales de AWS Academy (se pide que pegues todo el bloque)
read -p "AWS Access Key ID: " aws_access_key_id
read -sp "AWS Secret Access Key: " aws_secret_access_key
echo
read -sp "AWS Session Token: " aws_session_token
echo

# Crear el directorio ~/.aws si no existe
mkdir -p ~/.aws

# Escribir las credenciales en el archivo ~/.aws/credentials
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id=$aws_access_key_id" >> ~/.aws/credentials
echo "aws_secret_access_key=$aws_secret_access_key" >> ~/.aws/credentials
echo "aws_session_token=$aws_session_token" >> ~/.aws/credentials

# Configurar la región de AWS en ~/.aws/config
echo "[default]" > ~/.aws/config
echo "region=us-east-1" >> ~/.aws/config

# 7. Cargar las variables de entorno desde el archivo .env
echo "Cargando variables de entorno desde el archivo .env..."
source .env

# 8. Ejecutar Serverless para desplegar las tablas DynamoDB con el stage desde las variables de entorno
echo "Desplegando las tablas DynamoDB con Serverless..."
sls deploy --stage $STAGE

# 9. Ejecutar el script de Python para generar los datos
echo "Ejecutando el script de Python para generar los datos..."
python3 main.py

echo "Proceso de generación de datos completado."

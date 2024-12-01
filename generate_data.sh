#!/bin/bash

# 1. Comprobar si Serverless está instalado
if ! command -v sls &> /dev/null
then
    echo "Serverless no encontrado, instalando globalmente..."
    sudo npm i -g serverless
else
    echo "Serverless ya está instalado."
fi

# 2. Instalar las dependencias de Serverless (localmente en el proyecto)
echo "Instalando dependencias de Serverless en el proyecto..."
npm i -D serverless-dotenv-plugin

# 3. Instalar las dependencias de Python (pip)
echo "Instalando dependencias de Python..."
pip install -r requirements.txt

# 4. Crear el archivo .env automáticamente con las variables necesarias
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

# 5. Configurar las credenciales de AWS automáticamente
echo "Por favor, ingresa las credenciales de AWS cuando se te solicite."

# Solicitar que el usuario ingrese las credenciales línea por línea (sin ocultar la entrada)
echo "Ingresa tu AWS Access Key ID: "
read aws_access_key_id
echo "Ingresa tu AWS Secret Access Key: "
read aws_secret_access_key
echo "Ingresa tu AWS Session Token: "
read aws_session_token

# Crear el directorio ~/.aws si no existe
mkdir -p ~/.aws

# Escribir las credenciales en el archivo ~/.aws/credentials
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id=$aws_access_key_id" >> ~/.aws/credentials
echo "aws_secret_access_key=$aws_secret_access_key" >> ~/.aws/credentials
echo "aws_session_token=$aws_session_token" >> ~/.aws/credentials

# Verificar si las credenciales fueron escritas correctamente
echo "Verificando las credenciales con AWS..."
aws sts get-caller-identity &> /dev/null

if [ $? -eq 0 ]; then
    echo "Las credenciales de AWS se han configurado correctamente."
else
    echo "Error: No se pudo verificar las credenciales de AWS."
    exit 1
fi

# Configurar la región de AWS en ~/.aws/config
echo "[default]" > ~/.aws/config
echo "region=us-east-1" >> ~/.aws/config

# 6. Cargar las variables de entorno desde el archivo .env
echo "Cargando variables de entorno desde el archivo .env..."
source .env

# 7. Ejecutar Serverless para desplegar las tablas DynamoDB con el stage desde las variables de entorno
echo "Desplegando las tablas DynamoDB con Serverless..."
sls deploy --stage $STAGE

# 8. Ejecutar el script de Python para generar los datos
echo "Ejecutando el script de Python para generar los datos..."
python3 main.py

echo "Proceso de generación de datos completado."

import boto3
import os
from dotenv import load_dotenv
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

# Cargar las variables de entorno
load_dotenv()

# Obtener el valor de 'stage' desde el archivo .env
stage = os.getenv("stage")

# Configurar boto3 para conectarse a DynamoDB usando la región 'us-east-1' directamente en el código
dynamodb = boto3.resource(
    "dynamodb",
    region_name="us-east-1"  # Definir explícitamente la región aquí
)

def get_dynamodb_table_name(table_name):
    """Genera el nombre completo de la tabla DynamoDB usando el 'stage'."""
    return f"{stage}-hotel-{table_name}"

def upload_data_to_dynamodb(items, table_name):
    """Sube los items generados a la tabla DynamoDB correspondiente."""
    table_name = get_dynamodb_table_name(table_name)  # Obtener el nombre completo de la tabla
    table = dynamodb.Table(table_name)

    for item in items:
        try:
            # Inserta los datos en DynamoDB
            table.put_item(Item=item)
            print(f"Item insertado correctamente en {table_name}: {item}")
        except (NoCredentialsError, PartialCredentialsError):
            print("Error: No se encontraron las credenciales de AWS.")
        except Exception as e:
            print(f"Error al insertar el item en {table_name}: {e}")

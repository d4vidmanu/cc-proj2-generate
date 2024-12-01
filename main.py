import json
import os
from dotenv import load_dotenv
import boto3
from scripts.generate_users import generate_users
from scripts.generate_rooms import generate_rooms
from scripts.generate_services import generate_services
from scripts.generate_reservations import generate_reservations
from scripts.generate_payments import generate_payments
from scripts.generate_comments import generate_comments

# Cargar las variables de entorno desde .env
load_dotenv()

# Obtener los valores de las variables desde el archivo .env
org_name = os.getenv("ORG_NAME")
role_arn = os.getenv("ROLE_ARN")
stage = os.getenv("STAGE")

# Verificar que las variables se están cargando correctamente
print(f"ORG_NAME: {org_name}")
print(f"ROLE_ARN: {role_arn}")
print(f"STAGE: {stage}")

# Función para obtener el nombre de la tabla de DynamoDB basado en 'stage'
def get_dynamodb_table_name(table_name):
    return f"{stage}-hotel-{table_name}"

# Función para guardar los datos en formato JSON
def write_to_json(data_list, filename):
    """Escribe los datos en formato JSON en la carpeta 'generated_data'."""
    output_dir = "generated_data"
    os.makedirs(output_dir, exist_ok=True)

    file_path = os.path.join(output_dir, f"{filename}.json")
    
    with open(file_path, mode="w", encoding="utf-8") as file:
        json.dump(data_list, file, ensure_ascii=False, indent=2)

    print(f"Datos guardados en {file_path}")

# Conectar a DynamoDB usando las credenciales del archivo ~/.aws/credentials
dynamodb = boto3.resource('dynamodb')

def upload_data_to_dynamodb(items, table_name):
    """Sube los datos generados a DynamoDB usando el nombre de tabla dinámico."""
    table_name = get_dynamodb_table_name(table_name)  # Obtener el nombre completo de la tabla
    print(f"Subiendo datos a la tabla: {table_name}...")  # Imprimir el nombre completo de la tabla

    table = dynamodb.Table(table_name)

    # Variable para contar cuántos elementos se suben correctamente
    successful_uploads = 0

    for item in items:
        try:
            # Inserta los datos en DynamoDB
            table.put_item(Item=item)
            successful_uploads += 1
        except Exception as e:
            print(f"Error al insertar el item en {table_name}: {e}")

    # Al finalizar la carga de todos los items, se imprime un solo mensaje final
    print(f"Carga de datos a {table_name} completada. {successful_uploads} items fueron subidos correctamente.")

if __name__ == "__main__":
    tenant_ids = ["Hotel1", "Hotel2", "Hotel3"]

    # Step 1: Generate data
    users = generate_users(tenant_ids, 3334)
    rooms = generate_rooms(tenant_ids, 3334)
    services = generate_services(tenant_ids, 3334)
    reservations = generate_reservations(tenant_ids, users, rooms, services, 3334)
    comments = generate_comments(tenant_ids, users, rooms, 3334)
    payments = generate_payments(tenant_ids, reservations, 3334)

    # Step 2: Save the generated data using the write_to_json function
    write_to_json(users, "users")
    write_to_json(rooms, "rooms")
    write_to_json(services, "services")
    write_to_json(reservations, "reservations")
    write_to_json(comments, "comments")
    write_to_json(payments, "payments")

    # Step 3: Upload data to DynamoDB
    upload_data_to_dynamodb(users, "users")
    upload_data_to_dynamodb(rooms, "rooms")
    upload_data_to_dynamodb(services, "services")
    upload_data_to_dynamodb(reservations, "reservations")
    upload_data_to_dynamodb(comments, "comments")
    upload_data_to_dynamodb(payments, "payments")

    # Inform the user when all uploads are done
    print("Todos los datos han sido subidos a DynamoDB.")

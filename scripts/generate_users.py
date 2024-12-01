import uuid
from faker import Faker

faker = Faker()

def generate_users(tenant_ids, count_per_tenant):
    users = []
    for tenant_id in tenant_ids:
        for _ in range(count_per_tenant):
            user_id = str(uuid.uuid4())
            users.append({
                "tenant_id": tenant_id,
                "user_id": user_id,
                "nombre": faker.name(),
                "email": faker.email(),
                "password_hash": faker.sha256(),
                "fecha_registro": faker.date_time_this_year().isoformat(),
            })
    return users

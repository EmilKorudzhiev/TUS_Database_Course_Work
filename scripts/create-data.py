#!/usr/bin/env python3
"""
Data generation script for rental_service database
Generates realistic test data with proper relationships and constraints
"""

import mysql.connector
from mysql.connector import Error
from faker import Faker
from datetime import datetime, timedelta
import random
from decimal import Decimal
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', '3306')),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', 'root'),
    'database': 'rental_service',
    'charset': os.getenv('DB_CHARSET', 'utf8mb4'),
    'auth_plugin': 'mysql_native_password'
}

# Data generation constants
FAKER = Faker('bg_BG')  # Bulgarian locale for realistic names
Faker.seed(42)
random.seed(42)

# Vehicle data
VEHICLES_DATA = [
    # Bicycles
    {'brand': 'Trek', 'model': 'FX 3', 'power_type': 'HUMAN_POWERED', 'vehicle_type': 'BICYCLE',
     'price_per_minute': 0.10, 'price_per_km': 0.50, 'price_for_rental': 5.00},
    {'brand': 'Giant', 'model': 'Escape 3', 'power_type': 'HUMAN_POWERED', 'vehicle_type': 'BICYCLE',
     'price_per_minute': 0.10, 'price_per_km': 0.50, 'price_for_rental': 5.00},
    {'brand': 'Specialized', 'model': 'Rockhopper', 'power_type': 'HUMAN_POWERED', 'vehicle_type': 'BICYCLE',
     'price_per_minute': 0.12, 'price_per_km': 0.60, 'price_for_rental': 6.00},

    # Scooters (Electric only)
    {'brand': 'Xiaomi', 'model': 'Mi 3', 'power_type': 'ELECTRIC', 'vehicle_type': 'SCOOTER', 'price_per_minute': 0.20,
     'price_per_km': None, 'price_for_rental': 10.00},
    {'brand': 'Ninebot', 'model': 'MAX G30', 'power_type': 'ELECTRIC', 'vehicle_type': 'SCOOTER',
     'price_per_minute': 0.25, 'price_per_km': None, 'price_for_rental': 12.00},
    {'brand': 'Segway', 'model': 'Ninebot S', 'power_type': 'ELECTRIC', 'vehicle_type': 'SCOOTER',
     'price_per_minute': 0.30, 'price_per_km': None, 'price_for_rental': 15.00},

    # Microcars
    {'brand': 'Renault', 'model': 'Twizy', 'power_type': 'ELECTRIC', 'vehicle_type': 'MICROCAR',
     'price_per_minute': 0.50, 'price_per_km': 2.50, 'price_for_rental': 25.00},
    {'brand': 'Citroën', 'model': 'Ami', 'power_type': 'ELECTRIC', 'vehicle_type': 'MICROCAR', 'price_per_minute': 0.55,
     'price_per_km': 2.75, 'price_for_rental': 28.00},

    # Superminis
    {'brand': 'Toyota', 'model': 'Aygo', 'power_type': 'PETROL', 'vehicle_type': 'SUPERMINIS', 'price_per_minute': 0.60,
     'price_per_km': 3.00, 'price_for_rental': 35.00},
    {'brand': 'Peugeot', 'model': '208', 'power_type': 'DIESEL', 'vehicle_type': 'SUPERMINIS', 'price_per_minute': 0.65,
     'price_per_km': 3.25, 'price_for_rental': 38.00},
    {'brand': 'Volkswagen', 'model': 'Up!', 'power_type': 'PETROL', 'vehicle_type': 'SUPERMINIS',
     'price_per_minute': 0.70, 'price_per_km': 3.50, 'price_for_rental': 40.00},

    # SUVs
    {'brand': 'Dacia', 'model': 'Duster', 'power_type': 'PETROL', 'vehicle_type': 'SUV', 'price_per_minute': 0.80,
     'price_per_km': 4.00, 'price_for_rental': 50.00},
    {'brand': 'Kia', 'model': 'Niro EV', 'power_type': 'ELECTRIC', 'vehicle_type': 'SUV', 'price_per_minute': 0.90,
     'price_per_km': 4.50, 'price_for_rental': 55.00},
    {'brand': 'BMW', 'model': 'X5', 'power_type': 'HYBRID', 'vehicle_type': 'SUV', 'price_per_minute': 1.20,
     'price_per_km': 6.00, 'price_for_rental': 80.00},

    # Vans
    {'brand': 'Ford', 'model': 'Transit Custom', 'power_type': 'DIESEL', 'vehicle_type': 'VAN',
     'price_per_minute': 1.00, 'price_per_km': 5.00, 'price_for_rental': 65.00},
    {'brand': 'Mercedes', 'model': 'Sprinter', 'power_type': 'DIESEL', 'vehicle_type': 'VAN', 'price_per_minute': 1.20,
     'price_per_km': 6.00, 'price_for_rental': 75.00},
]

# Subscription plans - with detailed structure
SUBSCRIPTION_PLANS = [
    {
        'name': 'Casual Rider',
        'plan_type': 'BASIC',
        'billing_period': 'WEEKLY',
        'price': Decimal('9.99'),
        'duration_days': 7,
        'description': 'Perfect for occasional riders. Includes 5 free bike rides per week, 10% discount on scooters, and priority support.',
    },
    {
        'name': 'Weekly Commuter',
        'plan_type': 'BASIC',
        'billing_period': 'WEEKLY',
        'price': Decimal('19.99'),
        'duration_days': 7,
        'description': 'Ideal for weekday commuters. Unlimited bicycle rides, 5 free scooter rides, and 15% discount on all vehicles.',
    },
    {
        'name': 'Urban Explorer',
        'plan_type': 'BASIC',
        'billing_period': 'MONTHLY',
        'price': Decimal('29.99'),
        'duration_days': 30,
        'description': 'For city explorers. Unlimited bikes and scooters, free first 30 minutes on microcars, and 20% discount on all rentals.',
    },
    {
        'name': 'Professional Plus',
        'plan_type': 'VIP',
        'billing_period': 'MONTHLY',
        'price': Decimal('79.99'),
        'duration_days': 30,
        'description': 'Premium business plan. Unlimited everything, free first hour on all vehicles, 25% discount, dedicated account manager, and priority vehicle access.',
    },
    {
        'name': 'Premium Unlimited',
        'plan_type': 'VIP',
        'billing_period': 'MONTHLY',
        'price': Decimal('149.99'),
        'duration_days': 30,
        'description': 'Ultimate plan. Unlimited usage, free first 2 hours on all vehicles, 30% discount, 24/7 concierge support, and guaranteed vehicle availability.',
    },
    {
        'name': 'Annual Saver',
        'plan_type': 'BASIC',
        'billing_period': 'YEARLY',
        'price': Decimal('299.99'),
        'duration_days': 365,
        'description': 'Best value for committed users. Unlimited bikes, 50 free scooter rides per month, 20% discount on cars, and free vehicle replacement.',
    },
    {
        'name': 'Executive Elite',
        'plan_type': 'VIP',
        'billing_period': 'YEARLY',
        'price': Decimal('899.99'),
        'duration_days': 365,
        'description': 'Top-tier annual membership. Complete unlimited access, free first 3 hours daily, 40% discount on all vehicles, white-glove service, and custom routing.',
    },
]

LOCATIONS = [
    'Central Sofia', 'Vitosha Boulevard', 'Alexander Nevsky Cathedral', 'NDK Sofia',
    'University of Sofia', 'Borisova Gradina Park', 'Zaimoto District', 'Oborishte',
    'Lozengarten', 'Dobraritsa', 'Banishora', 'Iztok District', 'Hadji Dimitar',
    'Druzhba 1', 'Druzhba 2', 'Mladost 1', 'Mladost 2', 'Mladost 3', 'Mladost 4'
]

DOCUMENT_TYPES_CUSTOMER = ['ID_CARD', 'PASSPORT', 'DRIVERS_LICENSE']
DOCUMENT_TYPES_VEHICLE = ['INSURANCE', 'REGISTRATION']


class RentalServiceDataGenerator:
    """Generates realistic data for rental service database"""

    def __init__(self, config):
        self.config = config
        self.connection = None
        self.customers = []
        self.subscription_plans = []
        self.vehicles = []
        self.subscriptions = []
        self.rentals = []

    def connect(self):
        """Establish database connection"""
        try:
            print(f"Attempting to connect to MySQL at {self.config['host']}:{self.config.get('port', 3306)}...")
            print(f"Database: {self.config['database']}, User: {self.config['user']}")

            self.connection = mysql.connector.connect(**self.config)
            print("✓ Connected to database")
            return self.connection
        except Error as e:
            print(f"✗ Connection failed: {e}")
            print("\n💡 Troubleshooting tips:")
            print("   1. Check your .env file exists and has correct credentials")
            print("   2. Verify MySQL is running: docker ps")
            print("   3. Check MySQL user permissions:")
            print(f"      docker exec -it <container> mysql -u{self.config['user']} -p")
            print("   4. Grant permissions if needed:")
            print(f"      GRANT ALL PRIVILEGES ON {self.config['database']}.* TO '{self.config['user']}'@'%';")
            print("      FLUSH PRIVILEGES;")
            raise

    def disconnect(self):
        """Close database connection"""
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("✓ Disconnected from database")

    def execute_query(self, query, data=None, fetch=False):
        """Execute a query with error handling"""
        cursor = self.connection.cursor()
        try:
            if data:
                cursor.execute(query, data)
            else:
                cursor.execute(query)

            if fetch:
                result = cursor.fetchall()
                cursor.close()
                return result
            else:
                self.connection.commit()
                cursor.close()
                return cursor.rowcount
        except Error as e:
            self.connection.rollback()
            print(f"✗ Query error: {e}")
            cursor.close()
            raise

    def generate_customers(self, count=150):
        """Generate customer records"""
        print(f"\n📝 Generating {count} customers...")

        insert_query = """
            INSERT INTO customers 
            (first_name, last_name, gender, email, phone, date_of_birth, status, created_date, updated_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        genders = ['MALE', 'FEMALE', 'OTHER']
        statuses = ['ACTIVE', 'PENDING', 'SUSPENDED', 'CLOSED']
        status_distribution = ['ACTIVE'] * 70 + ['PENDING'] * 15 + ['SUSPENDED'] * 10 + ['CLOSED'] * 5

        # Transliteration mapping for Cyrillic to Latin
        def transliterate(text):
            cyrillic_to_latin = {
                'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ж': 'zh', 'з': 'z',
                'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o', 'п': 'p',
                'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'h', 'ц': 'ts', 'ч': 'ch',
                'ш': 'sh', 'щ': 'sht', 'ъ': 'a', 'ы': 'y', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
                'А': 'A', 'Б': 'B', 'В': 'V', 'Г': 'G', 'Д': 'D', 'Е': 'E', 'Ж': 'Zh', 'З': 'Z',
                'И': 'I', 'Й': 'Y', 'К': 'K', 'Л': 'L', 'М': 'M', 'Н': 'N', 'О': 'O', 'П': 'P',
                'Р': 'R', 'С': 'S', 'Т': 'T', 'У': 'U', 'Ф': 'F', 'Х': 'H', 'Ц': 'Ts', 'Ч': 'Ch',
                'Ш': 'Sh', 'Щ': 'Sht', 'Ъ': 'A', 'Ы': 'Y', 'Ь': '', 'Э': 'E', 'Ю': 'Yu', 'Я': 'Ya'
            }
            result = []
            for char in text:
                result.append(cyrillic_to_latin.get(char, char))
            return ''.join(result)

        for i in range(count):
            gender = random.choice(genders)

            # Generate unique email and phone
            first_name = FAKER.first_name_male() if gender == 'MALE' else (
                FAKER.first_name_female() if gender == 'FEMALE' else FAKER.first_name())
            last_name = FAKER.last_name()

            email_first = transliterate(first_name.lower()).replace(' ', '')
            email_last = transliterate(last_name.lower()).replace(' ', '')
            email = f"{email_first}.{email_last}{i}@example.com"

            # Simple phone format: 888-123-4567 (12 chars, always valid)
            area = random.randint(100, 999)
            prefix = random.randint(100, 999)
            suffix = random.randint(1000, 9999)
            phone = f"{area}-{prefix}-{suffix}"

            dob = FAKER.date_of_birth(minimum_age=18, maximum_age=75)
            status = random.choice(status_distribution)

            # Generate random created_date and updated_date from 2025
            created_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 334))  # Jan 1 - Nov 30, 2025
            updated_date = created_date + timedelta(days=random.randint(0, 100), hours=random.randint(0, 23))

            # Ensure updated_date doesn't go beyond Nov 29, 2025
            max_date = datetime(2025, 11, 29, 23, 59, 59)
            if updated_date > max_date:
                updated_date = max_date

            try:
                self.execute_query(insert_query, (
                    first_name, last_name, gender, email, phone, dob, status, created_date, updated_date
                ))
            except Exception as e:
                print(f"  ⚠ Skipped customer {i + 1}: {e}")
                continue

        print(f"✓ Generated {count} customers")

    def generate_subscription_plans(self):
        """Generate subscription plans"""
        print(f"\n📋 Generating subscription plans...")

        insert_query = """
            INSERT INTO subscription_plans 
            (name, description, plan_type, billing_period, price, currency, duration_days, created_date, updated_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        for plan in SUBSCRIPTION_PLANS:
            # Generate random created_date and updated_date from 2025
            created_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 30))  # Early 2025 for plans
            updated_date = created_date + timedelta(days=random.randint(0, 50), hours=random.randint(0, 23))

            max_date = datetime(2025, 11, 29, 23, 59, 59)
            if updated_date > max_date:
                updated_date = max_date

            try:
                self.execute_query(insert_query, (
                    plan['name'],
                    plan['description'],
                    plan['plan_type'],
                    plan['billing_period'],
                    plan['price'],
                    'EUR',
                    plan['duration_days'],
                    created_date,
                    updated_date
                ))
            except Exception as e:
                print(f"  ⚠ Skipped plan {plan['name']}: {e}")
                continue

        print(f"✓ Generated {len(SUBSCRIPTION_PLANS)} subscription plans")

    def generate_vehicles(self, count=80):
        """Generate vehicle records"""
        print(f"\n🚗 Generating {count} vehicles...")

        insert_query = """
            INSERT INTO vehicles 
            (identifier, registration_number, brand, model, power_type, vehicle_type, status, last_odometer_km, location, price_per_minute, price_per_km, price_for_rental, created_date, updated_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, ST_PointFromText(%s, 4326), %s, %s, %s, %s, %s)
        """

        statuses = ['AVAILABLE', 'RENTED', 'MAINTENANCE', 'INACTIVE']
        status_distribution = ['AVAILABLE'] * 50 + ['RENTED'] * 30 + ['MAINTENANCE'] * 15 + ['INACTIVE'] * 5

        for i in range(count):
            vehicle_template = random.choice(VEHICLES_DATA)
            identifier = f"VEH-{i + 1:05d}"
            registration = f"CA{random.randint(100000, 999999)}"
            odometer = Decimal(str(random.uniform(0, 50000)))
            status = random.choice(status_distribution)

            # Generate location as POINT (Sofia coordinates with variation)
            lat = 42.6977 + random.uniform(-0.05, 0.05)
            lon = 23.3219 + random.uniform(-0.05, 0.05)
            location_point = f"POINT({lon} {lat})"

            # Generate random created_date and updated_date from 2025
            created_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 300))
            updated_date = created_date + timedelta(days=random.randint(0, 30), hours=random.randint(0, 23))

            max_date = datetime(2025, 11, 29, 23, 59, 59)
            if updated_date > max_date:
                updated_date = max_date

            try:
                self.execute_query(insert_query, (
                    identifier,
                    registration,
                    vehicle_template['brand'],
                    vehicle_template['model'],
                    vehicle_template['power_type'],
                    vehicle_template['vehicle_type'],
                    status,
                    odometer,
                    location_point,
                    vehicle_template['price_per_minute'],
                    vehicle_template['price_per_km'],
                    vehicle_template['price_for_rental'],
                    created_date,
                    updated_date
                ))
            except Exception as e:
                print(f"  ⚠ Skipped vehicle {i + 1}: {e}")
                continue

        print(f"✓ Generated {count} vehicles")

    def generate_subscriptions(self, count=250):
        """Generate subscription records"""
        print(f"\n📅 Generating {count} subscriptions...")

        # Get customer and plan IDs
        customers = self.execute_query("SELECT id FROM customers LIMIT 150", fetch=True)
        plans = self.execute_query("SELECT id FROM subscription_plans", fetch=True)

        insert_query = """
            INSERT INTO subscriptions 
            (customer_id, subscription_plan_id, start_date, end_date, status, auto_renewal, created_date, updated_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        statuses = ['ACTIVE', 'PAUSED', 'CANCELLED']
        status_distribution = ['ACTIVE'] * 70 + ['PAUSED'] * 15 + ['CANCELLED'] * 15

        for i in range(count):
            customer_id = random.choice(customers)[0]
            plan_id = random.choice(plans)[0]

            # Start date somewhere in 2025
            start_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 320))
            end_date = None
            status = random.choice(status_distribution)
            auto_renewal = random.choice([True, False])

            if status == 'CANCELLED':
                end_date = start_date + timedelta(days=random.randint(5, 90))

            # created_date should be before start_date
            created_date = start_date - timedelta(days=random.randint(1, 30), hours=random.randint(0, 23))
            if created_date < datetime(2025, 1, 1):
                created_date = datetime(2025, 1, 1)

            # updated_date should be after created_date
            if status == 'CANCELLED' and end_date:
                # For cancelled subscriptions, updated_date might be around cancellation
                updated_date = datetime.combine(end_date, datetime.min.time()) + timedelta(days=random.randint(0, 5), hours=random.randint(0, 23))
            else:
                updated_date = created_date + timedelta(days=random.randint(0, 60), hours=random.randint(0, 23))

            max_date = datetime(2025, 11, 29, 23, 59, 59)
            if updated_date > max_date:
                updated_date = max_date

            try:
                self.execute_query(insert_query, (
                    customer_id, plan_id, start_date.date(), end_date, status, auto_renewal, created_date, updated_date
                ))
            except Exception as e:
                print(f"  ⚠ Skipped subscription {i + 1}: {e}")
                continue

        print(f"✓ Generated {count} subscriptions")

    def generate_documents(self):
        """Generate customer and vehicle documents"""
        print(f"\n📄 Generating documents...")

        customers = self.execute_query("SELECT id FROM customers", fetch=True)
        vehicles = self.execute_query("SELECT id FROM vehicles", fetch=True)

        # Separate insert queries for customer and vehicle documents
        customer_doc_insert = """
            INSERT INTO documents 
            (customer_id, document_number, document_type, issue_date, expiry_date, created_date, updated_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        vehicle_doc_insert = """
            INSERT INTO documents 
            (vehicle_id, document_number, document_type, issue_date, expiry_date, created_date, updated_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        doc_count = 0

        # Generate customer documents
        for customer_id, in customers:
            # 70% customers have ID card or passport
            if random.random() < 0.7:
                doc_type = random.choice(['ID_CARD', 'PASSPORT'])
                doc_number = f"{doc_type[:3]}{random.randint(100000, 999999)}"
                issue_date = datetime(2025, 1, 1) + timedelta(days=random.randint(-1825, 300))  # Can be issued before 2025
                expiry_date = issue_date + timedelta(days=random.randint(1825, 3650))

                # created_date should be within reasonable time of issue_date but in 2025
                if issue_date.year >= 2025:
                    created_date = issue_date - timedelta(days=random.randint(0, 30))
                else:
                    created_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 60))

                if created_date < datetime(2025, 1, 1):
                    created_date = datetime(2025, 1, 1)

                updated_date = created_date + timedelta(days=random.randint(0, 50), hours=random.randint(0, 23))
                max_date = datetime(2025, 11, 29, 23, 59, 59)
                if updated_date > max_date:
                    updated_date = max_date

                try:
                    self.execute_query(customer_doc_insert, (
                        customer_id, doc_number, doc_type,
                        issue_date.date(), expiry_date.date(), created_date, updated_date
                    ))
                    doc_count += 1
                except Exception as e:
                    print(f"  ⚠ Skipped customer document: {e}")
                    pass

            # 85% customers have driver's license
            if random.random() < 0.85:
                doc_number = f"DL{random.randint(1000000, 9999999)}"
                issue_date = datetime(2025, 1, 1) + timedelta(days=random.randint(-1825, 300))
                expiry_date = issue_date + timedelta(days=3650)  # 10 year validity

                if issue_date.year >= 2025:
                    created_date = issue_date - timedelta(days=random.randint(0, 30))
                else:
                    created_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 60))

                if created_date < datetime(2025, 1, 1):
                    created_date = datetime(2025, 1, 1)

                updated_date = created_date + timedelta(days=random.randint(0, 50), hours=random.randint(0, 23))
                max_date = datetime(2025, 11, 29, 23, 59, 59)
                if updated_date > max_date:
                    updated_date = max_date

                try:
                    self.execute_query(customer_doc_insert, (
                        customer_id, doc_number, 'DRIVERS_LICENSE',
                        issue_date.date(), expiry_date.date(), created_date, updated_date
                    ))
                    doc_count += 1
                except Exception as e:
                    print(f"  ⚠ Skipped driver's license: {e}")
                    pass

        # Generate vehicle documents
        for vehicle_id, in vehicles:
            # Insurance
            doc_number = f"INS{random.randint(100000, 999999)}"
            issue_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 300))
            expiry_date = issue_date + timedelta(days=365)

            created_date = issue_date - timedelta(days=random.randint(0, 15))
            if created_date < datetime(2025, 1, 1):
                created_date = datetime(2025, 1, 1)

            updated_date = created_date + timedelta(days=random.randint(0, 30), hours=random.randint(0, 23))
            max_date = datetime(2025, 11, 29, 23, 59, 59)
            if updated_date > max_date:
                updated_date = max_date

            try:
                self.execute_query(vehicle_doc_insert, (
                    vehicle_id, doc_number, 'INSURANCE',
                    issue_date.date(), expiry_date.date(), created_date, updated_date
                ))
                doc_count += 1
            except Exception as e:
                print(f"  ⚠ Skipped insurance: {e}")
                pass

            # Registration
            doc_number = f"REG{random.randint(1000000, 9999999)}"
            issue_date = datetime(2025, 1, 1) + timedelta(days=random.randint(-1095, 300))
            expiry_date = issue_date + timedelta(days=random.randint(1825, 3650))

            if issue_date.year >= 2025:
                created_date = issue_date - timedelta(days=random.randint(0, 15))
            else:
                created_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 60))

            if created_date < datetime(2025, 1, 1):
                created_date = datetime(2025, 1, 1)

            updated_date = created_date + timedelta(days=random.randint(0, 30), hours=random.randint(0, 23))
            max_date = datetime(2025, 11, 29, 23, 59, 59)
            if updated_date > max_date:
                updated_date = max_date

            try:
                self.execute_query(vehicle_doc_insert, (
                    vehicle_id, doc_number, 'REGISTRATION',
                    issue_date.date(), expiry_date.date(), created_date, updated_date
                ))
                doc_count += 1
            except Exception as e:
                print(f"  ⚠ Skipped registration: {e}")
                pass

        print(f"✓ Generated {doc_count} documents")

    def generate_rentals(self, count=300):
        """Generate rental records with waypoints"""
        print(f"\n🗺️  Generating {count} rentals with waypoints...")

        customers = self.execute_query("SELECT id FROM customers", fetch=True)
        vehicles = self.execute_query("SELECT id FROM vehicles", fetch=True)

        rental_insert = """
            INSERT INTO rentals 
            (customer_id, vehicle_id, start_datetime, end_datetime, price, currency, status, distance_km, created_date, updated_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        rental_update_status = """
            UPDATE rentals 
            SET status = %s, updated_date = %s
            WHERE id = %s
        """

        waypoint_insert = """
            INSERT INTO rental_waypoints 
            (rental_id, location, timestamp, speed, created_date, updated_date)
            VALUES (%s, ST_PointFromText(%s, 4326), %s, %s, %s, %s)
        """

        statuses = ['ACTIVE', 'COMPLETED', 'CANCELLED']
        status_distribution = ['COMPLETED'] * 80 + ['ACTIVE'] * 15 + ['CANCELLED'] * 5

        rental_count = 0
        waypoint_count = 0

        for i in range(count):
            customer_id = random.choice(customers)[0]
            vehicle_id = random.choice(vehicles)[0]

            start_datetime = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 330), hours=random.randint(0, 23), minutes=random.randint(0, 59))
            duration_minutes = random.randint(15, 240)
            end_datetime = start_datetime + timedelta(minutes=duration_minutes)

            final_status = random.choice(status_distribution)

            # For ACTIVE rentals, no end_datetime
            if final_status == 'ACTIVE':
                end_datetime = None

            # Calculate price based on duration and distance
            distance_km = Decimal(str(random.uniform(0.5, 50)))
            price = Decimal(str(random.uniform(5, 200)))

            # created_date should be before start_datetime
            created_date = start_datetime - timedelta(hours=random.randint(0, 72))
            if created_date < datetime(2025, 1, 1):
                created_date = datetime(2025, 1, 1)

            # Initial updated_date when creating the rental
            initial_updated_date = start_datetime + timedelta(minutes=random.randint(1, 10))

            max_date = datetime(2025, 11, 29, 23, 59, 59)
            if initial_updated_date > max_date:
                initial_updated_date = max_date

            try:
                cursor = self.connection.cursor()

                # Step 1: Insert rental with ACTIVE status initially
                cursor.execute(rental_insert, (
                    customer_id, vehicle_id, start_datetime, end_datetime,
                    price, 'EUR', 'ACTIVE', distance_km, created_date, initial_updated_date
                ))
                self.connection.commit()
                rental_id = cursor.lastrowid
                cursor.close()
                rental_count += 1

                # Step 2: Generate waypoints for rentals that will be completed
                if final_status == 'COMPLETED':
                    # Calculate number of waypoints based on rental duration
                    # More waypoints for longer rentals, with points every 30-90 seconds
                    duration_seconds = duration_minutes * 60
                    avg_interval_seconds = random.randint(30, 90)  # 30-90 seconds between points
                    num_waypoints = max(10, min(50, duration_seconds // avg_interval_seconds))

                    current_time = start_datetime
                    current_lat = 42.6977 + random.uniform(-0.02, 0.02)  # Starting position
                    current_lon = 23.3219 + random.uniform(-0.02, 0.02)

                    for wp in range(num_waypoints):
                        # Generate waypoint with smaller incremental changes for realistic path
                        # Movement between 0.0001 to 0.001 degrees (~10-100 meters per waypoint)
                        lat_change = random.uniform(-0.001, 0.001)
                        lon_change = random.uniform(-0.001, 0.001)

                        current_lat += lat_change
                        current_lon += lon_change

                        # Keep within Sofia area bounds
                        current_lat = max(42.65, min(42.75, current_lat))
                        current_lon = max(23.27, min(23.37, current_lon))

                        # Time increment: 30-120 seconds between waypoints
                        time_increment = random.randint(30, 120)
                        current_time = current_time + timedelta(seconds=time_increment)

                        # Realistic speed: 0-60 km/h, with occasional stops
                        if random.random() < 0.15:  # 15% chance of being stopped
                            speed = random.uniform(0, 2)
                        else:
                            speed = random.uniform(10, 60)

                        point_text = f"POINT({current_lon} {current_lat})"

                        # Waypoint created_date should be close to the waypoint timestamp
                        wp_created = current_time - timedelta(seconds=random.randint(0, 30))
                        wp_updated = current_time + timedelta(seconds=random.randint(0, 120))

                        cursor = self.connection.cursor()
                        cursor.execute(waypoint_insert, (rental_id, point_text, current_time, speed, wp_created, wp_updated))
                        self.connection.commit()
                        cursor.close()
                        waypoint_count += 1

                    # Step 3: Update rental status to COMPLETED (this will trigger your trigger)
                    final_updated_date = end_datetime + timedelta(minutes=random.randint(1, 60))
                    if final_updated_date > max_date:
                        final_updated_date = max_date

                    cursor = self.connection.cursor()
                    cursor.execute(rental_update_status, ('COMPLETED', final_updated_date, rental_id))
                    self.connection.commit()
                    cursor.close()

                # Step 3 (Alternative): Update to CANCELLED status if needed
                elif final_status == 'CANCELLED':
                    cancel_time = start_datetime + timedelta(minutes=random.randint(5, 60))
                    if cancel_time > max_date:
                        cancel_time = max_date

                    cursor = self.connection.cursor()
                    cursor.execute(rental_update_status, ('CANCELLED', cancel_time, rental_id))
                    self.connection.commit()
                    cursor.close()

                # If final_status is 'ACTIVE', we leave it as is (no update needed)

            except Exception as e:
                print(f"  ⚠ Skipped rental {i + 1}: {e}")
                continue

        print(f"✓ Generated {rental_count} rentals with {waypoint_count} waypoints")

    def generate_payments(self, count=400):
        """Generate payment records"""
        print(f"\n💳 Generating {count} payments...")

        customers = self.execute_query("SELECT id FROM customers", fetch=True)
        rentals = self.execute_query("SELECT id, start_datetime, end_datetime FROM rentals", fetch=True)
        subscriptions = self.execute_query("SELECT id, start_date FROM subscriptions", fetch=True)

        insert_query = """
            INSERT INTO payments 
            (customer_id, rental_id, subscription_id, amount, currency, payment_method, status, transaction_reference, created_date, updated_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        statuses = ['PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED']
        status_distribution = ['COMPLETED'] * 75 + ['PENDING'] * 10 + ['PROCESSING'] * 10 + ['FAILED'] * 3 + [
            'REFUNDED'] * 2
        payment_methods = ['CARD', 'BANK_TRANSFER']

        for i in range(count):
            customer_id = random.choice(customers)[0]
            payment_method = random.choice(payment_methods)
            status = random.choice(status_distribution)
            amount = Decimal(str(random.uniform(5, 300)))
            transaction_ref = f"TXN{random.randint(10000000, 99999999)}"

            # 70% rental payments, 30% subscription payments
            if random.random() < 0.7 and rentals:
                rental_data = random.choice(rentals)
                rental_id = rental_data[0]
                rental_start = rental_data[1]
                rental_end = rental_data[2] if rental_data[2] else datetime.now()
                subscription_id = None

                # Payment created after rental start
                created_date = rental_start + timedelta(minutes=random.randint(10, 120))
                if created_date < datetime(2025, 1, 1):
                    created_date = datetime(2025, 1, 1)
            else:
                rental_id = None
                if subscriptions:
                    sub_data = random.choice(subscriptions)
                    subscription_id = sub_data[0]
                    sub_start = datetime.combine(sub_data[1], datetime.min.time())

                    # Payment created around subscription start
                    created_date = sub_start - timedelta(days=random.randint(0, 2))
                    if created_date < datetime(2025, 1, 1):
                        created_date = datetime(2025, 1, 1)
                else:
                    subscription_id = None
                    created_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 320))

            # updated_date depends on payment status
            if status == 'COMPLETED':
                updated_date = created_date + timedelta(minutes=random.randint(1, 30))
            elif status in ['PENDING', 'PROCESSING']:
                updated_date = created_date + timedelta(minutes=random.randint(0, 10))
            else:  # FAILED or REFUNDED
                updated_date = created_date + timedelta(minutes=random.randint(5, 120))

            max_date = datetime(2025, 11, 29, 23, 59, 59)
            if updated_date > max_date:
                updated_date = max_date

            try:
                self.execute_query(insert_query, (
                    customer_id, rental_id, subscription_id, amount, 'EUR',
                    payment_method, status, transaction_ref, created_date, updated_date
                ))
            except Exception as e:
                print(f"  ⚠ Skipped payment {i + 1}: {e}")
                continue

        print(f"✓ Generated {count} payments")

    def generate_maintenance(self, count=120):
        """Generate maintenance records"""
        print(f"\n🔧 Generating {count} maintenance records...")

        vehicles = self.execute_query("SELECT id, last_odometer_km FROM vehicles", fetch=True)

        insert_query = """
            INSERT INTO maintenance 
            (vehicle_id, scheduled_date, scheduled_mileage_km, maintenance_type, description, performed_date, mileage_at_maintenance, cost, status, created_date, updated_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        maintenance_types = ['REGULAR', 'REPAIR', 'EMERGENCY']
        statuses = ['SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED']
        descriptions = [
            'Oil change and filter replacement',
            'Tire rotation and balance',
            'Brake inspection and adjustment',
            'Battery charging and diagnostics',
            'Windshield repair',
            'Engine diagnostics',
            'Chain lubrication and adjustment',
            'Suspension check',
            'Electrical system inspection',
            'Scooter wheel replacement'
        ]

        for i in range(count):
            vehicle_id, odometer = random.choice(vehicles)
            maintenance_type = random.choice(maintenance_types)
            status = random.choice(statuses)

            # Scheduled date in 2025
            scheduled_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 330))
            cost = Decimal(str(random.uniform(20, 300)))
            description = random.choice(descriptions)

            performed_date = None
            mileage_at_maintenance = None

            if status in ['COMPLETED', 'IN_PROGRESS']:
                performed_date = scheduled_date + timedelta(days=random.randint(0, 5))
                mileage_at_maintenance = Decimal(str(float(odometer) + random.uniform(0, 500)))

            # created_date should be before scheduled_date
            created_date = scheduled_date - timedelta(days=random.randint(1, 30))
            if created_date < datetime(2025, 1, 1):
                created_date = datetime(2025, 1, 1)

            # updated_date logic depends on status
            if status == 'COMPLETED' and performed_date:
                updated_date = datetime.combine(performed_date, datetime.min.time()) + timedelta(hours=random.randint(1, 12))
            elif status == 'IN_PROGRESS':
                updated_date = datetime.combine(scheduled_date, datetime.min.time()) + timedelta(hours=random.randint(1, 24))
            else:
                updated_date = created_date + timedelta(days=random.randint(0, 10), hours=random.randint(0, 23))

            max_date = datetime(2025, 11, 29, 23, 59, 59)
            if updated_date > max_date:
                updated_date = max_date

            try:
                self.execute_query(insert_query, (
                    vehicle_id, scheduled_date.date(),
                    Decimal(str(float(odometer) + random.uniform(100, 500))),
                    maintenance_type, description, performed_date, mileage_at_maintenance, cost, status,
                    created_date, updated_date
                ))
            except Exception as e:
                print(f"  ⚠ Skipped maintenance {i + 1}: {e}")
                continue

        print(f"✓ Generated {count} maintenance records")

    def generate_all(self, customer_count=150, vehicle_count=80):
        """Generate all data"""
        try:
            self.connect()

            print("\n" + "=" * 60)
            print("🚀 RENTAL SERVICE DATA GENERATOR")
            print("=" * 60)

            self.generate_subscription_plans()
            self.generate_customers(customer_count)
            self.generate_vehicles(vehicle_count)
            self.generate_subscriptions(int(customer_count * 0.9))
            self.generate_documents()
            self.generate_rentals(int(vehicle_count * 4))
            # todo: see if payments can be made better because now they are totally random and it would be better to generate payments correctly for rentals and subscriptions
            self.generate_payments(int(vehicle_count * 5))
            self.generate_maintenance(int(vehicle_count * 1.5))

            print("\n" + "=" * 60)
            print("✅ DATA GENERATION COMPLETED SUCCESSFULLY")
            print("=" * 60)

            # Print statistics
            self.print_statistics()

        except Exception as e:
            print(f"\n✗ Generation failed: {e}")
            raise
        finally:
            self.disconnect()

    def print_statistics(self):
        """Print data statistics"""
        print("\n📊 GENERATED DATA STATISTICS:")
        print("-" * 60)

        stats_queries = [
            ("Customers", "SELECT COUNT(*) FROM customers"),
            ("Active Customers", "SELECT COUNT(*) FROM customers WHERE status = 'ACTIVE'"),
            ("Subscription Plans", "SELECT COUNT(*) FROM subscription_plans"),
            ("Active Subscriptions", "SELECT COUNT(*) FROM subscriptions WHERE status = 'ACTIVE'"),
            ("Vehicles", "SELECT COUNT(*) FROM vehicles"),
            ("Available Vehicles", "SELECT COUNT(*) FROM vehicles WHERE status = 'AVAILABLE'"),
            ("Rentals", "SELECT COUNT(*) FROM rentals"),
            ("Completed Rentals", "SELECT COUNT(*) FROM rentals WHERE status = 'COMPLETED'"),
            ("Rental Waypoints", "SELECT COUNT(*) FROM rental_waypoints"),
            ("Documents", "SELECT COUNT(*) FROM documents"),
            ("Maintenance Records", "SELECT COUNT(*) FROM maintenance"),
            ("Payments", "SELECT COUNT(*) FROM payments"),
            ("Completed Payments", "SELECT COUNT(*) FROM payments WHERE status = 'COMPLETED'"),
        ]

        for label, query in stats_queries:
            result = self.execute_query(query, fetch=True)
            count = result[0][0] if result else 0
            print(f"  {label:<25} : {count:>8,}")

        # Total payment amount
        result = self.execute_query("SELECT SUM(amount) FROM payments WHERE status = 'COMPLETED'", fetch=True)
        total = result[0][0] if result and result[0][0] else 0
        print(f"  {'Total Payments':<25} : €{total:>7,.2f}")

        print("-" * 60)


if __name__ == "__main__":
    generator = RentalServiceDataGenerator(DB_CONFIG)

    # Change counts for generation of different data size
    generator.generate_all(customer_count=3000, vehicle_count=200)

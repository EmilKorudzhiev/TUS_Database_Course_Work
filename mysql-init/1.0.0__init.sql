DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS maintenance;
DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS rental_waypoints;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS documents;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS subscription_plans;
DROP TABLE IF EXISTS customers;

CREATE DATABASE IF NOT EXISTS rental_service DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rental_service;

CREATE TABLE customers
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    created_date  TIMESTAMP                                                  DEFAULT CURRENT_TIMESTAMP,
    updated_date  TIMESTAMP                                                  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    first_name    VARCHAR(50)                                       NOT NULL,
    last_name     VARCHAR(50)                                       NOT NULL,
    gender        ENUM ('MALE', 'FEMALE', 'OTHER')                  NOT NULL,
    email         VARCHAR(150)                                      NOT NULL UNIQUE,
    phone         VARCHAR(15)                                       NOT NULL UNIQUE,
    date_of_birth DATE                                              NOT NULL,
    status        ENUM ('ACTIVE', 'PENDING', 'SUSPENDED', 'CLOSED') NOT NULL DEFAULT 'PENDING',

    CONSTRAINT constraint_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT constraint_phone_format CHECK (phone REGEXP '^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
);

CREATE TABLE subscription_plans
(
    id             INT AUTO_INCREMENT PRIMARY KEY,
    created_date   TIMESTAMP                                     DEFAULT CURRENT_TIMESTAMP,
    updated_date   TIMESTAMP                                     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    name           VARCHAR(100)                         NOT NULL UNIQUE,
    description    TEXT                                 NOT NULL,
    plan_type      ENUM ('BASIC', 'VIP')                NOT NULL,
    billing_period ENUM ('WEEKLY', 'MONTHLY', 'YEARLY') NOT NULL,
    price          DECIMAL(10, 2)                       NOT NULL,
    currency       VARCHAR(3)                           NOT NULL DEFAULT 'EUR',

    CONSTRAINT constraint_price_positive CHECK (price > 0)
);

CREATE TABLE subscriptions
(
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    created_date         TIMESTAMP                                       DEFAULT CURRENT_TIMESTAMP,
    updated_date         TIMESTAMP                                       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    customer_id          INT                                    NOT NULL,
    subscription_plan_id INT                                    NOT NULL,
    start_date           DATE                                   NOT NULL,
    end_date             DATE,
    status               ENUM ('ACTIVE', 'PAUSED', 'CANCELLED') NOT NULL DEFAULT 'ACTIVE',
    auto_renewal         BOOLEAN                                NOT NULL DEFAULT TRUE,

    FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (subscription_plan_id) REFERENCES subscription_plans (id) ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT constraint_subscription_end_after_start CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE vehicles
(
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    created_date        TIMESTAMP                                                                 DEFAULT CURRENT_TIMESTAMP,
    updated_date        TIMESTAMP                                                                 DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    identifier          VARCHAR(50)                                                      NOT NULL UNIQUE,
    registration_number VARCHAR(20)                                                      NOT NULL UNIQUE,
    brand               VARCHAR(50)                                                      NOT NULL,
    model               VARCHAR(50)                                                      NOT NULL,
    power_type          ENUM ('ELECTRIC', 'DIESEL', 'PETROL', 'HYBRID', 'HUMAN_POWERED') NOT NULL,
    vehicle_type        ENUM ('BICYCLE', 'SCOOTER',
        'MICROCAR', 'SUPERMINIS', 'SUV', 'VAN')                                          NOT NULL,
    status              ENUM ('AVAILABLE', 'RENTED', 'MAINTENANCE', 'INACTIVE')          NOT NULL DEFAULT 'AVAILABLE',
    last_odometer_km    DECIMAL(10, 2)                                                   NOT NULL DEFAULT 0,
    location            VARCHAR(100)                                                     NOT NULL,
    price_per_minute    DECIMAL(10, 2),
    price_per_km        DECIMAL(10, 2),

    CONSTRAINT constraint_odometer_nonnegative CHECK (last_odometer_km >= 0),
    CONSTRAINT constraint_human_powered_type CHECK (NOT (power_type = 'HUMAN_POWERED' AND vehicle_type != 'BICYCLE')),
    CONSTRAINT constraint_scooter_type CHECK (NOT (vehicle_type = 'SCOOTER' AND power_type != 'ELECTRIC')),
    CONSTRAINT constraint_automobile_type CHECK (NOT (vehicle_type IN ('MICROCAR', 'SUPERMINIS', 'SUV', 'VAN') AND
                                                      power_type = 'HUMAN_POWERED')),
    CONSTRAINT constraint_price_per CHECK (price_per_minute IS NOT NULL OR price_per_km IS NOT NULL)
);

CREATE TABLE maintenance
(
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    created_date           TIMESTAMP                                        DEFAULT CURRENT_TIMESTAMP,
    updated_date           TIMESTAMP                                        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    vehicle_id             INT                                     NOT NULL,
    scheduled_date         DATE                                    NOT NULL,
    scheduled_mileage_km   DECIMAL(10, 2),
    maintenance_type       ENUM ('REGULAR', 'REPAIR', 'EMERGENCY') NOT NULL,
    description            TEXT,
    performed_date         DATE,
    mileage_at_maintenance DECIMAL(10, 2),
    cost                   DECIMAL(10, 2)                          NOT NULL,
    status                 ENUM ('SCHEDULED', 'IN_PROGRESS',
        'COMPLETED', 'CANCELLED')                                  NOT NULL DEFAULT 'SCHEDULED',

    FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT constraint_mileage_nonnegative CHECK (scheduled_mileage_km IS NULL OR scheduled_mileage_km >= 0),
    CONSTRAINT constraint_cost_positive CHECK (cost > 0),
    CONSTRAINT constraint_performed_after_scheduled CHECK (performed_date IS NULL OR performed_date >= scheduled_date)
);

CREATE TABLE documents
(
    id              INT AUTO_INCREMENT PRIMARY KEY,
    created_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    customer_id     INT,
    vehicle_id      INT,
    document_number VARCHAR(20)                                                                  NOT NULL,
    document_type   ENUM ('ID_CARD', 'PASSPORT', 'DRIVERS_LICENSE', 'INSURANCE', 'REGISTRATION') NOT NULL,
    issue_date      DATE                                                                         NOT NULL,
    expiry_date     DATE                                                                         NOT NULL,
    file_url        VARCHAR(255),

    UNIQUE KEY uk_customer_doctype (customer_id, document_type),

    FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles (id),

    CONSTRAINT constraint_expiry_after_issue CHECK (expiry_date >= issue_date),
    CONSTRAINT constraint_reference_customer_or_vehicle CHECK (
        (customer_id IS NOT NULL AND vehicle_id IS NULL) OR
        (customer_id IS NULL AND vehicle_id IS NOT NULL)
        ),
    CONSTRAINT constraint_customer_documents CHECK ((document_type IN ('ID_CARD', 'PASSPORT', 'DRIVERS_LICENSE') AND
                                                     customer_id IS NOT NULL AND vehicle_id IS NULL)),
    CONSTRAINT constraint_vehicle_documents CHECK ( (document_type IN ('INSURANCE', 'REGISTRATION') AND
                                                     vehicle_id IS NOT NULL AND customer_id IS NULL))
);

CREATE TABLE rentals
(
    id             INT AUTO_INCREMENT PRIMARY KEY,
    created_date   TIMESTAMP                                          DEFAULT CURRENT_TIMESTAMP,
    updated_date   TIMESTAMP                                          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    customer_id    INT                                       NOT NULL,
    vehicle_id     INT                                       NOT NULL,
    start_datetime TIMESTAMP                                 NOT NULL,
    end_datetime   TIMESTAMP,
    price          DECIMAL(10, 2),
    currency       VARCHAR(3)                                NOT NULL DEFAULT 'EUR',
    status         ENUM ('ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'ACTIVE',
    distance_km    DECIMAL(10, 2),
    trajectory     LINESTRING SRID 4326,

    FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE rental_waypoints
(
    id           INT AUTO_INCREMENT PRIMARY KEY,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    rental_id    INT      NOT NULL,
    location     POINT    NOT NULL SRID 4326,
    timestamp    DATETIME NOT NULL,
    speed        FLOAT,

    FOREIGN KEY (rental_id) REFERENCES rentals (id) ON DELETE CASCADE
);

CREATE TABLE payments
(
    id                    INT AUTO_INCREMENT PRIMARY KEY,
    created_date          TIMESTAMP                               DEFAULT CURRENT_TIMESTAMP,
    updated_date          TIMESTAMP                               DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    customer_id           INT                            NOT NULL,
    rental_id             INT,
    subscription_id       INT,
    amount                DECIMAL(10, 2)                 NOT NULL,
    currency              VARCHAR(3)                     NOT NULL DEFAULT 'EUR',
    payment_method        ENUM ('CARD', 'BANK_TRANSFER') NOT NULL,
    status                ENUM ('PENDING', 'PROCESSING',
        'COMPLETED', 'FAILED', 'REFUNDED')               NOT NULL DEFAULT 'PENDING',
    transaction_reference VARCHAR(32) UNIQUE,

    FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (rental_id) REFERENCES rentals (id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions (id) ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT constraint_amount_positive CHECK (amount > 0),
    CONSTRAINT constraint_reference_trip_or_subscription CHECK (
        (rental_id IS NOT NULL AND subscription_id IS NULL) OR
        (rental_id IS NULL AND subscription_id IS NOT NULL)
        )
);
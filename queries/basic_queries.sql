-- 1. Търсене на най-близли налични превозни средства по тип и дадена мерна единица за разтояние
explain analyze SELECT v.identifier,
       v.brand,
       v.model,
       v.vehicle_type,
       v.power_type,
       v.price_per_minute,
       v.price_per_km,
       v.price_for_rental,
       v.location,
       ROUND(ST_DISTANCE(ST_GeomFromText('POINT(23.28009015708178 42.652249987433666)', 4326), v.location,
                         'metre'), 0) as distance_from_location
FROM rental_service.vehicles v
WHERE v.vehicle_type = 'BICYCLE'
  AND v.status = 'AVAILABLE'
ORDER BY distance_from_location
    LIMIT 20;

-- 2. Намиране на активен наем за клиент
SELECT r.id                                           as rental_id,
       v.identifier,
       v.brand,
       v.model,
       r.start_datetime,
       TIMESTAMPDIFF(MINUTE, r.start_datetime, NOW()) as rental_minutes,
       ST_AsText(v.location)                          as current_location
FROM rental_service.rentals r
         JOIN rental_service.vehicles v ON r.vehicle_id = v.id
WHERE r.customer_id = 12
  AND r.status = 'ACTIVE'
ORDER BY r.start_datetime DESC
    LIMIT 20;

-- 3. Проверка на активен абонамент за даден клиент
SELECT c.first_name,
       c.last_name,
       sp.name as plan_name,
       sp.plan_type,
       s.start_date,
       s.end_date,
       s.auto_renewal
FROM rental_service.customers c
         JOIN rental_service.subscriptions s ON c.id = s.customer_id
         JOIN rental_service.subscription_plans sp ON s.subscription_plan_id = sp.id
WHERE c.id = 4005
  AND s.status = 'ACTIVE'
  AND CURDATE() BETWEEN s.start_date AND COALESCE(s.end_date, CURDATE())
    LIMIT 20;

-- 4. Намиране на превозни средства за поддръжка
SELECT v.identifier,
       v.registration_number,
       v.brand,
       v.model,
       v.last_odometer_km,
       m.scheduled_date,
       m.scheduled_mileage_km,
       m.maintenance_type,
       m.description
FROM rental_service.vehicles v
         JOIN rental_service.maintenance m ON v.id = m.vehicle_id
WHERE m.status = 'SCHEDULED'
  AND (m.scheduled_date <= CURDATE()
    OR m.scheduled_mileage_km <= v.last_odometer_km)
ORDER BY m.scheduled_date ASC
    LIMIT 20;

-- 5. Клиентска история на наети превозни средства
explain analyze SELECT r.id as rental_id,
       v.brand,
       v.model,
       v.vehicle_type,
       r.start_datetime,
       r.end_datetime,
       r.distance_km,
       r.price,
       r.status
FROM rental_service.rentals r
         JOIN rental_service.vehicles v ON r.vehicle_id = v.id
WHERE r.customer_id = 1
ORDER BY r.start_datetime DESC
    LIMIT 20;

-- 6. Проверка на документи на клиент
SELECT c.first_name,
       c.last_name,
       d.document_type,
       d.document_number,
       d.issue_date,
       d.expiry_date,
       CASE
           WHEN d.expiry_date < CURDATE() THEN 'EXPIRED'
           WHEN d.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'EXPIRING_SOON'
           ELSE 'VALID'
           END as status
FROM rental_service.customers c
         JOIN rental_service.documents d ON c.id = d.customer_id
WHERE c.id = 6119
  AND d.document_type IN ('DRIVERS_LICENSE', 'ID_CARD')
ORDER BY d.expiry_date ASC;

-- 7.Проверка на документи на преозно средство
SELECT v.id,
       v.registration_number,
       v.brand,
       v.model,
       d.document_type,
       d.document_number,
       d.issue_date,
       d.expiry_date,
       CASE
           WHEN d.expiry_date < CURDATE() THEN 'EXPIRED'
           WHEN d.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'EXPIRING_SOON'
           ELSE 'VALID'
           END as status
FROM rental_service.vehicles v
         JOIN rental_service.documents d ON v.id = d.vehicle_id
WHERE d.document_type IN ('INSURANCE', 'REGISTRATION')
ORDER BY d.expiry_date ASC;

-- 8. Инициализиране на rental
INSERT INTO rental_service.rentals (
    customer_id,
    vehicle_id,
    start_datetime,
    status,
    currency
) VALUES (
    123,
    456,
    NOW(),
    'ACTIVE',
    'EUR'
);
-- Актуализиране на статус на превозно средство
UPDATE rental_service.vehicles
SET status = 'RENTED'
WHERE id = 456;

-- 9. Завършване на рентал и калкулиране на крайна цена.
UPDATE rental_service.rentals
SET
    end_datetime = NOW(),
    status = 'COMPLETED',
    distance_km = 15.5,
    price = (
        TIMESTAMPDIFF(MINUTE, start_datetime, NOW()) *
        (SELECT price_per_minute FROM rental_service.vehicles WHERE id = 456) +
        15.5 * (SELECT price_per_km FROM rental_service.vehicles WHERE id = 456)
    )
WHERE id = 789 AND status = 'ACTIVE';
-- Актуализация на състоянието и локацията на превозното средство
UPDATE rental_service.vehicles
SET
    status = 'AVAILABLE',
    last_odometer_km = last_odometer_km + 15.5,
    location = ST_GeomFromText('POINT(12.34 56.78)', 4326)
WHERE id = 456;

-- 10. Обработка на плащане на наем
INSERT INTO rental_service.payments (
    customer_id,
    rental_id,
    amount,
    currency,
    payment_method,
    status,
    transaction_reference
) VALUES (
    123,
    789,
    (SELECT price FROM rental_service.rentals WHERE id = 789),
    'EUR',
    'CARD',
    'COMPLETED',
    UUID()
);

-- 11. Актуализиране на локация на п.с. по време на наем
INSERT INTO rental_service.rental_waypoints (
    rental_id,
    location,
    timestamp,
    speed
) VALUES (
    71,
    ST_GeomFromText('POINT(12.345 56.789)', 4326),
    NOW(),
    25.5
);
-- Актуализиране на сегашната локация на п.с.
UPDATE rental_service.vehicles
SET location = ST_GeomFromText('POINT(12.345 56.789)', 4326)
WHERE id = 456;

-- 12. Извличане на маршрутни точки за даден наем
SELECT rental_waypoints.location
FROM rental_service.rental_waypoints
WHERE rental_waypoints.rental_id = 2;

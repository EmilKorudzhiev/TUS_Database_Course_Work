-- TODO look at queries and figure out which are useful and add some more

-- 1. Търсене на налични превозни средства по местоположение и тип.
 SELECT 
    v.identifier,
    v.brand,
    v.model,
    v.vehicle_type,
    v.power_type,
    v.price_per_minute,
    v.price_per_km,
    v.price_for_rental,
    ST_AsText(v.location) as coordinates
FROM rental_service.vehicles v
WHERE v.status = 'AVAILABLE'
    AND v.location = ST_GeomFromText('POINT(12.34 56.78)', 4326)
    AND v.vehicle_type = 'BICYCLE'
ORDER BY v.created_date DESC;


-- 2. Инициализиране на rental
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


-- 3. Завършване на рентал и калкулиране на крайна цена.
UPDATE rental_service.rentals 
SET 
    end_datetime = NOW(),
    status = 'COMPLETED',
    distance_km = 15.5,
    price = (
        -- Calculate price based on time and distance
        TIMESTAMPDIFF(MINUTE, start_datetime, NOW()) * 
        (SELECT price_per_minute FROM vehicles WHERE id = 456) +
        15.5 * (SELECT price_per_km FROM vehicles WHERE id = 456)
    )
WHERE id = 789 AND status = 'ACTIVE';

-- Актуализация на състоянието и локацията на превозното средство
UPDATE rental_service.vehicles
SET 
    status = 'AVAILABLE',
    last_odometer_km = last_odometer_km + 15.5,
    location = ST_GeomFromText('POINT(12.34 56.78)', 4326)
WHERE id = 456;


-- 4. Намиране на активен наем за клиент
SELECT 
    r.id as rental_id,
    v.identifier,
    v.brand,
    v.model,
    r.start_datetime,
    TIMESTAMPDIFF(MINUTE, r.start_datetime, NOW()) as rental_minutes,
    ST_AsText(v.location) as current_location
FROM rental_service.rentals r
JOIN rental_service.vehicles v ON r.vehicle_id = v.id
WHERE r.customer_id = 2
    AND r.status = 'ACTIVE'
ORDER BY r.start_datetime DESC;


-- 5. Обработка на плащане на наем
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


-- 6. Проверка на активен абонамент за даден клиент 
SELECT 
    c.first_name,
    c.last_name,
    sp.name as plan_name,
    sp.plan_type,
    s.start_date,
    s.end_date,
    s.auto_renewal
FROM rental_service.customers c
JOIN rental_service.subscriptions s ON c.id = s.customer_id
JOIN rental_service.subscription_plans sp ON s.subscription_plan_id = sp.id
WHERE c.id = 4
    AND s.status = 'ACTIVE'
    AND CURDATE() BETWEEN s.start_date AND COALESCE(s.end_date, CURDATE());
    
    
    -- 7. Намиране на превозни средства за поддръжка
    SELECT 
    v.identifier,
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
ORDER BY m.scheduled_date ASC;


-- 8. Customer rental history 
SELECT 
    r.id as rental_id,
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
WHERE r.customer_id = 21
ORDER BY r.start_datetime DESC
LIMIT 20;


-- 9. Актуализиране на локация на п.с. по време на наем
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

-- 10. Проверка на документи на клиент
SELECT 
    c.first_name,
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
WHERE c.id = 21
    AND d.document_type IN ('DRIVERS_LICENSE', 'ID_CARD')
ORDER BY d.expiry_date ASC;


SELECT group_concat(ST_AsText(rental_waypoints.location)) as locations
FROM rental_service.rental_waypoints;


SELECT rental_waypoints.location as locations
FROM rental_service.rental_waypoints;




# //concat has a limit so trajectory is a bad idea for mysql, if it was postgresql there would be an easier solution, so we have to do stuff with joins here

-- 11. create linestring from waypoints
SELECT ST_GeomFromText(
               CONCAT(
                       'LINESTRING(',
                       GROUP_CONCAT(
                               CONCAT(ST_X(location), ' ', ST_Y(location))
                               ORDER BY id
                               SEPARATOR ','
                       ),
                       ')'
               ), 4236
       ) AS line
FROM rental_service.rental_waypoints
WHERE rental_id = 2;

SELECT ST_GeomFromText(
            'LINESTRING (23.293371610597003 42.66498072118308, 23.333817654884587 42.65116494437315, 23.319803092996015 42.73597785741589, 23.360365251622497 42.66764578066665, 23.370840361576153 42.72718462443019, 23.306303411978988 42.725843510583545, 23.303787756732937 42.66568158736978, 23.371053132343057 42.65355912302781, 23.281913433730494 42.74509798617335, 23.366680247821964 42.72410497237175, 23.35582222523059 42.683180463456516, 23.341662656359958 42.72832102253594, 23.32826064867832 42.742455873507, 23.289455676766064 42.701912460152094, 23.31969889881662 42.64969279898885, 23.28964598726539 42.68177590442667, 23.33056091750912 42.64989128962436, 23.367955875027576 42.73376694665915)'
           , 4236);;


SELECT ST_X(POINT(10, 20));



DROP TRIGGER IF EXISTS rental_service.rental_trajectory_update;
DELIMITER //
CREATE TRIGGER rental_trajectory_update
    AFTER UPDATE
    ON rental_service.rentals
    FOR EACH ROW
BEGIN
    IF NEW.status = 'COMPLETE' AND (OLD.status IS NULL OR OLD.status != 'COMPLETE')
    THEN
        UPDATE rental_service.rentals AS r
        SET r.trajectory = (SELECT ST_GeomFromText(
                                           CONCAT(
                                                   'LINESTRING(',
                                                   GROUP_CONCAT(
                                                           CONCAT(ST_X(location), ' ', ST_Y(location))
                                                           ORDER BY id
                                                           SEPARATOR ','
                                                   ),
                                                   ')'
                                           ), 4236
                                   )
                            FROM rental_service.rental_waypoints
                            WHERE rental_id = NEW.id)
        WHERE r.id = NEW.id;
        UPDATE rental_service.vehicles AS v
        SET v.status   = 'AVAILABLE',
            v.location = (SELECT location
                          FROM rental_service.rental_waypoints
                          WHERE rental_id = NEW.id
                          ORDER BY timestamp DESC
                          LIMIT 1)
        WHERE v.id = NEW.vehicle_id;
    END IF;
END;
//
DELIMITER ;


UPDATE rental_service.rentals AS r
SET r.trajectory = (SELECT ST_GeomFromText(
                                   CONCAT(
                                           'LINESTRING(',
                                           GROUP_CONCAT(
                                                   CONCAT(ST_X(location), ' ', ST_Y(location))
                                                   ORDER BY id
                                                   SEPARATOR ','
                                           ),
                                           ')'
                                   ), 4236
                           )
                    FROM rental_service.rental_waypoints
                    WHERE rental_id = 1)
WHERE r.id = 2;

SELECT GROUP_CONCAT(
               CONCAT(ST_X(location), ' ', ST_Y(location))
               ORDER BY id
               SEPARATOR ','
       )FROM rental_service.rental_waypoints
WHERE rental_id = 1;














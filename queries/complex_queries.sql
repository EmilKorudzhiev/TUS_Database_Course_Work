SELECT
    v.id                                   AS vehicle_id,
    v.identifier,
    v.registration_number,
    v.brand,
    v.model,
    v.status                               AS current_status,
    ST_AsText(v.location)                  AS vehicle_location,

    r.id                                   AS last_rental_id,
    r.start_datetime                       AS rental_start,
    r.end_datetime                         AS rental_end,
    r.status                               AS rental_status,
    r.distance_km,

    c.id                                   AS customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.phone,
    c.status                               AS customer_status,

    m.id                                   AS maintenance_id,
    m.scheduled_date,
    m.performed_date,
    m.maintenance_type,
    m.description                          AS maintenance_description,
    m.status                               AS maintenance_status,
    m.cost                                 AS maintenance_cost,

    (SELECT COUNT(*)
     FROM rental_waypoints rw
     WHERE rw.rental_id = r.id)            AS total_waypoints_recorded,

    (SELECT MAX(rw2.speed)
     FROM rental_waypoints rw2
     WHERE rw2.rental_id = r.id)           AS max_speed_kmh,

    (SELECT AVG(rw2.speed)
     FROM rental_waypoints rw2
     WHERE rw2.rental_id = r.id)           AS avg_speed_kmh,

    (SELECT COUNT(*)
     FROM rental_waypoints rw2
     WHERE rw2.rental_id = r.id
       AND rw2.speed > 80)                 AS high_speed_incidents,

    (SELECT MAX(rw2.timestamp)
     FROM rental_waypoints rw2
     WHERE rw2.rental_id = r.id)           AS last_waypoint_time,

    CASE
        WHEN EXISTS (SELECT 1
                     FROM documents d
                     WHERE d.customer_id = c.id
                       AND d.document_type = 'DRIVERS_LICENSE'
                       AND d.expiry_date < CURDATE()) THEN 'EXPIRED_LICENSE'
        WHEN NOT EXISTS (SELECT 1
                         FROM documents d
                         WHERE d.customer_id = c.id
                           AND d.document_type = 'DRIVERS_LICENSE') THEN 'NO_LICENSE'
        ELSE 'LICENSE_VALID'
        END                                AS driver_license_status

FROM vehicles v

         LEFT JOIN rentals r ON r.vehicle_id = v.id
    AND r.id = (SELECT r2.id
                FROM rentals r2
                WHERE r2.vehicle_id = v.id
                ORDER BY r2.start_datetime DESC
                LIMIT 1)

         LEFT JOIN customers c ON r.customer_id = c.id

         LEFT JOIN maintenance m ON m.vehicle_id = v.id
    AND m.performed_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    AND m.id = (SELECT m2.id
                FROM maintenance m2
                WHERE m2.vehicle_id = v.id
                ORDER BY m2.performed_date DESC
                LIMIT 1)
WHERE v.id = 1;

-- статистика приходи и разходи дневна база
SELECT date_range.date,

       COALESCE(rental_income.total_rental_income, 0)               AS rental_income,
       COALESCE(rental_income.rental_count, 0)                      AS rental_count,

       COALESCE(subscription_income.total_subscription_income, 0)   AS subscription_income,
       COALESCE(subscription_income.subscription_count, 0)          AS subscription_count,

       (COALESCE(rental_income.total_rental_income, 0) +
        COALESCE(subscription_income.total_subscription_income, 0)) AS total_income,

       COALESCE(maintenance_expenses.total_maintenance_cost, 0)     AS maintenance_expenses,
       COALESCE(maintenance_expenses.maintenance_count, 0)          AS maintenance_count,

       COALESCE(refund_expenses.total_refunds, 0)                   AS refund_expenses,
       COALESCE(refund_expenses.refund_count, 0)                    AS refund_count,

       (COALESCE(maintenance_expenses.total_maintenance_cost, 0) +
        COALESCE(refund_expenses.total_refunds, 0))                 AS total_expenses,

       ((COALESCE(rental_income.total_rental_income, 0) +
         COALESCE(subscription_income.total_subscription_income, 0)) -
        (COALESCE(maintenance_expenses.total_maintenance_cost, 0) +
         COALESCE(refund_expenses.total_refunds, 0)))               AS daily_profit,

       CASE
           WHEN (COALESCE(rental_income.total_rental_income, 0) +
                 COALESCE(subscription_income.total_subscription_income, 0)) > 0
               THEN ROUND((((COALESCE(rental_income.total_rental_income, 0) +
                             COALESCE(subscription_income.total_subscription_income, 0)) -
                            (COALESCE(maintenance_expenses.total_maintenance_cost, 0) +
                             COALESCE(refund_expenses.total_refunds, 0))) /
                           (COALESCE(rental_income.total_rental_income, 0) +
                            COALESCE(subscription_income.total_subscription_income, 0))) * 100, 2)
           ELSE 0
           END                                                      AS profit_margin_percent,

       SUM((COALESCE(rental_income.total_rental_income, 0) +
            COALESCE(subscription_income.total_subscription_income, 0)))
           OVER (ORDER BY date_range.date)                          AS cumulative_income,

       SUM(((COALESCE(rental_income.total_rental_income, 0) +
             COALESCE(subscription_income.total_subscription_income, 0)) -
            (COALESCE(maintenance_expenses.total_maintenance_cost, 0) +
             COALESCE(refund_expenses.total_refunds, 0))))
           OVER (ORDER BY date_range.date)                          AS cumulative_profit
FROM (
         -- Generate date range based on parameters
         SELECT date_add(@start_date, INTERVAL seq.seq DAY) AS date
         FROM (SELECT ones.N + tens.N * 10 + hundreds.N * 100 AS seq
               FROM (SELECT 0 AS N
                     UNION ALL
                     SELECT 1
                     UNION ALL
                     SELECT 2
                     UNION ALL
                     SELECT 3
                     UNION ALL
                     SELECT 4
                     UNION ALL
                     SELECT 5
                     UNION ALL
                     SELECT 6
                     UNION ALL
                     SELECT 7
                     UNION ALL
                     SELECT 8
                     UNION ALL
                     SELECT 9) ones
                        CROSS JOIN (SELECT 0 AS N
                                    UNION ALL
                                    SELECT 1
                                    UNION ALL
                                    SELECT 2
                                    UNION ALL
                                    SELECT 3
                                    UNION ALL
                                    SELECT 4
                                    UNION ALL
                                    SELECT 5
                                    UNION ALL
                                    SELECT 6
                                    UNION ALL
                                    SELECT 7
                                    UNION ALL
                                    SELECT 8
                                    UNION ALL
                                    SELECT 9) tens
                        CROSS JOIN (SELECT 0 AS N
                                    UNION ALL
                                    SELECT 1
                                    UNION ALL
                                    SELECT 2
                                    UNION ALL
                                    SELECT 3
                                    UNION ALL
                                    SELECT 4
                                    UNION ALL
                                    SELECT 5
                                    UNION ALL
                                    SELECT 6
                                    UNION ALL
                                    SELECT 7
                                    UNION ALL
                                    SELECT 8
                                    UNION ALL
                                    SELECT 9) hundreds) seq
         WHERE date_add(@start_date, INTERVAL seq.seq DAY) <= @end_date) date_range

         LEFT JOIN (SELECT DATE(p.created_date) AS payment_date,
                           SUM(p.amount)        AS total_rental_income,
                           COUNT(*)             AS rental_count
                    FROM payments p
                    WHERE p.status = 'COMPLETED'
                      AND p.rental_id IS NOT NULL
                      AND p.subscription_id IS NULL
                      AND DATE(p.created_date) BETWEEN @start_date AND @end_date
                    GROUP BY DATE(p.created_date)) AS rental_income ON date_range.date = rental_income.payment_date

         LEFT JOIN (SELECT DATE(p.created_date) AS payment_date,
                           SUM(p.amount)        AS total_subscription_income,
                           COUNT(*)             AS subscription_count
                    FROM payments p
                    WHERE p.status = 'COMPLETED'
                      AND p.rental_id IS NULL
                      AND p.subscription_id IS NOT NULL
                      AND DATE(p.created_date) BETWEEN @start_date AND @end_date
                    GROUP BY DATE(p.created_date)) AS subscription_income
                   ON date_range.date = subscription_income.payment_date

         LEFT JOIN (SELECT DATE(performed_date) AS maintenance_date,
                           SUM(cost)            AS total_maintenance_cost,
                           COUNT(*)             AS maintenance_count
                    FROM maintenance
                    WHERE status = 'COMPLETED'
                      AND DATE(performed_date) BETWEEN @start_date AND @end_date
                    GROUP BY DATE(performed_date)) AS maintenance_expenses
                   ON date_range.date = maintenance_expenses.maintenance_date

         LEFT JOIN (SELECT DATE(created_date) AS refund_date,
                           SUM(amount)        AS total_refunds,
                           COUNT(*)           AS refund_count
                    FROM payments
                    WHERE status = 'REFUNDED'
                      AND DATE(created_date) BETWEEN @start_date AND @end_date
                    GROUP BY DATE(created_date)) AS refund_expenses ON date_range.date = refund_expenses.refund_date
ORDER BY date_range.date DESC;

-- Last 30 days
SET @start_date = CURDATE() - INTERVAL 30 DAY;
SET @end_date = CURDATE();

-- Last 7 days
SET @start_date = CURDATE() - INTERVAL 7 DAY;
SET @end_date = CURDATE();

-- Specific date range
SET @start_date = '2025-01-01';
SET @end_date = '2025-11-30';

-- Last 90 days
SET @start_date = CURDATE() - INTERVAL 90 DAY;
SET @end_date = CURDATE();

-- Year to date
SET @start_date = DATE_FORMAT(CURDATE(), '%Y-01-01');
SET @end_date = CURDATE();
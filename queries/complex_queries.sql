-- TODO look at queries and figure out which are useful and add some more

SELECT
    -- Vehicle Information
    v.id AS vehicle_id,
    v.identifier,
    v.registration_number,
    v.brand,
    v.model,
    v.status AS current_status,
    ST_AsText(v.location) AS current_location,

    -- Last Rental Information
    r.id AS last_rental_id,
    r.start_datetime AS rental_start,
    r.end_datetime AS rental_end,
    r.status AS rental_status,
    r.distance_km,

    -- Last Customer Details
    c.id AS customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.phone,
    c.status AS customer_status,

    -- Maintenance History (Recent)
    m.id AS maintenance_id,
    m.scheduled_date,
    m.performed_date,
    m.maintenance_type,
    m.description AS maintenance_description,
    m.status AS maintenance_status,
    m.cost AS maintenance_cost,

    -- Rental Waypoints Analysis
    (
        SELECT COUNT(*)
        FROM rental_waypoints rw
        WHERE rw.rental_id = r.id
    ) AS total_waypoints_recorded,

    -- Speed Analysis
    (
        SELECT MAX(rw2.speed)
        FROM rental_waypoints rw2
        WHERE rw2.rental_id = r.id
    ) AS max_speed_kmh,

    (
        SELECT AVG(rw2.speed)
        FROM rental_waypoints rw2
        WHERE rw2.rental_id = r.id
    ) AS avg_speed_kmh,

    -- Critical Speed Moments (speeds above 80 km/h)
    (
        SELECT COUNT(*)
        FROM rental_waypoints rw2
        WHERE rw2.rental_id = r.id AND rw2.speed > 80
    ) AS high_speed_incidents,

    -- Last known location from waypoints
    (
        SELECT ST_AsText(rw2.location)
        FROM rental_waypoints rw2
        WHERE rw2.rental_id = r.id
        ORDER BY rw2.timestamp DESC
        LIMIT 1
    ) AS last_known_location,

    -- Time of last recorded waypoint
    (
        SELECT MAX(rw2.timestamp)
        FROM rental_waypoints rw2
        WHERE rw2.rental_id = r.id
    ) AS last_waypoint_time,

    -- Vehicle's Maintenance Schedule Compliance
    CASE
        WHEN EXISTS (
            SELECT 1 FROM maintenance m2
            WHERE m2.vehicle_id = v.id
            AND m2.status = 'SCHEDULED'
            AND m2.scheduled_date < CURDATE()
        ) THEN 'OVERDUE_MAINTENANCE'
        WHEN EXISTS (
            SELECT 1 FROM maintenance m2
            WHERE m2.vehicle_id = v.id
            AND m2.scheduled_mileage_km IS NOT NULL
            AND m2.scheduled_mileage_km < v.last_odometer_km
            AND m2.status = 'SCHEDULED'
        ) THEN 'OVERDUE_MILEAGE_MAINTENANCE'
        ELSE 'MAINTENANCE_COMPLIANT'
END AS maintenance_compliance_status,

    -- Customer's Document Status
    CASE
        WHEN EXISTS (
            SELECT 1 FROM documents d
            WHERE d.customer_id = c.id
            AND d.document_type = 'DRIVERS_LICENSE'
            AND d.expiry_date < CURDATE()
        ) THEN 'EXPIRED_LICENSE'
        WHEN NOT EXISTS (
            SELECT 1 FROM documents d
            WHERE d.customer_id = c.id
            AND d.document_type = 'DRIVERS_LICENSE'
        ) THEN 'NO_LICENSE'
        ELSE 'LICENSE_VALID'
END AS driver_license_status

FROM vehicles v

-- Get the last rental for this vehicle
LEFT JOIN rentals r ON r.vehicle_id = v.id
    AND r.id = (
        SELECT r2.id
        FROM rentals r2
        WHERE r2.vehicle_id = v.id
        ORDER BY r2.start_datetime DESC
        LIMIT 1
    )

-- Get customer details from last rental
LEFT JOIN customers c ON r.customer_id = c.id

-- Get recent maintenance records (last 30 days)
LEFT JOIN maintenance m ON m.vehicle_id = v.id
    AND m.performed_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    AND m.id = (
        SELECT m2.id
        FROM maintenance m2
        WHERE m2.vehicle_id = v.id
        ORDER BY m2.performed_date DESC
        LIMIT 1
    )

-- Specify the vehicle you're investigating
WHERE v.id = 123  -- Replace with actual vehicle ID
   OR v.registration_number = 'ABC123'  -- Or search by registration number
   OR v.identifier = 'VEHICLE_001';     -- Or search by identifier


----


SELECT
    date_range.date,

    -- INCOME SECTIONS
    -- Rental Income
    COALESCE(rental_income.total_rental_income, 0) AS rental_income,

    -- Subscription Income
    COALESCE(subscription_income.total_subscription_income, 0) AS subscription_income,

    -- Other Income (fees, penalties, etc.)
    COALESCE(other_income.total_other_income, 0) AS other_income,

    -- TOTAL INCOME
    (COALESCE(rental_income.total_rental_income, 0) +
     COALESCE(subscription_income.total_subscription_income, 0) +
     COALESCE(other_income.total_other_income, 0)) AS total_income,

    -- EXPENSE SECTIONS
    -- Maintenance Expenses
    COALESCE(maintenance_expenses.total_maintenance_cost, 0) AS maintenance_expenses,

    -- Refund Expenses
    COALESCE(refund_expenses.total_refunds, 0) AS refund_expenses,

    -- TOTAL EXPENSES
    (COALESCE(maintenance_expenses.total_maintenance_cost, 0) +
     COALESCE(refund_expenses.total_refunds, 0)) AS total_expenses,

    -- PROFIT CALCULATION
    ((COALESCE(rental_income.total_rental_income, 0) +
      COALESCE(subscription_income.total_subscription_income, 0) +
      COALESCE(other_income.total_other_income, 0)) -
     (COALESCE(maintenance_expenses.total_maintenance_cost, 0) +
      COALESCE(refund_expenses.total_refunds, 0))) AS daily_profit,

    -- PROFIT MARGIN (%)
    CASE
        WHEN (COALESCE(rental_income.total_rental_income, 0) +
              COALESCE(subscription_income.total_subscription_income, 0) +
              COALESCE(other_income.total_other_income, 0)) > 0
            THEN ROUND((((COALESCE(rental_income.total_rental_income, 0) +
                          COALESCE(subscription_income.total_subscription_income, 0) +
                          COALESCE(other_income.total_other_income, 0)) -
                         (COALESCE(maintenance_expenses.total_maintenance_cost, 0) +
                          COALESCE(refund_expenses.total_refunds, 0))) /
                        (COALESCE(rental_income.total_rental_income, 0) +
                         COALESCE(subscription_income.total_subscription_income, 0) +
                         COALESCE(other_income.total_other_income, 0))) * 100, 2)
        ELSE 0
        END AS profit_margin_percent

FROM (
         -- Generate date range (last 30 days)
         SELECT CURDATE() - INTERVAL (a.a + (10 * b.a)) DAY AS date
         FROM
             (SELECT 0 AS a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
              SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS a
                 CROSS JOIN
             (SELECT 0 AS a UNION ALL SELECT 1 UNION ALL SELECT 2) AS b
         WHERE (a.a + (10 * b.a)) <= 29
         ORDER BY date DESC
     ) AS date_range

-- Rental Income (completed payments for rentals)
         LEFT JOIN (
    SELECT
        DATE(p.created_date) AS payment_date,
        SUM(p.amount) AS total_rental_income
    FROM payments p
    WHERE p.status = 'COMPLETED'
      AND p.rental_id IS NOT NULL
      AND p.created_date >= CURDATE() - INTERVAL 30 DAY
    GROUP BY DATE(p.created_date)
) AS rental_income ON date_range.date = rental_income.payment_date

-- Subscription Income
         LEFT JOIN (
    SELECT
        DATE(p.created_date) AS payment_date,
        SUM(p.amount) AS total_subscription_income
    FROM payments p
    WHERE p.status = 'COMPLETED'
      AND p.subscription_id IS NOT NULL
      AND p.created_date >= CURDATE() - INTERVAL 30 DAY
    GROUP BY DATE(p.created_date)
) AS subscription_income ON date_range.date = subscription_income.payment_date

-- Other Income (potential fees, penalties - you might need to adjust based on your business logic)
         LEFT JOIN (
    SELECT
        DATE(created_date) AS payment_date,
        SUM(amount) AS total_other_income
    FROM payments
    WHERE status = 'COMPLETED'
      AND rental_id IS NULL
      AND subscription_id IS NULL
      AND created_date >= CURDATE() - INTERVAL 30 DAY
    GROUP BY DATE(created_date)
) AS other_income ON date_range.date = other_income.payment_date

-- Maintenance Expenses
         LEFT JOIN (
    SELECT
        DATE(performed_date) AS maintenance_date,
        SUM(cost) AS total_maintenance_cost
    FROM maintenance
    WHERE status = 'COMPLETED'
      AND performed_date >= CURDATE() - INTERVAL 30 DAY
    GROUP BY DATE(performed_date)
) AS maintenance_expenses ON date_range.date = maintenance_expenses.maintenance_date

-- Refund Expenses
         LEFT JOIN (
    SELECT
        DATE(created_date) AS refund_date,
        SUM(amount) AS total_refunds
    FROM payments
    WHERE status = 'REFUNDED'
      AND created_date >= CURDATE() - INTERVAL 30 DAY
    GROUP BY DATE(created_date)
) AS refund_expenses ON date_range.date = refund_expenses.refund_date

ORDER BY date_range.date DESC;

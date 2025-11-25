ALTER TABLE rental_service.subscription_plans
    ADD COLUMN duration_days INT NOT NULL;

ALTER TABLE rental_service.vehicles
    ADD COLUMN price_for_rental DECIMAL(10, 2);

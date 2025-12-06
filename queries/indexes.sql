-- Customer indexes
CREATE INDEX idx_customers_status ON rental_service.customers(status);

-- Vehicle indexes
CREATE SPATIAL INDEX idx_vehicles_location ON rental_service.vehicles(location);
CREATE INDEX idx_vehicles_status ON rental_service.vehicles(status);
CREATE INDEX idx_vehicles_type_status ON rental_service.vehicles(vehicle_type, status);

-- Rental indexes
CREATE INDEX idx_rentals_customer_id ON rental_service.rentals(customer_id);
CREATE INDEX idx_rentals_vehicle_id ON rental_service.rentals(vehicle_id);
CREATE INDEX idx_rentals_status ON rental_service.rentals(status);
CREATE INDEX idx_rentals_customer_status ON rental_service.rentals(customer_id, status);
CREATE INDEX idx_rentals_start_datetime ON rental_service.rentals(start_datetime DESC);
CREATE INDEX idx_rentals_customer_vehicle_start ON rental_service.rentals(customer_id, start_datetime DESC);

-- Rental waypoints indexes
CREATE INDEX idx_waypoints_rental_id ON rental_service.rental_waypoints(rental_id);
CREATE INDEX idx_waypoints_timestamp ON rental_service.rental_waypoints(timestamp);
CREATE INDEX idx_waypoints_speed ON rental_service.rental_waypoints(rental_id, speed);

-- Subscription indexes
CREATE INDEX idx_subscriptions_customer_id ON rental_service.subscriptions(customer_id);
CREATE INDEX idx_subscriptions_status ON rental_service.subscriptions(status);
CREATE INDEX idx_subscriptions_dates ON rental_service.subscriptions(start_date, end_date);

-- Maintenance indexes
CREATE INDEX idx_maintenance_vehicle_id ON rental_service.maintenance(vehicle_id);
CREATE INDEX idx_maintenance_status ON rental_service.maintenance(status);
CREATE INDEX idx_maintenance_scheduled_date ON rental_service.maintenance(scheduled_date);
CREATE INDEX idx_maintenance_performed_date ON rental_service.maintenance(performed_date);

-- Payment indexes
CREATE INDEX idx_payments_customer_id ON rental_service.payments(customer_id);
CREATE INDEX idx_payments_rental_id ON rental_service.payments(rental_id);
CREATE INDEX idx_payments_subscription_id ON rental_service.payments(subscription_id);
CREATE INDEX idx_payments_status ON rental_service.payments(status);

-- Document indexes
CREATE INDEX idx_documents_customer_id ON rental_service.documents(customer_id);
CREATE INDEX idx_documents_vehicle_id ON rental_service.documents(vehicle_id);
CREATE INDEX idx_documents_expiry_date ON rental_service.documents(expiry_date);
CREATE INDEX idx_documents_customer_type ON rental_service.documents(customer_id, document_type);
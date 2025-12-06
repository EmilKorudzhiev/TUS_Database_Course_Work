-- промяна на статуса на превозното средство при създаване на нов наем
CREATE TRIGGER trg_rentals_set_vehicle_rented
    AFTER INSERT ON rental_service.rentals
    FOR EACH ROW
BEGIN
    IF NEW.status = 'ACTIVE' THEN
    UPDATE rental_service.vehicles SET status = 'RENTED' WHERE id = NEW.vehicle_id;
END IF;
END;
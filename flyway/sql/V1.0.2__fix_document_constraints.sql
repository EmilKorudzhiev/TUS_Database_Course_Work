ALTER TABLE rental_service.documents
DROP
CONSTRAINT constraint_customer_documents,
DROP
CONSTRAINT constraint_vehicle_documents;

ALTER TABLE rental_service.documents
    ADD CONSTRAINT constraint_customer_documents CHECK (document_type NOT IN
                                                        ('ID_CARD', 'PASSPORT', 'DRIVERS_LICENSE') OR
                                                        (customer_id IS NOT NULL AND vehicle_id IS NULL)),
    ADD CONSTRAINT constraint_vehicle_documents CHECK (document_type NOT IN
                                                        ('INSURANCE', 'REGISTRATION') OR
                                                        (vehicle_id IS NOT NULL AND customer_id IS NULL));
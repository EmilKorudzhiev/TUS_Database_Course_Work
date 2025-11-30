-- 1. Търсене на най-близли налични превозни средства по тип и дадена мерна единица за разтояние
SELECT v.identifier,
       v.brand,
       v.model,
       v.vehicle_type,
       v.power_type,
       v.price_per_minute,
       v.price_per_km,
       v.price_for_rental,
       v.location,
       ST_DISTANCE(ST_GeomFromText('POINT(23.28009015708178 42.652249987433666)', 4326), v.location,
                   'metre') as distance_from_location
FROM rental_service.vehicles v
WHERE v.status = 'AVAILABLE'
  AND v.vehicle_type = 'BICYCLE'
ORDER BY distance_from_location LIMIT 10;
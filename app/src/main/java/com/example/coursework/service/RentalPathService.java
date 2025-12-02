package com.example.coursework.service;


import com.example.coursework.model.Rental;
import com.example.coursework.model.RentalWaypoint;
import com.example.coursework.model.dto.LatLng;
import com.example.coursework.repository.RentalWaypointRepository;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class RentalPathService {

    private final RentalWaypointRepository waypointRepository;
    private final GeometryFactory geometryFactory;

    public RentalPathService(RentalWaypointRepository waypointRepository,
                             GeometryFactory geometryFactory) {
        this.waypointRepository = waypointRepository;
        this.geometryFactory = geometryFactory;
    }

    @Transactional
    public void saveRoute(Rental rental, List<LatLng> routePoints) {

        if (routePoints == null || routePoints.size() < 2) {
            return;
        }

        LocalDateTime startTime = rental.getStartDateTime(); // адаптирай към името при теб
        LocalDateTime endTime = rental.getEndDateTime();

        if (startTime == null) {
            startTime = endTime != null ? endTime.minusMinutes(5) : LocalDateTime.now().minusMinutes(5);
        }
        if (endTime == null) {
            endTime = LocalDateTime.now();
        }

        long totalSeconds = Math.max(1, Duration.between(startTime, endTime).getSeconds());
        int pointsCount = routePoints.size();
        long stepSeconds = Math.max(1, totalSeconds / Math.max(1, pointsCount - 1));

        for (int i = 0; i < pointsCount; i++) {
            LatLng p = routePoints.get(i);

            Coordinate coord = new Coordinate(p.getLng(), p.getLat()); // x=lng, y=lat
            Point point = geometryFactory.createPoint(coord);
            point.setSRID(4326);

            RentalWaypoint wp = new RentalWaypoint();
            wp.setRental(rental);
            wp.setLocation(point);
            wp.setTimestamp(startTime.plusSeconds(stepSeconds * i));
            wp.setSpeed(null);

            waypointRepository.save(wp);
        }
    }
}


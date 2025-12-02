package com.example.coursework.service;

import com.example.coursework.model.*;
import com.example.coursework.model.dto.LatLng;
import com.example.coursework.repository.CustomerRepository;
import com.example.coursework.repository.RentalRepository;
import com.example.coursework.repository.RentalWaypointRepository;
import com.example.coursework.util.LocationUtil;
import jakarta.transaction.Transactional;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class RentalService {

    private RentalRepository repository;
    private PaymentsService paymentsService;
    private VehicleService vehicleService;
    private CustomerRepository customerRepository;
    private final RentalWaypointRepository waypointRepository;
    private final GeometryFactory geometryFactory;
    private final RentalPathService rentalPathService;
    private final DirectionsService directionsService;

    public RentalService(RentalRepository repository, PaymentsService paymentsService, VehicleService vehicleService, CustomerRepository customerRepository, RentalWaypointRepository waypointRepository, GeometryFactory geometryFactory, RentalPathService rentalPathService, DirectionsService directionsService) {
        this.repository = repository;
        this.paymentsService = paymentsService;
        this.vehicleService = vehicleService;
        this.customerRepository = customerRepository;
        this.waypointRepository = waypointRepository;
        this.geometryFactory = geometryFactory;
        this.rentalPathService = rentalPathService;
        this.directionsService = directionsService;
    }

    public Optional<Rental> getRentalByVehicle(Vehicle vehicle, Rental.Status status){
        return repository.findRentalByVehicleAndStatus(vehicle, status);
    }

    public void finishTrip(Long rentalId) {
       Rental byId = repository.findById(rentalId).get();
       byId.setEndDateTime(LocalDateTime.now());
    }

    public List<Rental> getRentalsByCustomer(Customer customerByID) {
        return repository.findAllByCustomer(customerByID);
    }

    public void payRental(Long rentalId) {
        Rental rental = repository.findById(rentalId)
                .orElseThrow(() -> new IllegalArgumentException("Rental not found: " + rentalId));

        rental.setPaid(true);
        Payment payment = new Payment();
        payment.setRental(rental);
        payment.setPaymentMethod(Payment.PaymentMethod.card);
        payment.setCustomer(rental.getCustomer());
        payment.setStatus(Payment.Status.completed);
        payment.setAmount(rental.getPrice());
        payment.setCurrency("EUR");
        payment.setPaymentDate(LocalDateTime.now());
        paymentsService.savePayment(payment);
        repository.save(rental);
    }

    public void finshTrip(Long rentalId) {
        Rental rental = repository.findById(rentalId)
                .orElseThrow(() -> new IllegalArgumentException("Rental not found"));

        Vehicle vehicle = rental.getVehicle();

        // старт и край за маршрута
        String startLoc = vehicle.getLocation();              // текуща локация преди FINISH
        String endLoc = LocationUtil.randomLocationInSofia(); // нова локация
        String randomLocation = endLoc;

        // 1) изчисляваме разстоянието (по права линия)
        double distance = LocationUtil.distanceKm(startLoc, endLoc);
        rental.setDistanceKm(BigDecimal.valueOf(distance));

        // 2) статуси и времена
        rental.setStatus(Rental.Status.completed);
        rental.setEndDateTime(LocalDateTime.now());
        vehicle.setStatus(Vehicle.Status.available);

        // 3) цена
        rental.setPrice(
                rental.getPrice().add(
                        vehicle.getPricePerKm().multiply(rental.getDistanceKm())
                )
        );

        // 4) взимаме реален маршрут от Google Directions
        List<LatLng> route = directionsService.getRoute(startLoc, endLoc);
        rentalPathService.saveRoute(rental, route);

        // 5) накрая обновяваме локацията на автомобила
        vehicle.setLocation(randomLocation);

        repository.save(rental);
        vehicleService.saveVehicle(vehicle);
    }

    public void startRentalForCustomerAndVehicle(Long customerID, Long vehicleId) {
        Vehicle vehicle = vehicleService.findVehicleById(vehicleId).get();
        Customer customer = customerRepository.findById(customerID).get();
        Rental rental = new Rental();
        rental.setPrice(vehicle.getPriceForRental());
        rental.setVehicle(vehicle);
        rental.setCustomer(customer);
        rental.setPaid(false);
        rental.setStatus(Rental.Status.active);
        rental.setStartDateTime(LocalDateTime.now());
        vehicle.setStatus(Vehicle.Status.rented);
        vehicleService.saveVehicle(vehicle);
        repository.save(rental);
    }

    @Transactional
    public void generateAndSavePathForRental(Rental rental,
                                             String startLoc,
                                             String endLoc,
                                             int steps) {

        List<String> pathPoints = LocationUtil.generatePath(startLoc, endLoc, steps);

        LocalDateTime startTime = rental.getStartDateTime();  // адаптирай към полето ти
        LocalDateTime endTime = rental.getEndDateTime();      // вече сетнато при finishTrip

        if (endTime == null || startTime == null) {
            endTime = LocalDateTime.now();
            if (startTime == null) {
                startTime = endTime.minusMinutes(5);
            }
        }

        long totalSeconds = Math.max(1, Duration.between(startTime, endTime).getSeconds());
        int pointsCount = pathPoints.size();
        long stepSeconds = Math.max(1, totalSeconds / Math.max(1, pointsCount - 1));

        for (int i = 0; i < pointsCount; i++) {
            String loc = pathPoints.get(i);
            double[] latLng = parseLocation(loc);
            double lat = latLng[0];
            double lng = latLng[1];

            Coordinate coord = new Coordinate(lng, lat);
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

    public Optional<Rental> findLastCompletedRentalByCustomer(Long customerId) {
        return repository.findTopByCustomerIdAndStatusOrderByEndDateTimeDesc(
                customerId,
                Rental.Status.completed
        );
    }

    private double[] parseLocation(String loc) {
        String[] parts = loc.split(",");
        if (parts.length != 2) {
            throw new IllegalArgumentException("Invalid location: " + loc);
        }
        double lat = Double.parseDouble(parts[0].trim());
        double lng = Double.parseDouble(parts[1].trim());
        return new double[]{lat, lng};
    }
}

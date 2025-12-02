package com.example.coursework.service;

import com.example.coursework.model.Rental;
import com.example.coursework.model.Vehicle;
import com.example.coursework.model.dto.VehicleRentDto;
import com.example.coursework.repository.RentalRepository;
import com.example.coursework.repository.VehicleRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class VehicleService {

    private VehicleRepository vehicleRepository;
    private RentalRepository rentalRepository;

    public VehicleService(VehicleRepository vehicleRepository, RentalRepository rentalRepository) {
        this.vehicleRepository = vehicleRepository;
        this.rentalRepository = rentalRepository;
    }

    public List<VehicleRentDto> getAllVehicles(){
        return vehicleRepository.findAll()
                .stream()
                .map(v -> {
                    Long renterId = null;
                    Long rentalId = null;

                    if (v.getStatus() == Vehicle.Status.rented) {
                        Optional<Rental> rentalByVehicle = rentalRepository.findRentalByVehicleAndStatus(v, Rental.Status.active);

                        if (rentalByVehicle.isPresent()
                                && rentalByVehicle.get().getStatus() == Rental.Status.active) {
                            renterId = rentalByVehicle.get().getCustomer().getId();
                            rentalId = rentalByVehicle.get().getId();
                        }
                    }

                    return new VehicleRentDto(
                            v.getId(),
                            v.getIdentifier(),
                            v.getRegistrationNumber(),
                            v.getBrand(),
                            v.getModel(),
                            v.getStatus(),
                            v.getLocation(),renterId, rentalId,  v.getPricePerMinute(), v.getPricePerKm(), v.getPriceForRental()
                    );
                })
                .toList();
    }

    public void saveVehicle(Vehicle vehicle) {
        vehicleRepository.save(vehicle);
    }

    public Optional<Vehicle> findVehicleById(Long vehicleId) {
        return vehicleRepository.findById(vehicleId);
    }
}

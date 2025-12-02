package com.example.coursework.repository;

import com.example.coursework.model.Customer;
import com.example.coursework.model.Rental;
import com.example.coursework.model.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RentalRepository extends JpaRepository<Rental, Long> {

    Optional<Rental> findRentalByVehicleAndStatus(Vehicle vehicle, Rental.Status status);
    List<Rental> findAllByCustomer(Customer customer);

    Optional<Rental> findTopByCustomerIdAndStatusOrderByEndDateTimeDesc(Long customerId, Rental.Status status);
}

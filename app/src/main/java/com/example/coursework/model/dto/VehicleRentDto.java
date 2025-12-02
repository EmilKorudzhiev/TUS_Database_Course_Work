package com.example.coursework.model.dto;

import com.example.coursework.model.Vehicle;
import jakarta.persistence.Column;

import java.math.BigDecimal;

public class VehicleRentDto {

    private Long id;
    private String identifier;
    private String registrationNumber;
    private String brand;
    private String model;
    private Vehicle.Status status;
    private String location;
    private Long rentedByCustomerId;
    private Long rentalId;
    private BigDecimal pricePerMinute;

    private BigDecimal pricePerKm;

    private BigDecimal priceForRental;

    public Long getRentalId() {
        return rentalId;
    }

    public void setRentalId(Long rentalId) {
        this.rentalId = rentalId;
    }

    public VehicleRentDto() {
    }

    public VehicleRentDto(Long id,
                          String identifier,
                          String registrationNumber,
                          String brand,
                          String model,
                          Vehicle.Status status,
                          Long rentedByCustomerId, Long rentalId, String location) {
        this.id = id;
        this.identifier = identifier;
        this.registrationNumber = registrationNumber;
        this.brand = brand;
        this.model = model;
        this.status = status;
        this.rentedByCustomerId = rentedByCustomerId;
        this.rentalId = rentalId;
        this.location = location;
    }

    public VehicleRentDto(Long id, String identifier, String registrationNumber, String brand, String model, Vehicle.Status status, String location, Long rentedByCustomerId, Long rentalId, BigDecimal pricePerMinute, BigDecimal pricePerKm, BigDecimal priceForRental) {
        this.id = id;
        this.identifier = identifier;
        this.registrationNumber = registrationNumber;
        this.brand = brand;
        this.model = model;
        this.status = status;
        this.location = location;
        this.rentedByCustomerId = rentedByCustomerId;
        this.rentalId = rentalId;
        this.pricePerMinute = pricePerMinute;
        this.pricePerKm = pricePerKm;
        this.priceForRental = priceForRental;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getIdentifier() {
        return identifier;
    }

    public void setIdentifier(String identifier) {
        this.identifier = identifier;
    }

    public String getRegistrationNumber() {
        return registrationNumber;
    }

    public void setRegistrationNumber(String registrationNumber) {
        this.registrationNumber = registrationNumber;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public Vehicle.Status getStatus() {
        return status;
    }

    public void setStatus(Vehicle.Status status) {
        this.status = status;
    }

    public Long getRentedByCustomerId() {
        return rentedByCustomerId;
    }

    public void setRentedByCustomerId(Long rentedByCustomerId) {
        this.rentedByCustomerId = rentedByCustomerId;
    }

    public BigDecimal getPricePerMinute() {
        return pricePerMinute;
    }

    public void setPricePerMinute(BigDecimal pricePerMinute) {
        this.pricePerMinute = pricePerMinute;
    }

    public BigDecimal getPricePerKm() {
        return pricePerKm;
    }

    public void setPricePerKm(BigDecimal pricePerKm) {
        this.pricePerKm = pricePerKm;
    }

    public BigDecimal getPriceForRental() {
        return priceForRental;
    }

    public void setPriceForRental(BigDecimal priceForRental) {
        this.priceForRental = priceForRental;
    }
}

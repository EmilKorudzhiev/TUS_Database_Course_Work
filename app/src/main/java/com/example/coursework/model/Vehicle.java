package com.example.coursework.model;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "Vehicles")
public class Vehicle {

    public enum Status {
        available, rented, maintenance, inactive
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vehicle_id")
    private Long id;

    @Column(name = "identifier", nullable = false)
    private String identifier;

    @Column(name = "registration_number")
    private String registrationNumber;

    @Column(name = "brand", nullable = false)
    private String brand;

    @Column(name = "model", nullable = false)
    private String model;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private Status status;

    @Column
    private String location;

    @ManyToOne
    @JoinColumn(name = "next_maintenance_id")
    private Maintenance nextMaintenance;

    @Column(name = "price_per_minute", precision = 10, scale = 2)
    private BigDecimal pricePerMinute;

    @Column(name = "price_per_km", precision = 10, scale = 2)
    private BigDecimal pricePerKm;

    @Column(name = "price_for_rental", precision = 10, scale = 2)
    private BigDecimal priceForRental;

    // getters and setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getIdentifier() {
        return identifier;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
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

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public Maintenance getNextMaintenance() {
        return nextMaintenance;
    }

    public void setNextMaintenance(Maintenance nextMaintenance) {
        this.nextMaintenance = nextMaintenance;
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

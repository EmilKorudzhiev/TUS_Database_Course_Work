package com.example.coursework.web.controller;

import com.example.coursework.model.RentalWaypoint;
import com.example.coursework.model.dto.VehicleRentDto;
import com.example.coursework.repository.RentalWaypointRepository;
import com.example.coursework.service.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class HomePage {

    private VehicleService vehicleService;
    private PaymentsService paymentsService;
    private CustomerService customerService;
    private RentalService rentalService;
    private final RentalWaypointRepository waypointRepository;

    public HomePage(VehicleService vehicleService, PaymentsService paymentsService, CustomerService customerService, RentalService rentalService, RentalWaypointRepository waypointRepository) {
        this.vehicleService = vehicleService;
        this.paymentsService = paymentsService;
        this.customerService = customerService;
        this.rentalService = rentalService;
        this.waypointRepository = waypointRepository;
    }

    @GetMapping("/cars")
    public String showCars(Model model) {
        List<VehicleRentDto> cars = vehicleService.getAllVehicles();
        model.addAttribute("cars", cars);

        // Тук примерно за клиент с id = 1 (за демо)
        Long customerId = 1L;

        rentalService.findLastCompletedRentalByCustomer(customerId)
                .ifPresent(rental -> {
                    List<RentalWaypoint> waypoints =
                            waypointRepository.findByRentalIdOrderByTimestampAsc(rental.getId());
                    model.addAttribute("waypoints", waypoints);
                });

        return "index";
    }

    @GetMapping("/payments")
    public String getPayments(Model model) {
        model.addAttribute("payments", paymentsService.getCustomerPayments(customerService.getCustomerByID(1L)));
        return "payments";
    }

    //TODO show all trips and make button for payment
    @GetMapping("/trips")
    public String showTrips(Model model) {
        model.addAttribute("trips", rentalService.getRentalsByCustomer(customerService.getCustomerByID(1L)));
        return "trips";
    }
    @PostMapping("/pay-trip")
    public String payTrip(@RequestParam("rentalId") Long rentalId) {
        rentalService.payRental(rentalId); // set paid = true, maybe create Payment
        return "redirect:/trips";
    }

    @PostMapping("/finish-trip")
    public String finishTrip(@RequestParam("rentalId") Long rentalId) {
        rentalService.finshTrip(rentalId);
        return "redirect:/cars";
    }

    @PostMapping("/rent-vehicle")
    public String rentVehicle(@RequestParam("vehicleId") Long vehicleId) {
        rentalService.startRentalForCustomerAndVehicle(1L, vehicleId); // example: customer 1 for now
        return "redirect:/cars";
    }
}

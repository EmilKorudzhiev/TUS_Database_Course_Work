package com.example.coursework.repository;

import com.example.coursework.model.RentalWaypoint;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RentalWaypointRepository extends JpaRepository<RentalWaypoint, Long> {

    List<RentalWaypoint> findByRentalIdOrderByTimestampAsc(Long rentalId);
}

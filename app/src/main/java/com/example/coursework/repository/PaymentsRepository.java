package com.example.coursework.repository;

import com.example.coursework.model.Customer;
import com.example.coursework.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentsRepository extends JpaRepository<Payment, Long> {

    List<Payment> findAllByCustomer(Customer customer);

}

package com.example.coursework.service;

import com.example.coursework.model.Customer;
import com.example.coursework.model.Payment;
import com.example.coursework.repository.PaymentsRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PaymentsService {

    private PaymentsRepository paymentsRepository;


    public PaymentsService(PaymentsRepository paymentsRepository) {
        this.paymentsRepository = paymentsRepository;
    }

    public List<Payment> getCustomerPayments(Customer customer){
        return paymentsRepository.findAllByCustomer(customer);
    }

    public void savePayment(Payment payment) {
        paymentsRepository.saveAndFlush(payment);
    }
}

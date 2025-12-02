package com.example.coursework.service;

import com.example.coursework.model.Customer;
import com.example.coursework.model.Vehicle;
import com.example.coursework.repository.CustomerRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerService {

    private CustomerRepository customerRepository;

    public CustomerService(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }


    public Customer getCustomerByID(Long id){
        return customerRepository.getCustomerById(id);
    }

}

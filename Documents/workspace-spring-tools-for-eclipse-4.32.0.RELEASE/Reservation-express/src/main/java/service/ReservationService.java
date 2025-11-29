package service;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import model.Reservation;
import model.RestaurantTable;
import model.User;
import repository.ReservationRepository;
import repository.TableRepository;
import repository.UserRepository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Service
public class ReservationService {
    
    @Autowired
    private ReservationRepository reservationRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private TableRepository tableRepository;
    
    public Reservation createReservation(Reservation reservation) {
        // Calculate total price
        Double totalPrice = reservation.getTable().getPricePerHour() * reservation.getDurationHours();
        reservation.setTotalPrice(totalPrice);
        
        return reservationRepository.save(reservation);
    }
    
    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }
    
    public Optional<Reservation> getReservationById(Long id) {
        return reservationRepository.findById(id);
    }
    
    public List<Reservation> getReservationsByUser(Long userId) {
        Optional<User> user = userRepository.findById(userId);
        return user.map(reservationRepository::findByUser).orElse(List.of());
    }
    
    public List<Reservation> getReservationsByTable(Long tableId) {
        Optional<RestaurantTable> table = tableRepository.findById(tableId);
        return table.map(reservationRepository::findByTable).orElse(List.of());
    }
    
    public List<Reservation> getReservationsByDate(LocalDate date) {
        return reservationRepository.findByReservationDate(date);
    }
    
    public Reservation updateReservation(Long id, Reservation reservationDetails) {
        Optional<Reservation> reservationOptional = reservationRepository.findById(id);
        if (reservationOptional.isPresent()) {
            Reservation reservation = reservationOptional.get();
            
            if (reservationDetails.getReservationDate() != null) {
                reservation.setReservationDate(reservationDetails.getReservationDate());
            }
            if (reservationDetails.getReservationTime() != null) {
                reservation.setReservationTime(reservationDetails.getReservationTime());
            }
            if (reservationDetails.getDurationHours() != null) {
                reservation.setDurationHours(reservationDetails.getDurationHours());
            }
            if (reservationDetails.getNumberOfGuests() != null) {
                reservation.setNumberOfGuests(reservationDetails.getNumberOfGuests());
            }
            if (reservationDetails.getSpecialRequests() != null) {
                reservation.setSpecialRequests(reservationDetails.getSpecialRequests());
            }
            if (reservationDetails.getStatus() != null) {
                reservation.setStatus(reservationDetails.getStatus());
            }
            if (reservationDetails.getTotalPrice() != null) {
                reservation.setTotalPrice(reservationDetails.getTotalPrice());
            }
            
            return reservationRepository.save(reservation);
        }
        return null;
    }
    
    public boolean cancelReservation(Long id) {
        Optional<Reservation> reservationOptional = reservationRepository.findById(id);
        if (reservationOptional.isPresent()) {
            Reservation reservation = reservationOptional.get();
            reservation.setStatus("cancelled");
            reservationRepository.save(reservation);
            return true;
        }
        return false;
    }
    
    public boolean deleteReservation(Long id) {
        if (reservationRepository.existsById(id)) {
            reservationRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
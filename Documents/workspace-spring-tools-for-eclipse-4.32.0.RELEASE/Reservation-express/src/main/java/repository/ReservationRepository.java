package repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import model.Reservation;
import model.RestaurantTable;
import model.User;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByUser(User user);
    List<Reservation> findByTable(RestaurantTable table);
    List<Reservation> findByReservationDate(LocalDate date);
    List<Reservation> findByStatus(String status);
    
    @Query("SELECT r FROM Reservation r WHERE r.user.id = :userId AND r.status != 'cancelled'")
    List<Reservation> findActiveReservationsByUser(@Param("userId") Long userId);
}
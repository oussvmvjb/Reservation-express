package repository;

import model.Order;
import model.User;
import model.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByUser(User user);
    List<Order> findByReservation(Reservation reservation);
    List<Order> findByStatus(String status);
    Optional<Order> findByOrderNumber(String orderNumber);
}
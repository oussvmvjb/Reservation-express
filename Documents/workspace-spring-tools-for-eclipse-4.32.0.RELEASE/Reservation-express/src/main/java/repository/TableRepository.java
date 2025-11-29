package repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import model.RestaurantTable;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface TableRepository extends JpaRepository<RestaurantTable, Long> {
    List<RestaurantTable> findByStatus(String status);
    List<RestaurantTable> findByTableType(String tableType);
    List<RestaurantTable> findByCapacityGreaterThanEqual(Integer capacity);
    Optional<RestaurantTable> findByTableNumber(String tableNumber);
    
    @Query("SELECT t FROM RestaurantTable t WHERE t.status = 'available' AND t.id NOT IN " +
           "(SELECT r.table.id FROM Reservation r WHERE r.reservationDate = :date " +
           "AND r.reservationTime BETWEEN :startTime AND :endTime AND r.status != 'cancelled')")
    List<RestaurantTable> findAvailableTables(@Param("date") LocalDate date, 
                                            @Param("startTime") LocalTime startTime,
                                            @Param("endTime") LocalTime endTime);
}
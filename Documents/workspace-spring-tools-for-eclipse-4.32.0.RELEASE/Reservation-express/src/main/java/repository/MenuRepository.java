package repository;

import model.MenuItem; // IMPORT CORRECT
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MenuRepository extends JpaRepository<MenuItem, Long> {
    List<MenuItem> findByCategory(String category);
    List<MenuItem> findByNameContainingIgnoreCase(String name);
    List<MenuItem> findByPriceBetween(Double minPrice, Double maxPrice);
    
    @Query("SELECT m FROM MenuItem m WHERE m.category = :category AND m.price BETWEEN :minPrice AND :maxPrice")
    List<MenuItem> findByCategoryAndPriceBetween(@Param("category") String category, 
                                               @Param("minPrice") Double minPrice, 
                                               @Param("maxPrice") Double maxPrice);
}
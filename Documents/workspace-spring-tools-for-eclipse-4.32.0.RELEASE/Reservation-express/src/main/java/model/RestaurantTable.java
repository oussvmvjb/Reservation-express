package model;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "restaurant_tables")
public class RestaurantTable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "table_number", unique = true, nullable = false)
    private String tableNumber;
    
    @Column(nullable = false)
    private Integer capacity;
    
    @Column(name = "table_type")
    private String tableType; // indoor, outdoor, vip
    
    @Column(nullable = false)
    private String status = "available"; // available, reserved, occupied
    
    @Column(name = "location_description")
    private String locationDescription;
    
    @Column(name = "price_per_hour")
    private Double pricePerHour;
    
    @Column(name = "image_url")
    private String imageUrl;
    
    // Constructors, Getters and Setters
    public RestaurantTable() {}
    
    public RestaurantTable(String tableNumber, Integer capacity, String tableType, 
                          String locationDescription, Double pricePerHour, String imageUrl) {
        this.tableNumber = tableNumber;
        this.capacity = capacity;
        this.tableType = tableType;
        this.locationDescription = locationDescription;
        this.pricePerHour = pricePerHour;
        this.imageUrl = imageUrl;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }
    
    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }
    
    public String getTableType() { return tableType; }
    public void setTableType(String tableType) { this.tableType = tableType; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getLocationDescription() { return locationDescription; }
    public void setLocationDescription(String locationDescription) { this.locationDescription = locationDescription; }
    
    public Double getPricePerHour() { return pricePerHour; }
    public void setPricePerHour(Double pricePerHour) { this.pricePerHour = pricePerHour; }
    
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}
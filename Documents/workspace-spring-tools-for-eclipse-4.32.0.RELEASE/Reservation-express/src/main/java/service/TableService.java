package service;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import model.RestaurantTable;
import repository.TableRepository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Service
public class TableService {
    
    @Autowired
    private TableRepository tableRepository;
    
    public List<RestaurantTable> getAllTables() {
        return tableRepository.findAll();
    }
    
    public Optional<RestaurantTable> getTableById(Long id) {
        return tableRepository.findById(id);
    }
    
    public List<RestaurantTable> getAvailableTables() {
        return tableRepository.findByStatus("available");
    }
    
    public List<RestaurantTable> getTablesByType(String tableType) {
        return tableRepository.findByTableType(tableType);
    }
    
    public List<RestaurantTable> getTablesByCapacity(Integer capacity) {
        return tableRepository.findByCapacityGreaterThanEqual(capacity);
    }
    
    public List<RestaurantTable> getAvailableTablesForDateTime(LocalDate date, LocalTime time) {
        LocalTime endTime = time.plusHours(2); // Default 2 hours reservation
        return tableRepository.findAvailableTables(date, time, endTime);
    }
    
    public RestaurantTable saveTable(RestaurantTable table) {
        return tableRepository.save(table);
    }
    
    public RestaurantTable updateTable(Long id, RestaurantTable tableDetails) {
        Optional<RestaurantTable> tableOptional = tableRepository.findById(id);
        if (tableOptional.isPresent()) {
            RestaurantTable table = tableOptional.get();
            
            if (tableDetails.getTableNumber() != null) {
                table.setTableNumber(tableDetails.getTableNumber());
            }
            if (tableDetails.getCapacity() != null) {
                table.setCapacity(tableDetails.getCapacity());
            }
            if (tableDetails.getTableType() != null) {
                table.setTableType(tableDetails.getTableType());
            }
            if (tableDetails.getStatus() != null) {
                table.setStatus(tableDetails.getStatus());
            }
            if (tableDetails.getLocationDescription() != null) {
                table.setLocationDescription(tableDetails.getLocationDescription());
            }
            if (tableDetails.getPricePerHour() != null) {
                table.setPricePerHour(tableDetails.getPricePerHour());
            }
            if (tableDetails.getImageUrl() != null) {
                table.setImageUrl(tableDetails.getImageUrl());
            }
            
            return tableRepository.save(table);
        }
        return null;
    }
    
    public boolean deleteTable(Long id) {
        if (tableRepository.existsById(id)) {
            tableRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
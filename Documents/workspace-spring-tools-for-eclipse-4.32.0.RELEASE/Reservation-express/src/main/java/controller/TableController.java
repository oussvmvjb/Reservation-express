package controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import model.RestaurantTable;
import service.TableService;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/tables")
@CrossOrigin(origins = "*")
public class TableController {
    
    @Autowired
    private TableService tableService;
    
    @GetMapping
    public List<RestaurantTable> getAllTables() {
        return tableService.getAllTables();
    }
    
    @GetMapping("/available")
    public List<RestaurantTable> getAvailableTables() {
        return tableService.getAvailableTables();
    }
    
    @GetMapping("/type/{tableType}")
    public List<RestaurantTable> getTablesByType(@PathVariable String tableType) {
        return tableService.getTablesByType(tableType);
    }
    
    @GetMapping("/capacity/{capacity}")
    public List<RestaurantTable> getTablesByCapacity(@PathVariable Integer capacity) {
        return tableService.getTablesByCapacity(capacity);
    }
    
    @GetMapping("/available/{date}/{time}")
    public List<RestaurantTable> getAvailableTablesForDateTime(
            @PathVariable String date, 
            @PathVariable String time) {
        
        LocalDate reservationDate = LocalDate.parse(date);
        LocalTime reservationTime = LocalTime.parse(time);
        
        return tableService.getAvailableTablesForDateTime(reservationDate, reservationTime);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<RestaurantTable> getTableById(@PathVariable Long id) {
        Optional<RestaurantTable> table = tableService.getTableById(id);
        return table.map(ResponseEntity::ok)
                   .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<RestaurantTable> createTable(@RequestBody RestaurantTable table) {
        try {
            RestaurantTable savedTable = tableService.saveTable(table);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedTable);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<?> updateTable(@PathVariable Long id, @RequestBody RestaurantTable tableDetails) {
        try {
            RestaurantTable updatedTable = tableService.updateTable(id, tableDetails);
            if (updatedTable != null) {
                return ResponseEntity.ok(updatedTable);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("{\"message\": \"Erreur lors de la mise à jour\"}");
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTable(@PathVariable Long id) {
        try {
            if (tableService.deleteTable(id)) {
                return ResponseEntity.ok().body("{\"message\": \"Table supprimée avec succès\"}");
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("{\"message\": \"Erreur lors de la suppression\"}");
        }
    }
}
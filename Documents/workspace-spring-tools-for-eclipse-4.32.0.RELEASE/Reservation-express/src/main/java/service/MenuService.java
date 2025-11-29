package service;

import model.MenuItem; // IMPORT CORRECT
import repository.MenuRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MenuService {
    
    @Autowired
    private MenuRepository menuRepository;
    
    public List<MenuItem> getAllMenuItems() {
        return menuRepository.findAll();
    }
    
    public Optional<MenuItem> getMenuItemById(Long id) {
        return menuRepository.findById(id);
    }
    
    public List<MenuItem> getMenuItemsByCategory(String category) {
        return menuRepository.findByCategory(category);
    }
    
    public List<MenuItem> searchMenuItems(String name) {
        return menuRepository.findByNameContainingIgnoreCase(name);
    }
    
    public List<MenuItem> getMenuItemsByPriceRange(Double minPrice, Double maxPrice) {
        return menuRepository.findByPriceBetween(minPrice, maxPrice);
    }
    
    public List<String> getAllCategories() {
        return menuRepository.findAll()
                .stream()
                .map(MenuItem::getCategory)
                .distinct()
                .toList();
    }
    
    public MenuItem saveMenuItem(MenuItem menuItem) {
        return menuRepository.save(menuItem);
    }
    
    public MenuItem updateMenuItem(Long id, MenuItem menuItemDetails) {
        Optional<MenuItem> menuItemOptional = menuRepository.findById(id);
        if (menuItemOptional.isPresent()) {
            MenuItem menuItem = menuItemOptional.get();
            
            if (menuItemDetails.getCategory() != null) {
                menuItem.setCategory(menuItemDetails.getCategory());
            }
            if (menuItemDetails.getName() != null) {
                menuItem.setName(menuItemDetails.getName());
            }
            if (menuItemDetails.getDescription() != null) {
                menuItem.setDescription(menuItemDetails.getDescription());
            }
            if (menuItemDetails.getPrice() != null) {
                menuItem.setPrice(menuItemDetails.getPrice());
            }
            if (menuItemDetails.getImageUrl() != null) {
                menuItem.setImageUrl(menuItemDetails.getImageUrl());
            }
            if (menuItemDetails.getIngredients() != null) {
                menuItem.setIngredients(menuItemDetails.getIngredients());
            }
            if (menuItemDetails.getPreparationTime() != null) {
                menuItem.setPreparationTime(menuItemDetails.getPreparationTime());
            }
            
            return menuRepository.save(menuItem);
        }
        return null;
    }
    
    public boolean deleteMenuItem(Long id) {
        if (menuRepository.existsById(id)) {
            menuRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
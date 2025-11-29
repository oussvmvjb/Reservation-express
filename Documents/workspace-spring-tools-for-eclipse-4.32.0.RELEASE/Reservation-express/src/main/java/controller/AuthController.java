package controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import model.User;
import service.UserService;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    @Autowired
    private UserService userService;
    
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        try {
            System.out.println("📝 Registration attempt for: " + user.getEmail());
            
            if (userService.emailExists(user.getEmail())) {
                return ResponseEntity.badRequest().body("{\"message\": \"Erreur: L'email existe déjà\"}");
            }
            
            if (user.getPhoneNumber() == null || user.getPhoneNumber().isEmpty()) {
                return ResponseEntity.badRequest().body("{\"message\": \"Erreur: Le numéro de téléphone est obligatoire\"}");
            }
            
            if (user.getPassword() == null || user.getPassword().isEmpty()) {
                return ResponseEntity.badRequest().body("{\"message\": \"Erreur: Le mot de passe est obligatoire\"}");
            }
            
            User savedUser = userService.saveUser(user);
            System.out.println("✅ User registered successfully: " + savedUser.getEmail());
            return ResponseEntity.status(HttpStatus.CREATED).body(savedUser);
            
        } catch (Exception e) {
            System.out.println("❌ Registration error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("{\"message\": \"Erreur lors de l'inscription\"}");
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        try {
            String email = loginRequest.get("email");
            String password = loginRequest.get("password");
            
            System.out.println("🔐 Login attempt for: " + email);
            
            if (email == null || email.isEmpty() || password == null || password.isEmpty()) {
                return ResponseEntity.badRequest().body("{\"message\": \"Email et mot de passe sont requis\"}");
            }
            
            Optional<User> userOptional = userService.getUserByEmail(email);
            if (userOptional.isEmpty()) {
                System.out.println("❌ User not found: " + email);
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("{\"message\": \"Email ou mot de passe incorrect\"}");
            }
            
            User user = userOptional.get();
            if (!user.getPassword().equals(password)) {
                System.out.println("❌ Invalid password for: " + email);
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("{\"message\": \"Email ou mot de passe incorrect\"}");
            }
            
            System.out.println("✅ Login successful for: " + email);
            return ResponseEntity.ok(user);
            
        } catch (Exception e) {
            System.out.println("❌ Login error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("{\"message\": \"Erreur lors de la connexion\"}");
        }
    }
    
    @GetMapping("/check-email/{email}")
    public ResponseEntity<?> checkEmailExists(@PathVariable String email) {
        try {
            boolean exists = userService.emailExists(email);
            System.out.println("📧 Email check for " + email + ": " + exists);
            return ResponseEntity.ok().body("{\"exists\": " + exists + "}");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("{\"message\": \"Erreur lors de la vérification\"}");
        }
    }
    
    @PutMapping("/update-password")
    public ResponseEntity<?> updatePassword(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            String newPassword = request.get("newPassword");
            
            System.out.println("🔑 Password update request for: " + email);
            
            if (email == null || email.isEmpty() || newPassword == null || newPassword.isEmpty()) {
                return ResponseEntity.badRequest().body("{\"message\": \"Email et nouveau mot de passe sont requis\"}");
            }
            
            Optional<User> userOptional = userService.getUserByEmail(email);
            if (userOptional.isEmpty()) {
                return ResponseEntity.badRequest().body("{\"message\": \"Utilisateur non trouvé\"}");
            }
            
            User user = userOptional.get();
            user.setPassword(newPassword);
            userService.saveUser(user);
            
            System.out.println("✅ Password updated successfully for: " + email);
            return ResponseEntity.ok("{\"message\": \"Mot de passe mis à jour avec succès\"}");
            
        } catch (Exception e) {
            System.out.println("❌ Error updating password: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("{\"message\": \"Erreur lors de la mise à jour du mot de passe\"}");
        }
    }
}
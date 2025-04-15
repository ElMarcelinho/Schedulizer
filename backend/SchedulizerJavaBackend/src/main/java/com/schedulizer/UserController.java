package com.schedulizer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.sql.Date;
import java.time.LocalDate;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/api")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @PostMapping("/register")
    public ResponseEntity<String> registerUser(@RequestBody User user) {
        String username = user.getUsername();
        String email = user.getEmail();
        String password = user.getPasswordHash();

        if (username == null || username.length() < 4) {
            return ResponseEntity.badRequest().body("Username must be at least 4 characters.");
        }

        if (email == null || !email.contains("@") || !email.contains(".")) {
            return ResponseEntity.badRequest().body("Invalid email format.");
        }

        if (password == null || password.length() < 8) {
            return ResponseEntity.badRequest().body("Password must be at least 8 characters.");
        }

        if (userRepository.existsByUsername(username)) {
            return ResponseEntity.badRequest().body("Username already exists.");
        }

        if (userRepository.existsByEmail(email)) {
            return ResponseEntity.badRequest().body("Email already exists.");
        }

        try {
            String hashedPassword = passwordEncoder.encode(password);
System.out.println("Hashed Password: " + hashedPassword);
            jdbcTemplate.queryForObject(
                "SELECT register_user(?, ?, ?)",
                String.class,
                username,
                email,
                hashedPassword
            );
            System.out.println("✅ Registration successful for: " + username);
            return ResponseEntity.ok("Registration successful.");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity
                .status(400)
                .body("Registration failed: " + e.getMessage());
        }
    }

    @PostMapping("/login")
public ResponseEntity<?> loginUser(@RequestBody Map<String, String> payload) {


    System.out.println("Login attempt reached!");
    String email = payload.get("email");
    String password = payload.get("password"); // raw password from frontend

    try {
        System.out.println("✅ Login attempt for: " + email);
        System.out.println("✅ Raw password from frontend: " + password);

        // Fetch user by email
        User user = userRepository.findByEmail(email);

        if (user == null) {
            System.out.println("❌ No user found for email: " + email);
            return ResponseEntity.status(401).body("Invalid email or password.");
        }

        // Now that the user object is not null, print the stored password hash from the DB
        System.out.println("✅ Stored password hash in DB: " + user.getPasswordHash());

        // Log the result of password match
        System.out.println("✅ Password match? " + passwordEncoder.matches(password, user.getPasswordHash()));

        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            System.out.println("❌ Password mismatch.");
            return ResponseEntity.status(401).body("Invalid email or password.");
        }

        System.out.println("🎉 Login successful!");
        jdbcTemplate.queryForList("SELECT * FROM login_user(?, ?)", email, password);
        Map<String, String> response = new HashMap<>();
response.put("username", user.getUsername());
response.put("email", user.getEmail());
response.put("role", user.getRole());

return ResponseEntity.ok(response);

    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(500).body("Login failed: " + e.getMessage());
    }
}
@PostMapping("/availability/save")
public ResponseEntity<String> saveAvailability(@RequestBody AvailabilityRequest request) {
    try {
        User user = userRepository.findByEmail(request.getEmail());
        if (user == null) {
            return ResponseEntity.badRequest().body("User not found.");
        }

        String weekStartStr = request.getWeekStart(); // e.g., "2025-04-14"
        LocalDate parsedDate = LocalDate.parse(weekStartStr);
        Date sqlWeekStart = Date.valueOf(parsedDate); // ✅ Proper SQL date

        // ✅ Use sqlWeekStart in both delete and insert
        jdbcTemplate.update(
            "DELETE FROM user_availability WHERE user_id = ? AND week_start = ?",
            user.getId(), sqlWeekStart
        );

        Map<String, String> availability = request.getAvailability();

        String jsonAvailability = new ObjectMapper().writeValueAsString(availability); // JSONB string

jdbcTemplate.execute(
    "SELECT save_user_availability(" + user.getId() + ", '" + sqlWeekStart + "', '" + jsonAvailability + "'::jsonb)"
);


        return ResponseEntity.ok("Availability saved.");
    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(500).body("Error saving availability: " + e.getMessage());
    }
}

@GetMapping("/users/all")
public ResponseEntity<List<String>> getAllUserEmails() {
    try {
        List<User> users = userRepository.findAll();
        List<String> emails = users.stream()
                                   .map(User::getEmail)
                                   .toList();
        return ResponseEntity.ok(emails);
    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(500).body(null);
    }
}
@GetMapping("/availability")
public ResponseEntity<Map<String, String>> getAvailability(
    @RequestParam("email") String email,
    @RequestParam("weekStart") String weekStart) {


    try {
        User user = userRepository.findByEmail(email);
        if (user == null) {
            return ResponseEntity.badRequest().body(null);
        }

        LocalDate parsedDate = LocalDate.parse(weekStart);
Date sqlWeekStart = Date.valueOf(parsedDate);

String query = "SELECT * FROM get_user_availability(?, ?)";
List<Map<String, Object>> rows = jdbcTemplate.queryForList(query, user.getId(), sqlWeekStart);



        Map<String, String> availabilityMap = new HashMap<>();
for (Map<String, Object> row : rows) {
    Object keyObj = row.get("shift_key");
    Object valObj = row.get("availability");

    System.out.println("Row: " + row); // debug output

    if (keyObj != null && valObj != null) {
        availabilityMap.put(keyObj.toString(), valObj.toString());
    } else {
        System.out.println("⚠️ Null or unexpected row values: " + row);
    }
}


        return ResponseEntity.ok(availabilityMap);
    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(500).body(null);
    }
}
@GetMapping("/test")
public ResponseEntity<String> testPublic() {
    return ResponseEntity.ok("I'm public!");
}

}




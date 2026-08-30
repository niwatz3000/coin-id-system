package com.coinid.usercatalog.controller;

import com.coinid.usercatalog.repository.UserRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final UserRepository userRepository;

    public AdminController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // TODO: restrict to ROLE_ADMIN via Spring Security method security
    @GetMapping("/users")
    public List<?> listUsers() {
        return userRepository.findAll().stream()
                .map(u -> new UserSummary(u.getId().toString(), u.getEmail(), u.getDisplayName(), u.getRole()))
                .toList();
    }

    @PutMapping("/users/{id}/role")
    public void updateUserRole(@PathVariable String id, @RequestParam String role) {
        userRepository.findById(java.util.UUID.fromString(id)).ifPresent(u -> {
            u.setRole(role);
            userRepository.save(u);
        });
    }

    public record UserSummary(String id, String email, String displayName, String role) {}
}

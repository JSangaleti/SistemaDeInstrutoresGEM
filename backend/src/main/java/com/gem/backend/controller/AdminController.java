package com.gem.backend.controller;

import com.gem.backend.dto.AdminResponseDTO;
import com.gem.backend.model.Admin;
import com.gem.backend.service.AdminService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/admins")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService service;

    public AdminController(AdminService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<AdminResponseDTO> create(@Valid @RequestBody Admin admin) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createAdmin(admin));
    }

    @GetMapping
    public ResponseEntity<List<AdminResponseDTO>> getList() {
        return ResponseEntity.ok(service.getListAdmin());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AdminResponseDTO> get(@PathVariable Integer id) {
        return ResponseEntity.ok(service.getAdmin(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AdminResponseDTO> update(@PathVariable Integer id, @RequestBody Admin admin) {
        return ResponseEntity.ok(service.updateAdmin(id, admin));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        service.deleteAdmin(id);
        return ResponseEntity.noContent().build();
    }
}

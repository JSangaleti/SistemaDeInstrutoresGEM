/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.ComumResponseDTO;
import com.gem.backend.model.Comum;
import com.gem.backend.service.ComumService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/comuns")
public class ComumController {

    private final ComumService service;

    public ComumController(ComumService service) {
        this.service = service;
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @PostMapping
    public ResponseEntity<ComumResponseDTO> create(@Valid @RequestBody Comum comum) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createComum(comum));
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR', 'ROLE_ALUNO')")
    @GetMapping
    public ResponseEntity<List<ComumResponseDTO>> getList() {
        return ResponseEntity.ok(service.getListComum());
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR', 'ROLE_ALUNO')")
    @GetMapping("/{id}")
    public ResponseEntity<ComumResponseDTO> get(@PathVariable Integer id) {
        return ResponseEntity.ok(service.getComum(id));
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<ComumResponseDTO> update(@PathVariable Integer id, @Valid @RequestBody Comum comum) {
        return ResponseEntity.ok(service.updateComum(id, comum));
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        service.deleteComum(id);
        return ResponseEntity.noContent().build();
    }
}

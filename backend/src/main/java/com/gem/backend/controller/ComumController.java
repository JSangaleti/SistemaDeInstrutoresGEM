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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/comuns")
public class ComumController {

    private final ComumService service;

    public ComumController(ComumService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<ComumResponseDTO> create(@RequestBody Comum comum) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createComum(comum));
    }

    @GetMapping
    public ResponseEntity<List<ComumResponseDTO>> getList() {
        return ResponseEntity.ok(service.getListComum());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ComumResponseDTO> get(@PathVariable Integer id) {
        return ResponseEntity.ok(service.getComum(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ComumResponseDTO> update(@PathVariable Integer id, @RequestBody Comum comum) {
        return ResponseEntity.ok(service.updateComum(id, comum));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        service.deleteComum(id);
        return ResponseEntity.noContent().build();
    }
}

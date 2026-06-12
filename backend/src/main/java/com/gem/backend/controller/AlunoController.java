/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.AlunoResponseDTO;
import com.gem.backend.model.Aluno;
import com.gem.backend.service.AlunoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/alunos")
public class AlunoController {

    private final AlunoService service;

    public AlunoController(AlunoService service) {
        this.service = service;
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @PostMapping
    public ResponseEntity<AlunoResponseDTO> create(@Valid @RequestBody Aluno aluno) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createAluno(aluno));
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @GetMapping
    public ResponseEntity<List<AlunoResponseDTO>> getList() {
        return ResponseEntity.ok(service.getListAluno());
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR', 'ROLE_ALUNO')")
    @GetMapping("/{id}")
    public ResponseEntity<AlunoResponseDTO> get(@PathVariable Long id) {
        return ResponseEntity.ok(service.getAluno(id));
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @PutMapping("/{id}")
    public ResponseEntity<AlunoResponseDTO> update(@PathVariable Long id, @RequestBody Aluno aluno) {
        return ResponseEntity.ok(service.updateAluno(id, aluno));
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.deleteAluno(id);
        return ResponseEntity.noContent().build();
    }
}
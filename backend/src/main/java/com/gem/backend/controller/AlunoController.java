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
import com.gem.backend.dto.AlunoRequestDTO;
import com.gem.backend.service.AlunoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/alunos")
public class AlunoController {

    private final AlunoService service;

    public AlunoController(AlunoService service) {
        this.service = service;
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','INSTRUTOR')")
    public ResponseEntity<AlunoResponseDTO> create(@Valid @RequestBody AlunoRequestDTO aluno) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createAluno(aluno));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','INSTRUTOR')")
    public ResponseEntity<List<AlunoResponseDTO>> getList() {
        return ResponseEntity.ok(service.getListAluno());
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('ALUNO')")
    public ResponseEntity<AlunoResponseDTO> getMe(Authentication authentication) {
        return ResponseEntity.ok(service.getAlunoPorCpf(authentication.getName()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','INSTRUTOR','ALUNO')") 
    public ResponseEntity<AlunoResponseDTO> get(@PathVariable Long id) {
        return ResponseEntity.ok(service.getAluno(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','INSTRUTOR')")
    public ResponseEntity<AlunoResponseDTO> update(
            @PathVariable Long id,
            @Valid @RequestBody AlunoRequestDTO aluno,
            Authentication authentication
    ) {
        return ResponseEntity.ok(service.updateAluno(id, aluno, authentication));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','INSTRUTOR')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.deleteAluno(id);
        return ResponseEntity.noContent().build();
    }
}

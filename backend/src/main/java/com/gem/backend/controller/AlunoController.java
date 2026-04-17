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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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
    public ResponseEntity<AlunoResponseDTO> create(@RequestBody Aluno aluno) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createAluno(aluno));
    }

    @GetMapping
    public ResponseEntity<List<AlunoResponseDTO>> getList() {
        return ResponseEntity.ok(service.getListAluno());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AlunoResponseDTO> get(@PathVariable Long id) {
        return ResponseEntity.ok(service.getAluno(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AlunoResponseDTO> update(@PathVariable Long id, @RequestBody Aluno aluno) {
        return ResponseEntity.ok(service.updateAluno(id, aluno));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.deleteAluno(id);
        return ResponseEntity.noContent().build();
    }
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.PessoaResponseDTO;
import com.gem.backend.model.Pessoa;
import com.gem.backend.service.PessoaService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/pessoas")
public class PessoaController {

    private final PessoaService service;

    public PessoaController(PessoaService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<PessoaResponseDTO> create(@RequestBody Pessoa pessoa) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createPessoa(pessoa));
    }

    @GetMapping
    public ResponseEntity<List<PessoaResponseDTO>> getList() {
        return ResponseEntity.ok(service.getListPessoa());
    }

    @GetMapping("/{cpf}")
    public ResponseEntity<PessoaResponseDTO> get(@PathVariable String cpf) {
        return ResponseEntity.ok(service.getPessoa(cpf));
    }

    @PutMapping("/{cpf}")
    public ResponseEntity<PessoaResponseDTO> update(@PathVariable String cpf, @RequestBody Pessoa pessoa) {
        return ResponseEntity.ok(service.updatePessoa(cpf, pessoa));
    }

    @DeleteMapping("/{cpf}")
    public ResponseEntity<Void> delete(@PathVariable String cpf) {
        service.deletePessoa(cpf);
        return ResponseEntity.noContent().build();
    }
}

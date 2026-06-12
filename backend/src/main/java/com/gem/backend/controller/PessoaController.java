package com.gem.backend.controller;

import com.gem.backend.dto.PessoaResponseDTO;
import com.gem.backend.model.Pessoa;
import com.gem.backend.service.PessoaService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/pessoas")
public class PessoaController {

    private final PessoaService service;

    public PessoaController(PessoaService service) {
        this.service = service;
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @PostMapping
    public ResponseEntity<PessoaResponseDTO> create(@Valid @RequestBody Pessoa pessoa) {
        Pessoa pessoaSalva = service.createPessoa(pessoa);
        PessoaResponseDTO response = new PessoaResponseDTO(pessoaSalva);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @GetMapping
    public ResponseEntity<List<PessoaResponseDTO>> getList() {
        List<PessoaResponseDTO> response = service.getListPessoa()
                .stream()
                .map(PessoaResponseDTO::new)
                .toList();

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @GetMapping("/{cpf}")
    public ResponseEntity<PessoaResponseDTO> get(@PathVariable String cpf) {
        Pessoa pessoa = service.getPessoa(cpf);
        PessoaResponseDTO response = new PessoaResponseDTO(pessoa);

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @PutMapping("/{cpf}")
    public ResponseEntity<PessoaResponseDTO> update(
            @PathVariable String cpf,
            @RequestBody Pessoa pessoa
    ) {
        Pessoa pessoaAtualizada = service.updatePessoa(cpf, pessoa);
        PessoaResponseDTO response = new PessoaResponseDTO(pessoaAtualizada);

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @DeleteMapping("/{cpf}")
    public ResponseEntity<Void> delete(@PathVariable String cpf) {
        service.deletePessoa(cpf);
        return ResponseEntity.noContent().build();
    }
}

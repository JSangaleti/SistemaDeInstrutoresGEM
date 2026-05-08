package com.gem.backend.controller;

import com.gem.backend.dto.PessoaResponseDTO;
import com.gem.backend.model.Pessoa;
import com.gem.backend.service.PessoaService;
import jakarta.validation.Valid;
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
    public ResponseEntity<PessoaResponseDTO> create(@Valid @RequestBody Pessoa pessoa) {
        Pessoa pessoaSalva = service.createPessoa(pessoa);
        PessoaResponseDTO response = new PessoaResponseDTO(pessoaSalva);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<PessoaResponseDTO>> getList() {
        List<PessoaResponseDTO> response = service.getListPessoa()
                .stream()
                .map(PessoaResponseDTO::new)
                .toList();

        return ResponseEntity.ok(response);
    }

    @GetMapping("/{cpf}")
    public ResponseEntity<PessoaResponseDTO> get(@PathVariable String cpf) {
        Pessoa pessoa = service.getPessoa(cpf);
        PessoaResponseDTO response = new PessoaResponseDTO(pessoa);

        return ResponseEntity.ok(response);
    }

    @PutMapping("/{cpf}")
    public ResponseEntity<PessoaResponseDTO> update(
            @PathVariable String cpf,
            @Valid @RequestBody Pessoa pessoa
    ) {
        Pessoa pessoaAtualizada = service.updatePessoa(cpf, pessoa);
        PessoaResponseDTO response = new PessoaResponseDTO(pessoaAtualizada);

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{cpf}")
    public ResponseEntity<Void> delete(@PathVariable String cpf) {
        service.deletePessoa(cpf);
        return ResponseEntity.noContent().build();
    }
}

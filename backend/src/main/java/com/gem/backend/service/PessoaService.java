/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.PessoaResponseDTO;
import com.gem.backend.model.Pessoa;
import com.gem.backend.repository.PessoaRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PessoaService {

    private final PessoaRepository repository;

    public PessoaService(PessoaRepository repository) {
        this.repository = repository;
    }

    public PessoaResponseDTO createPessoa(Pessoa pessoa) {
        Pessoa pessoaSalvo = repository.save(pessoa);
        return new PessoaResponseDTO(pessoaSalvo);
    }

    public List<PessoaResponseDTO> getListPessoa() {
        return repository.findAll().stream()
                .map(PessoaResponseDTO::new)
                .toList();
    }

    public PessoaResponseDTO getPessoa(String cpf) {
        Pessoa pessoa = repository.findById(cpf)
                .orElseThrow(() -> new RuntimeException("Pessoa não encontrado!"));
        return new PessoaResponseDTO(pessoa);
    }

    public PessoaResponseDTO updatePessoa(String cpf, Pessoa dadosAtualizados) {
        Pessoa pessoaExistente = repository.findById(cpf)
                .orElseThrow(() -> new RuntimeException("Pessoa não encontrado!"));

        pessoaExistente.setNome(dadosAtualizados.getNome());
        pessoaExistente.setComum(dadosAtualizados.getComum());

        return new PessoaResponseDTO(repository.save(pessoaExistente));
    }

    public void deletePessoa(String cpf) {
        repository.deleteById(cpf);
    }
}

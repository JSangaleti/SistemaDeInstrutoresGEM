/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
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

    public Pessoa createPessoa(Pessoa pessoa) {
        if (pessoa.getCpf() != null && repository.existsById(pessoa.getCpf())) {
            throw new DuplicateResourceException("Já existe uma pessoa cadastrada com este CPF.");
        }

        return repository.save(pessoa);
    }

    public List<Pessoa> getListPessoa() {
        return repository.findAll();
    }

    public Pessoa getPessoa(String cpf) {
        Pessoa pessoa = repository.findById(cpf)
                .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrado!"));
        return pessoa;
    }

    public Pessoa updatePessoa(String cpf, Pessoa dadosAtualizados) {
        Pessoa pessoaExistente = repository.findById(cpf)
                .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrado!"));

        pessoaExistente.setNome(dadosAtualizados.getNome());
        pessoaExistente.setComum(dadosAtualizados.getComum());

        return repository.save(pessoaExistente);
    }

    public void deletePessoa(String cpf) {
        if (!repository.existsById(cpf)) {
            throw new ResourceNotFoundException("Pessoa não encontrada.");
        }

        repository.deleteById(cpf);
    }
}

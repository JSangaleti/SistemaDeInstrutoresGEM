package com.gem.backend.service;

import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Comum;
import com.gem.backend.model.Pessoa;
import com.gem.backend.repository.ComumRepository;
import com.gem.backend.repository.PessoaRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PessoaService {

    private final PessoaRepository repository;
    private final ComumRepository comumRepository;

    public PessoaService(PessoaRepository repository, ComumRepository comumRepository) {
        this.repository = repository;
        this.comumRepository = comumRepository;
    }

    public Pessoa createPessoa(Pessoa pessoa) {
        if (pessoa.getCpf() != null && repository.existsById(pessoa.getCpf())) {
            throw new DuplicateResourceException("Já existe uma pessoa cadastrada com este CPF.");
        }

        if (pessoa.getComum() != null && pessoa.getComum().getId() != null) {
            Comum comum = comumRepository.findById(pessoa.getComum().getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Comum não encontrada."));

            pessoa.setComum(comum);
        }

        return repository.save(pessoa);
    }

    public List<Pessoa> getListPessoa() {
        return repository.findAll();
    }

    public Pessoa getPessoa(String cpf) {
        return repository.findById(cpf)
                .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));
    }

    public Pessoa updatePessoa(String cpf, Pessoa dadosAtualizados) {
        Pessoa pessoaExistente = repository.findById(cpf)
                .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));

        if (dadosAtualizados.getNome() != null && !dadosAtualizados.getNome().trim().isEmpty()) {
            pessoaExistente.setNome(dadosAtualizados.getNome());
        }

        if (dadosAtualizados.getComum() != null && dadosAtualizados.getComum().getId() != null) {
            Comum comum = comumRepository.findById(dadosAtualizados.getComum().getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Comum não encontrada."));

            pessoaExistente.setComum(comum);
        }

        return repository.save(pessoaExistente);
    }

    public void deletePessoa(String cpf) {
        if (!repository.existsById(cpf)) {
            throw new ResourceNotFoundException("Pessoa não encontrada.");
        }

        repository.deleteById(cpf);
    }
}

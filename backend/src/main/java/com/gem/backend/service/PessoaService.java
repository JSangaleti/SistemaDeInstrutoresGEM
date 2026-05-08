package com.gem.backend.service;

import com.gem.backend.dto.PessoaResponseDTO;
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

    public PessoaResponseDTO createPessoa(Pessoa pessoa) {
        if (pessoa.getComum() != null && pessoa.getComum().getId() != null) {
            Comum comum = comumRepository.findById(pessoa.getComum().getId())
                    .orElseThrow(() -> new RuntimeException("Comum não encontrada!"));

            pessoa.setComum(comum);
        }

        Pessoa pessoaSalva = repository.save(pessoa);
        return new PessoaResponseDTO(pessoaSalva);
    }

    public List<PessoaResponseDTO> getListPessoa() {
        return repository.findAll().stream()
                .map(PessoaResponseDTO::new)
                .toList();
    }

    public PessoaResponseDTO getPessoa(String cpf) {
        Pessoa pessoa = repository.findById(cpf)
                .orElseThrow(() -> new RuntimeException("Pessoa não encontrada!"));

        return new PessoaResponseDTO(pessoa);
    }

    public PessoaResponseDTO updatePessoa(String cpf, Pessoa dadosAtualizados) {
        Pessoa pessoaExistente = repository.findById(cpf)
                .orElseThrow(() -> new RuntimeException("Pessoa não encontrada!"));

        pessoaExistente.setNome(dadosAtualizados.getNome());

        if (dadosAtualizados.getComum() != null && dadosAtualizados.getComum().getId() != null) {
            Comum comum = comumRepository.findById(dadosAtualizados.getComum().getId())
                    .orElseThrow(() -> new RuntimeException("Comum não encontrada!"));

            pessoaExistente.setComum(comum);
        }

        Pessoa pessoaSalva = repository.save(pessoaExistente);
        return new PessoaResponseDTO(pessoaSalva);
    }

    public void deletePessoa(String cpf) {
        repository.deleteById(cpf);
    }
}
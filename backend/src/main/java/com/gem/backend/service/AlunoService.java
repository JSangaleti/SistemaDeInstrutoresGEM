package com.gem.backend.service;

import com.gem.backend.dto.AlunoResponseDTO;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.Comum;
import com.gem.backend.model.Pessoa;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.ComumRepository;
import com.gem.backend.repository.PessoaRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AlunoService {

    private final AlunoRepository repository;
    private final PessoaRepository pessoaRepository;
    private final ComumRepository comumRepository;

    public AlunoService(
            AlunoRepository repository,
            PessoaRepository pessoaRepository,
            ComumRepository comumRepository
    ) {
        this.repository = repository;
        this.pessoaRepository = pessoaRepository;
        this.comumRepository = comumRepository;
    }

    public AlunoResponseDTO createAluno(Aluno aluno) {
        if (aluno.getId() != null && repository.existsById(aluno.getId())) {
            throw new DuplicateResourceException("Já existe um aluno cadastrado com este ID.");
        }

        if (aluno.getPessoa() != null && aluno.getPessoa().getCpf() != null) {
            Pessoa pessoa = pessoaRepository.findById(aluno.getPessoa().getCpf())
                    .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));

            aluno.setPessoa(pessoa);
        }

        if (aluno.getComum() != null && aluno.getComum().getId() != null) {
            Comum comum = comumRepository.findById(aluno.getComum().getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Comum não encontrada."));

            aluno.setComum(comum);
        }

        Aluno alunoSalvo = repository.save(aluno);
        return new AlunoResponseDTO(alunoSalvo);
    }

    public List<AlunoResponseDTO> getListAluno() {
        return repository.findAll().stream()
                .map(AlunoResponseDTO::new)
                .toList();
    }

    public AlunoResponseDTO getAluno(Long id) {
        Aluno aluno = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));

        return new AlunoResponseDTO(aluno);
    }

    public AlunoResponseDTO updateAluno(Long id, Aluno dadosAtualizados) {
        Aluno alunoExistente = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));

        if (dadosAtualizados.getSenha() != null && !dadosAtualizados.getSenha().trim().isEmpty()) {
            alunoExistente.setSenha(dadosAtualizados.getSenha());
        }

        if (dadosAtualizados.getPessoa() != null && dadosAtualizados.getPessoa().getCpf() != null) {
            Pessoa pessoa = pessoaRepository.findById(dadosAtualizados.getPessoa().getCpf())
                    .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));

            alunoExistente.setPessoa(pessoa);
        }

        if (dadosAtualizados.getComum() != null && dadosAtualizados.getComum().getId() != null) {
            Comum comum = comumRepository.findById(dadosAtualizados.getComum().getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Comum não encontrada."));

            alunoExistente.setComum(comum);
        }

        return new AlunoResponseDTO(repository.save(alunoExistente));
    }

    public void deleteAluno(Long id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Aluno não encontrado.");
        }

        repository.deleteById(id);
    }
}

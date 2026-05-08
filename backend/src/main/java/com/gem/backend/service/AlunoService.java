/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.AlunoResponseDTO;
import com.gem.backend.model.Aluno;
import com.gem.backend.repository.AlunoRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AlunoService {

    private final AlunoRepository repository;

    public AlunoService(AlunoRepository repository) {
        this.repository = repository;
    }

    public AlunoResponseDTO createAluno(Aluno aluno) {
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
                .orElseThrow(() -> new RuntimeException("Aluno não encontrado!"));
        return new AlunoResponseDTO(aluno);
    }

    public AlunoResponseDTO updateAluno(Long id, Aluno dadosAtualizados) {
        Aluno alunoExistente = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Aluno não encontrado!"));

        alunoExistente.setSenha(dadosAtualizados.getSenha());
        alunoExistente.setPessoa(dadosAtualizados.getPessoa());
        alunoExistente.setComum(dadosAtualizados.getComum());

        return new AlunoResponseDTO(repository.save(alunoExistente));
    }

    public void deleteAluno(Long id) {
        repository.deleteById(id);
    }
}

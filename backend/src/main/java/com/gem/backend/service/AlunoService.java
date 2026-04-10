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

    public AlunoResponseDTO criarAluno(Aluno aluno) {
        Aluno alunoSalvo = repository.save(aluno);
        return new AlunoResponseDTO(alunoSalvo);
    }

    public List<AlunoResponseDTO> listarTodos() {
        return repository.findAll().stream()
                .map(AlunoResponseDTO::new)
                .toList();
    }

    public AlunoResponseDTO atualizar(Long id, Aluno dadosAtualizados) {
        Aluno alunoExistente = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Aluno não encontrado!"));
        
        alunoExistente.setSenha(dadosAtualizados.getSenha());
        alunoExistente.setCpfPessoa(dadosAtualizados.getCpfPessoa());
        
        return new AlunoResponseDTO(repository.save(alunoExistente));
    }

    public void deletar(Long id) {
        repository.deleteById(id);
    }
}

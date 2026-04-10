/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.dto;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Aluno;

public record AlunoResponseDTO(Long id, String cpfPessoa) {
    
    public AlunoResponseDTO(Aluno aluno) {
        this(aluno.getId(), aluno.getCpfPessoa());
    }
}

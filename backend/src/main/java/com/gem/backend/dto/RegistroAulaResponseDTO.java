/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.dto;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.RegistroAula;
import java.time.LocalDate;

public record RegistroAulaResponseDTO(Integer id, String descricao, String paraProximaAula, Short presente, LocalDate data, String alunoNome, String instrutorNome) {
    
    public RegistroAulaResponseDTO(RegistroAula aula) {
        this(
            aula.getId(),
            aula.getDescricao(),
            aula.getParaProximaAula(),
            aula.getPresente(),
            aula.getData(),
            (aula.getAluno() != null && aula.getAluno().getPessoa() != null) ? aula.getAluno().getPessoa().getNome() : null,
            (aula.getInstrutor() != null && aula.getInstrutor().getPessoa() != null) ? aula.getInstrutor().getPessoa().getNome() : null
        );
    }
}
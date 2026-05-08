/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.dto;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Instrutor;

public record InstrutorResponseDTO(Integer id, String nome, String cpf) {
    public InstrutorResponseDTO(Instrutor instrutor) {
        this(
            instrutor.getId(),
            instrutor.getPessoa() != null ? instrutor.getPessoa().getNome() : null,
            instrutor.getPessoa() != null ? instrutor.getPessoa().getCpf() : null
        );
    }
}

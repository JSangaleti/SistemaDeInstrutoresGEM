/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.dto;

/**
 *
 * @author leonardo
 */
import com.gem.backend.model.Pessoa;

public record PessoaResponseDTO(String cpf, String nome, String comum) {

    public PessoaResponseDTO(Pessoa pessoa) {
        this(
                pessoa.getCpf(),
                pessoa.getNome(),
                pessoa.getComum() != null ? pessoa.getComum().getNome() : ""
        );
    }
}

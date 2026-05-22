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

public record InstrutorResponseDTO(
        Integer id,
        String nome,
        String cpf,
        String comumNome,
        String comumCidade,
        String comumUF
        ) {

    public InstrutorResponseDTO(Instrutor instrutor) {
        this(
                instrutor.getId(),
                instrutor.getPessoa() != null ? instrutor.getPessoa().getNome() : null,
                instrutor.getPessoa() != null ? instrutor.getPessoa().getCpf() : null,
                instrutor.getPessoa().getComum() != null ? instrutor.getPessoa().getComum().getNome() : "",
                instrutor.getPessoa().getComum() != null ? instrutor.getPessoa().getComum().getCidade() : "",
                instrutor.getPessoa().getComum() != null ? instrutor.getPessoa().getComum().getEstado() : ""
        );
    }
}

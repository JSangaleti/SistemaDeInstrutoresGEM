/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.dto;

/**
 *
 * @author leonardo
 */
import com.gem.backend.model.Comum;

public record ComumResponseDTO(Integer id, String nome, String cidade, String estado, String bairro) {

    public ComumResponseDTO(Comum comum) {
        this(
                comum.getId(),
                comum.getNome(),
                comum.getCidade(),
                comum.getEstado(),
                comum.getBairro()
        );
    }
}

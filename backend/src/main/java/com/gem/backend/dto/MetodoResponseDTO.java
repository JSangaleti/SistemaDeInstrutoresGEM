/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.dto;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Metodo;

public record MetodoResponseDTO(Integer id, String nome, Integer instrumentoId, String instrumentoNome) {
    public MetodoResponseDTO(Metodo metodo) {
        this(
            metodo.getId(), 
            metodo.getNome(),
            metodo.getInstrumento() != null ? metodo.getInstrumento().getId() : null,
            metodo.getInstrumento() != null ? metodo.getInstrumento().getNome() : null
        );
    }
}
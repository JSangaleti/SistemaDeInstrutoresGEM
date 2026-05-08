/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.dto;

/**
 *
 * @author leonardo
 */
import com.gem.backend.model.Instrumento;

public record InstrumentoResponseDTO(Integer id, String nome) {

    public InstrumentoResponseDTO(Instrumento instrumento) {
        this(instrumento.getId(), instrumento.getNome());
    }
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.dto;

import com.gem.backend.enums.Perfil;

/**
 *
 * @author leonardo
 */

public record LoginResponseDTO(
    String token,
    Perfil perfil,
    Long usuarioId,
    String nome,
    String cpf
) {}

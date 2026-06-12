/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.dto;

/**
 *
 * @author leonardo
 */
import com.gem.backend.enums.Perfil;

public record LoginRequestDTO(
    String cpf,
    String senha,
    Perfil perfil
) {}

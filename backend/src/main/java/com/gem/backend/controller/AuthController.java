/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */

import com.gem.backend.dto.AlterarSenhaRequestDTO;
import com.gem.backend.dto.AdminAlterarSenhaRequestDTO;
import com.gem.backend.dto.LoginRequestDTO;
import com.gem.backend.dto.LoginResponseDTO;
import com.gem.backend.enums.Perfil;
import jakarta.validation.Valid;
import com.gem.backend.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login(@RequestBody LoginRequestDTO dto) {
        try {
            LoginResponseDTO response = authService.login(dto);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PutMapping("/senha")
    public ResponseEntity<Void> alterarSenha(
            Authentication authentication,
            @Valid @RequestBody AlterarSenhaRequestDTO dto
    ) {
        String role = authentication.getAuthorities().stream()
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Perfil inválido"))
                .getAuthority()
                .replace("ROLE_", "");

        authService.alterarSenha(authentication.getName(), Perfil.valueOf(role), dto);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/admin/senha")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> alterarSenhaComoAdmin(
            @Valid @RequestBody AdminAlterarSenhaRequestDTO dto
    ) {
        authService.alterarSenhaComoAdmin(dto);
        return ResponseEntity.noContent().build();
    }
}

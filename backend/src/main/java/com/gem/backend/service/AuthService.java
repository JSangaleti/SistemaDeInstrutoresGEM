/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */

import com.gem.backend.dto.LoginRequestDTO;
import com.gem.backend.dto.LoginResponseDTO;
import com.gem.backend.repository.AdminRepository;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.InstrutorRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final AlunoRepository alunoRepository;
    private final InstrutorRepository instrutorRepository;
    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;

    public AuthService(AlunoRepository alunoRepository, 
                       InstrutorRepository instrutorRepository,
                       AdminRepository adminRepository, 
                       PasswordEncoder passwordEncoder, 
                       TokenService tokenService) {
        this.alunoRepository = alunoRepository;
        this.instrutorRepository = instrutorRepository;
        this.adminRepository = adminRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenService = tokenService;
    }

    public LoginResponseDTO login(LoginRequestDTO dto) {
        String hashBanco;

        switch (dto.perfil()) {
            case ALUNO -> {
                var aluno = alunoRepository.findByPessoa_Cpf(dto.cpf())
                        .orElseThrow(() -> new RuntimeException("Credenciais inválidas"));
                hashBanco = aluno.getSenha();
            }
            case INSTRUTOR -> {
                var instrutor = instrutorRepository.findByPessoa_Cpf(dto.cpf())
                        .orElseThrow(() -> new RuntimeException("Credenciais inválidas"));
                hashBanco = instrutor.getSenha();
            }
            case ADMIN -> {
                var admin = adminRepository.findByPessoa_Cpf(dto.cpf())
                        .orElseThrow(() -> new RuntimeException("Credenciais inválidas"));
                hashBanco = admin.getSenha();
            }
            default -> throw new RuntimeException("Perfil inválido");
        }

        if (!passwordEncoder.matches(dto.senha(), hashBanco)) {
            throw new RuntimeException("Credenciais inválidas");
        }

        String token = tokenService.gerarToken(dto.cpf(), dto.perfil());
        return new LoginResponseDTO(token);
    }
}
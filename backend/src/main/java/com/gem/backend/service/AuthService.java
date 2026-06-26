/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */

import com.gem.backend.dto.AlterarSenhaRequestDTO;
import com.gem.backend.dto.AdminAlterarSenhaRequestDTO;
import com.gem.backend.dto.LoginRequestDTO;
import com.gem.backend.dto.LoginResponseDTO;
import com.gem.backend.enums.Perfil;
import com.gem.backend.exception.BadRequestException;
import com.gem.backend.exception.ResourceNotFoundException;
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
        Long usuarioId;
        String nome;
        String cpf;

        switch (dto.perfil()) {
            case ALUNO -> {
                var aluno = alunoRepository.findByPessoa_Cpf(dto.cpf())
                        .orElseThrow(() -> new RuntimeException("Credenciais inválidas"));
                hashBanco = aluno.getSenha();
                usuarioId = aluno.getId();
                nome = aluno.getPessoa().getNome();
                cpf = aluno.getPessoa().getCpf();
            }
            case INSTRUTOR -> {
                var instrutor = instrutorRepository.findByPessoa_Cpf(dto.cpf())
                        .orElseThrow(() -> new RuntimeException("Credenciais inválidas"));
                hashBanco = instrutor.getSenha();
                usuarioId = instrutor.getId().longValue();
                nome = instrutor.getPessoa().getNome();
                cpf = instrutor.getPessoa().getCpf();
            }
            case ADMIN -> {
                var admin = adminRepository.findByPessoa_Cpf(dto.cpf())
                        .orElseThrow(() -> new RuntimeException("Credenciais inválidas"));
                hashBanco = admin.getSenha();
                usuarioId = admin.getId().longValue();
                nome = admin.getPessoa().getNome();
                cpf = admin.getPessoa().getCpf();
            }
            default -> throw new RuntimeException("Perfil inválido");
        }

        if (!passwordEncoder.matches(dto.senha(), hashBanco)) {
            throw new RuntimeException("Credenciais inválidas");
        }

        String token = tokenService.gerarToken(dto.cpf(), dto.perfil());
        Perfil perfil = dto.perfil();
        return new LoginResponseDTO(token, perfil, usuarioId, nome, cpf);
    }

    public void alterarSenha(String cpf, Perfil perfil, AlterarSenhaRequestDTO dto) {
        if (!dto.novaSenha().equals(dto.confirmacaoNovaSenha())) {
            throw new BadRequestException("A confirmação da nova senha não confere.");
        }

        switch (perfil) {
            case ALUNO -> {
                var aluno = alunoRepository.findByPessoa_Cpf(cpf)
                        .orElseThrow(() -> new BadRequestException("Usuário não encontrado."));
                validarSenhaAntiga(dto.senhaAntiga(), aluno.getSenha());
                aluno.setSenha(passwordEncoder.encode(dto.novaSenha()));
                alunoRepository.save(aluno);
            }
            case INSTRUTOR -> {
                var instrutor = instrutorRepository.findByPessoa_Cpf(cpf)
                        .orElseThrow(() -> new BadRequestException("Usuário não encontrado."));
                validarSenhaAntiga(dto.senhaAntiga(), instrutor.getSenha());
                instrutor.setSenha(passwordEncoder.encode(dto.novaSenha()));
                instrutorRepository.save(instrutor);
            }
            case ADMIN -> {
                var admin = adminRepository.findByPessoa_Cpf(cpf)
                        .orElseThrow(() -> new BadRequestException("Usuário não encontrado."));
                validarSenhaAntiga(dto.senhaAntiga(), admin.getSenha());
                admin.setSenha(passwordEncoder.encode(dto.novaSenha()));
                adminRepository.save(admin);
            }
            default -> throw new BadRequestException("Perfil inválido.");
        }
    }

    private void validarSenhaAntiga(String senhaAntiga, String hashBanco) {
        if (!passwordEncoder.matches(senhaAntiga, hashBanco)) {
            throw new BadRequestException("Senha antiga incorreta.");
        }
    }

    public void alterarSenhaComoAdmin(AdminAlterarSenhaRequestDTO dto) {
        if (!dto.novaSenha().equals(dto.confirmacaoNovaSenha())) {
            throw new BadRequestException("A confirmação da nova senha não confere.");
        }

        String senhaCriptografada = passwordEncoder.encode(dto.novaSenha());

        switch (dto.perfil()) {
            case ALUNO -> {
                var aluno = alunoRepository.findById(dto.usuarioId())
                        .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));
                aluno.setSenha(senhaCriptografada);
                alunoRepository.save(aluno);
            }
            case INSTRUTOR -> {
                var instrutor = instrutorRepository.findById(toIntegerId(dto.usuarioId()))
                        .orElseThrow(() -> new ResourceNotFoundException("Instrutor não encontrado."));
                instrutor.setSenha(senhaCriptografada);
                instrutorRepository.save(instrutor);
            }
            case ADMIN -> {
                var admin = adminRepository.findById(toIntegerId(dto.usuarioId()))
                        .orElseThrow(() -> new ResourceNotFoundException("Admin não encontrado."));
                admin.setSenha(senhaCriptografada);
                adminRepository.save(admin);
            }
            default -> throw new BadRequestException("Perfil inválido.");
        }
    }

    private Integer toIntegerId(Long usuarioId) {
        try {
            return Math.toIntExact(usuarioId);
        } catch (ArithmeticException ex) {
            throw new BadRequestException("ID do usuário é inválido.");
        }
    }
}

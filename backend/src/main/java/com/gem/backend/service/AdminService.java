package com.gem.backend.service;

import com.gem.backend.dto.AdminResponseDTO;
import com.gem.backend.exception.BadRequestException;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Admin;
import com.gem.backend.model.Pessoa;
import com.gem.backend.repository.AdminRepository;
import com.gem.backend.repository.PessoaRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AdminService {

    private final AdminRepository repository;
    private final PessoaRepository pessoaRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminService(AdminRepository repository, PessoaRepository pessoaRepository, PasswordEncoder passwordEncoder) {
        this.repository = repository;
        this.pessoaRepository = pessoaRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public AdminResponseDTO createAdmin(Admin admin) {
        if (admin.getId() != null && repository.existsById(admin.getId())) {
            throw new DuplicateResourceException("Já existe um admin cadastrado com este ID.");
        }

        Pessoa pessoa = buscarPessoaObrigatoria(admin);

        if (repository.existsByPessoa_Cpf(pessoa.getCpf())) {
            throw new DuplicateResourceException("Já existe um admin cadastrado para este CPF.");
        }

        admin.setPessoa(pessoa);
        admin.setSenha(passwordEncoder.encode(admin.getSenha()));

        Admin adminSalvo = repository.save(admin);
        return new AdminResponseDTO(adminSalvo);
    }

    public List<AdminResponseDTO> getListAdmin() {
        return repository.findAll()
                .stream()
                .map(AdminResponseDTO::new)
                .toList();
    }

    public AdminResponseDTO getAdmin(Integer id) {
        Admin admin = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Admin não encontrado."));

        return new AdminResponseDTO(admin);
    }

    public AdminResponseDTO updateAdmin(Integer id, Admin dadosAtualizados) {
        Admin adminExistente = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Admin não encontrado."));

        if (dadosAtualizados.getSenha() != null && !dadosAtualizados.getSenha().trim().isEmpty()) {
            adminExistente.setSenha(passwordEncoder.encode(dadosAtualizados.getSenha()));
        }

        if (dadosAtualizados.getPessoa() != null && dadosAtualizados.getPessoa().getCpf() != null) {
            Pessoa pessoa = buscarPessoaObrigatoria(dadosAtualizados);

            boolean cpfMudou = !pessoa.getCpf().equals(adminExistente.getPessoa().getCpf());

            if (cpfMudou && repository.existsByPessoa_Cpf(pessoa.getCpf())) {
                throw new DuplicateResourceException("Já existe um admin cadastrado para este CPF.");
            }

            adminExistente.setPessoa(pessoa);
        }

        return new AdminResponseDTO(repository.save(adminExistente));
    }

    public void deleteAdmin(Integer id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Admin não encontrado.");
        }

        repository.deleteById(id);
    }

    private Pessoa buscarPessoaObrigatoria(Admin admin) {
        if (admin.getPessoa() == null
                || admin.getPessoa().getCpf() == null
                || admin.getPessoa().getCpf().trim().isEmpty()) {
            throw new BadRequestException("Informe o CPF da pessoa vinculada ao admin.");
        }

        return pessoaRepository.findById(admin.getPessoa().getCpf())
                .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));
    }
}
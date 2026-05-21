package com.gem.backend.service;

import com.gem.backend.dto.AdminResponseDTO;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Admin;
import com.gem.backend.model.Pessoa;
import com.gem.backend.repository.AdminRepository;
import com.gem.backend.repository.PessoaRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AdminService {

    private final AdminRepository repository;
    private final PessoaRepository pessoaRepository;

    public AdminService(AdminRepository repository, PessoaRepository pessoaRepository) {
        this.repository = repository;
        this.pessoaRepository = pessoaRepository;
    }

    public AdminResponseDTO createAdmin(Admin admin) {
        if (admin.getId() != null && repository.existsById(admin.getId())) {
            throw new DuplicateResourceException("Já existe um admin cadastrado com este ID.");
        }

        if (admin.getPessoa() != null && admin.getPessoa().getCpf() != null) {
            Pessoa pessoa = pessoaRepository.findById(admin.getPessoa().getCpf())
                    .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));

            admin.setPessoa(pessoa);
        }

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
            adminExistente.setSenha(dadosAtualizados.getSenha());
        }

        if (dadosAtualizados.getPessoa() != null && dadosAtualizados.getPessoa().getCpf() != null) {
            Pessoa pessoa = pessoaRepository.findById(dadosAtualizados.getPessoa().getCpf())
                    .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));

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
}

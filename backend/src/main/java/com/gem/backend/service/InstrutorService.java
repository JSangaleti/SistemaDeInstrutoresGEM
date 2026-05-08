/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.InstrutorResponseDTO;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Instrutor;
import com.gem.backend.repository.InstrutorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class InstrutorService {

    @Autowired
    private InstrutorRepository repository;

    public InstrutorResponseDTO createInstrutor(Instrutor instrutor) {
        if (repository.existsById(instrutor.getId())) {
            throw new DuplicateResourceException("Já existe um instrutor cadastrado com este ID.");
        }

        Instrutor instrutorSalvo = repository.save(instrutor);
        return new InstrutorResponseDTO(instrutorSalvo);
    }

    public List<Instrutor> getListInstrutor() {
        return repository.findAll();
    }

    public Instrutor getInstrutor(Integer id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Instrutor não encontrado!"));
    }

    public Instrutor updateInstrutor(Integer id, Instrutor dadosAtualizados) {
        Instrutor existente = getInstrutor(id);

        if (dadosAtualizados.getSenha() != null && !dadosAtualizados.getSenha().trim().isEmpty()) {
            existente.setSenha(dadosAtualizados.getSenha());
        }

        if (dadosAtualizados.getPessoa() != null && dadosAtualizados.getPessoa().getCpf() != null) {
            existente.setPessoa(dadosAtualizados.getPessoa());
        }

        return repository.save(existente);
    }

    public void deleteInstrutor(Integer id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Instrutor não encontrado.");
        }

        repository.deleteById(id);
    }
}

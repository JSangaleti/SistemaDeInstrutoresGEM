/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.ComumResponseDTO;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Comum;
import com.gem.backend.repository.ComumRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ComumService {

    private final ComumRepository repository;

    public ComumService(ComumRepository repository) {
        this.repository = repository;
    }

    public ComumResponseDTO createComum(Comum comum) {
        if (repository.existsById(comum.getId())) {
            throw new DuplicateResourceException("Já existe uma comum cadastrada com este ID.");
        }

        Comum comumSalvo = repository.save(comum);
        return new ComumResponseDTO(comumSalvo);
    }

    public List<ComumResponseDTO> getListComum() {
        return repository.findAll().stream()
                .map(ComumResponseDTO::new)
                .toList();
    }

    public ComumResponseDTO getComum(Integer id) {
        Comum comum = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Comum não encontrado!"));
        return new ComumResponseDTO(comum);
    }

    public ComumResponseDTO updateComum(Integer id, Comum dadosAtualizados) {
        Comum comumExistente = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Comum não encontrado!"));

        comumExistente.setNome(dadosAtualizados.getNome());
        comumExistente.setCidade(dadosAtualizados.getCidade());
        comumExistente.setEstado(dadosAtualizados.getEstado());
        comumExistente.setBairro(dadosAtualizados.getBairro());
        comumExistente.setLogradouro(dadosAtualizados.getLogradouro());
        comumExistente.setNumero(dadosAtualizados.getNumero());

        return new ComumResponseDTO(repository.save(comumExistente));
    }

    public void deleteComum(Integer id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Comum não encontrada.");
        }

        repository.deleteById(id);
    }
}

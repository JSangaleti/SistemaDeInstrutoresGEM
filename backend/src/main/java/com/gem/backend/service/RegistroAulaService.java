/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.RegistroAula;
import com.gem.backend.repository.RegistroAulaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;

@Service
public class RegistroAulaService {

    @Autowired
    private RegistroAulaRepository repository;

    public RegistroAula createRegistroAula(RegistroAula aula) {
        if (repository.existsById(aula.getId())) {
            throw new DuplicateResourceException("Já existe uma aula cadastrada com este ID.");
        }

        if (aula.getData() == null) {
            aula.setData(LocalDate.now());
        }

        return repository.save(aula);
    }

    public List<RegistroAula> getListRegistroAula() {
        return repository.findAll();
    }

    public RegistroAula getRegistroAula(Integer id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Registro de aula não encontrado!"));
    }

    public RegistroAula updateRegistroAula(Integer id, RegistroAula dadosAtualizados) {
        RegistroAula existente = getRegistroAula(id);

        if (dadosAtualizados.getAluno() != null && dadosAtualizados.getAluno().getId() != null) {
            existente.setAluno(dadosAtualizados.getAluno());
        }
        if (dadosAtualizados.getInstrutor() != null && dadosAtualizados.getInstrutor().getId() != null) {
            existente.setInstrutor(dadosAtualizados.getInstrutor());
        }

        if (dadosAtualizados.getDescricao() != null) {
            existente.setDescricao(dadosAtualizados.getDescricao());
        }
        if (dadosAtualizados.getParaProximaAula() != null) {
            existente.setParaProximaAula(dadosAtualizados.getParaProximaAula());
        }
        if (dadosAtualizados.getPresente() != null) {
            existente.setPresente(dadosAtualizados.getPresente());
        }
        if (dadosAtualizados.getData() != null) {
            existente.setData(dadosAtualizados.getData());
        }

        return repository.save(existente);
    }

    public void deleteRegistroAula(Integer id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Registro de aula não encontrada.");
        }

        repository.deleteById(id);
    }
}

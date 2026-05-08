/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Metodo;
import com.gem.backend.repository.MetodoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class MetodoService {

    @Autowired
    private MetodoRepository repository;

    public Metodo createMetodo(Metodo metodo) {
        return repository.save(metodo);
    }

    public List<Metodo> getListMetodo() {
        return repository.findAll();
    }

    public Metodo getMetodo(Integer id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Método não encontrado!"));
    }

    public Metodo updateMetodo(Integer id, Metodo dadosAtualizados) {
        Metodo existente = getMetodo(id);
        
        if (dadosAtualizados.getNome() != null && !dadosAtualizados.getNome().isBlank()) {
            existente.setNome(dadosAtualizados.getNome());
        }
        
        if (dadosAtualizados.getInstrumento() != null && dadosAtualizados.getInstrumento().getId() != null) {
            existente.setInstrumento(dadosAtualizados.getInstrumento());
        }
        if (dadosAtualizados.getAluno() != null && dadosAtualizados.getAluno().getId() != null) {
            existente.setAluno(dadosAtualizados.getAluno());
        }
        
        return repository.save(existente);
    }

    public void deleteMetodo(Integer id) {
        repository.deleteById(id);
    }
}

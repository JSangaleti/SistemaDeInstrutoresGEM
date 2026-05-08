/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Instrutor;
import com.gem.backend.repository.InstrutorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class InstrutorService {

    @Autowired
    private InstrutorRepository repository;

    public Instrutor createInstrutor(Instrutor instrutor) {
        return repository.save(instrutor);
    }

    public List<Instrutor> getListInstrutor() {
        return repository.findAll();
    }

    public Instrutor getInstrutor(Integer id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Instrutor não encontrado!"));
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
        repository.deleteById(id);
    }
}

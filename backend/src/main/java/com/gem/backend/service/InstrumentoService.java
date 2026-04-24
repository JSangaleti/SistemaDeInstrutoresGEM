/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Instrumento;
import com.gem.backend.repository.InstrumentoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class InstrumentoService {

    @Autowired
    private InstrumentoRepository repository;

    public Instrumento createInstrumento(Instrumento instrumento) {
        return repository.save(instrumento);
    }

    public List<Instrumento> getListInstrumento() {
        return repository.findAll();
    }

    public Instrumento getInstrumento(Integer id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Instrumento não encontrado!"));
    }

    public Instrumento updateInstrumento(Integer id, Instrumento dadosAtualizados) {
        Instrumento existente = getInstrumento(id);
        
        if (dadosAtualizados.getNome() != null && !dadosAtualizados.getNome().isBlank()) {
            existente.setNome(dadosAtualizados.getNome());
        }
        
        return repository.save(existente);
    }

    public void deleteInstrumento(Integer id) {
        repository.deleteById(id);
    }
}

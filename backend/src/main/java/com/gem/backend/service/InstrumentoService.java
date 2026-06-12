/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.service;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.InstrumentoResponseDTO;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Instrumento;
import com.gem.backend.repository.InstrumentoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class InstrumentoService {

    @Autowired
    private InstrumentoRepository repository;

    public InstrumentoResponseDTO createInstrumento(Instrumento instrumento) {
        if (instrumento.getId() != null && repository.existsById(instrumento.getId())) {
            throw new DuplicateResourceException("Já existe um instrumento cadastrado com este ID.");
        }
        return new InstrumentoResponseDTO(repository.save(instrumento));
    }

    public List<InstrumentoResponseDTO> getListInstrumento() {
        return repository.findAll().stream().map(InstrumentoResponseDTO::new).toList();
    }

    public InstrumentoResponseDTO getInstrumento(Integer id) {
        Instrumento instrumento = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Instrumento não encontrado."));
        return new InstrumentoResponseDTO(instrumento);
    }

    public InstrumentoResponseDTO updateInstrumento(Integer id, Instrumento dadosAtualizados) {
        Instrumento existente = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Instrumento não encontrado."));

        if (dadosAtualizados.getNome() != null && !dadosAtualizados.getNome().isBlank()) {
            existente.setNome(dadosAtualizados.getNome());
        }
        return new InstrumentoResponseDTO(repository.save(existente));
    }

    public void deleteInstrumento(Integer id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Instrumento não encontrado.");
        }
        repository.deleteById(id);
    }
}
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.InstrumentoResponseDTO;
import com.gem.backend.model.Instrumento;
import com.gem.backend.service.InstrumentoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/instrumentos")
public class InstrumentoController {

    @Autowired
    private InstrumentoService service;

    @PostMapping
    public InstrumentoResponseDTO create(@Valid @RequestBody Instrumento instrumento) {
        return new InstrumentoResponseDTO(service.createInstrumento(instrumento));
    }

    @GetMapping
    public List<InstrumentoResponseDTO> getList() {
        return service.getListInstrumento().stream().map(InstrumentoResponseDTO::new).toList();
    }

    @GetMapping("/{id}")
    public InstrumentoResponseDTO getById(@PathVariable Integer id) {
        return new InstrumentoResponseDTO(service.getInstrumento(id));
    }

    @PutMapping("/{id}")
    public InstrumentoResponseDTO update(@PathVariable Integer id, @RequestBody Instrumento instrumento) {
        return new InstrumentoResponseDTO(service.updateInstrumento(id, instrumento));
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteInstrumento(id);
    }
}

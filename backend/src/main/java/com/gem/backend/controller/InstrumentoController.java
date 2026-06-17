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
import org.springframework.web.bind.annotation.*;
import java.util.List;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/instrumentos")
public class InstrumentoController {

    private final InstrumentoService service;

    public InstrumentoController(InstrumentoService service) {
        this.service = service;
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @PostMapping
    public InstrumentoResponseDTO create(@Valid @RequestBody Instrumento instrumento) {
        return service.createInstrumento(instrumento);
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR', 'ROLE_ALUNO')")
    @GetMapping
    public List<InstrumentoResponseDTO> getList() {
        return service.getListInstrumento();
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR', 'ROLE_ALUNO')")
    @GetMapping("/{id}")
    public InstrumentoResponseDTO getById(@PathVariable Integer id) {
        return service.getInstrumento(id);
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @PutMapping("/{id}")
    public InstrumentoResponseDTO update(@PathVariable Integer id, @RequestBody Instrumento instrumento) {
        return service.updateInstrumento(id, instrumento);
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteInstrumento(id);
    }
}
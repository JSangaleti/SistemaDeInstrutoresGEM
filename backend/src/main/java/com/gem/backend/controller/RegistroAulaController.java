/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.RegistroAulaResponseDTO;
import com.gem.backend.model.RegistroAula;
import com.gem.backend.service.RegistroAulaService;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/registro-aulas")
public class RegistroAulaController {

    private final RegistroAulaService service;

    public RegistroAulaController(RegistroAulaService service) {
        this.service = service;
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @PostMapping
    public RegistroAulaResponseDTO create(@Valid @RequestBody RegistroAula aula) {
        return service.createRegistroAula(aula);
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @GetMapping
    public List<RegistroAulaResponseDTO> getList() {
        return service.getListRegistroAula();
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR', 'ROLE_ALUNO')")
    @GetMapping("/{id}")
    public RegistroAulaResponseDTO getById(@PathVariable Integer id) {
        return service.getRegistroAula(id);
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @PutMapping("/{id}")
    public RegistroAulaResponseDTO update(@PathVariable Integer id, @RequestBody RegistroAula aula) {
        return service.updateRegistroAula(id, aula);
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteRegistroAula(id);
    }
}
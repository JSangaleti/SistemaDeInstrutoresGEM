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
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/registro-aulas")
public class RegistroAulaController {

    private final RegistroAulaService service;

    public RegistroAulaController(RegistroAulaService service) {
        this.service = service;
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','INSTRUTOR')")
    public RegistroAulaResponseDTO create(
            @Valid @RequestBody RegistroAula aula,
            Authentication authentication
    ) {
        return service.createRegistroAula(aula, authentication);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','INSTRUTOR')")
    public List<RegistroAulaResponseDTO> getList() {
        return service.getListRegistroAula();
    }

    @GetMapping("/meu-historico")
    @PreAuthorize("hasRole('ALUNO')")
    public List<RegistroAulaResponseDTO> getMeuHistorico(Authentication authentication) {
        return service.getHistoricoDoAlunoAutenticado(authentication.getName());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','INSTRUTOR','ALUNO')")
    public RegistroAulaResponseDTO getById(@PathVariable Integer id) {
        return service.getRegistroAula(id);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','INSTRUTOR')")
    public RegistroAulaResponseDTO update(
            @PathVariable Integer id,
            @Valid @RequestBody RegistroAula aula,
            Authentication authentication
    ) {
        return service.updateRegistroAula(id, aula, authentication);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void delete(@PathVariable Integer id) {
        service.deleteRegistroAula(id);
    }
}

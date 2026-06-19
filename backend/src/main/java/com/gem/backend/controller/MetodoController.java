package com.gem.backend.controller;

import com.gem.backend.dto.MetodoResponseDTO;
import com.gem.backend.model.Metodo;
import com.gem.backend.service.MetodoService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/metodos")
@PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR')")
public class MetodoController {

    private final MetodoService service;

    public MetodoController(MetodoService service) {
        this.service = service;
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @PostMapping
    public MetodoResponseDTO create(@Valid @RequestBody Metodo metodo) {
        return service.createMetodo(metodo);
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR', 'ROLE_ALUNO')")
    @GetMapping
    public List<MetodoResponseDTO> getList() {
        return service.getListMetodo();
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN', 'ROLE_INSTRUTOR', 'ROLE_ALUNO')")
    @GetMapping("/{id}")
    public MetodoResponseDTO getById(@PathVariable Integer id) {
        return service.getMetodo(id);
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @PutMapping("/{id}")
    public MetodoResponseDTO update(@PathVariable Integer id, @Valid @RequestBody Metodo metodo) {
        return service.updateMetodo(id, metodo);
    }

    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteMetodo(id);
    }
}

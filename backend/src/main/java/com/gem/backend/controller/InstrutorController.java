/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */
import com.gem.backend.dto.InstrutorResponseDTO;
import com.gem.backend.model.Instrutor;
import com.gem.backend.service.InstrutorService;
import com.gem.backend.validation.ValidationGroups;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;

@RestController
@RequestMapping("/instrutores")
public class InstrutorController {

    private final InstrutorService service;

    public InstrutorController(InstrutorService service) {
        this.service = service;
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public InstrutorResponseDTO create(
            @Validated(ValidationGroups.Create.class) @RequestBody Instrutor instrutor
    ) {
        return service.createInstrutor(instrutor);
    }

    @GetMapping
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public List<InstrutorResponseDTO> getList() {
        return service.getListInstrutor();
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('INSTRUTOR')")
    public InstrutorResponseDTO getMe(Authentication authentication) {
        return service.getInstrutorPorCpf(authentication.getName());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public InstrutorResponseDTO getById(@PathVariable Integer id) {
        return service.getInstrutor(id);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public InstrutorResponseDTO update(@PathVariable Integer id, @Valid @RequestBody Instrutor instrutor) {
        return service.updateInstrutor(id, instrutor);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public void delete(@PathVariable Integer id) {
        service.deleteInstrutor(id);
    }
}

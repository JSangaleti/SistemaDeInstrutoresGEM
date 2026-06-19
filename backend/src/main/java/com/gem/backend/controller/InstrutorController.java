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
import org.springframework.validation.annotation.Validated;

@RestController
@RequestMapping("/instrutores")
@PreAuthorize("hasAuthority('ROLE_ADMIN')")
public class InstrutorController {

    private final InstrutorService service;

    public InstrutorController(InstrutorService service) {
        this.service = service;
    }

    @PostMapping
    public InstrutorResponseDTO create(
            @Validated(ValidationGroups.Create.class) @RequestBody Instrutor instrutor
    ) {
        return service.createInstrutor(instrutor);
    }

    @GetMapping
    public List<InstrutorResponseDTO> getList() {
        return service.getListInstrutor();
    }

    @GetMapping("/{id}")
    public InstrutorResponseDTO getById(@PathVariable Integer id) {
        return service.getInstrutor(id);
    }

    @PutMapping("/{id}")
    public InstrutorResponseDTO update(@PathVariable Integer id, @Valid @RequestBody Instrutor instrutor) {
        return service.updateInstrutor(id, instrutor);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteInstrutor(id);
    }
}

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
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/instrutores")
public class InstrutorController {

    private final InstrutorService service;

    public InstrutorController(InstrutorService service) {
        this.service = service;
    }

    @PostMapping
    public InstrutorResponseDTO create(@Valid @RequestBody Instrutor instrutor) {
        return new InstrutorResponseDTO(service.createInstrutor(instrutor));
    }

    @GetMapping
    public List<InstrutorResponseDTO> getList() {
        return service.getListInstrutor().stream().map(InstrutorResponseDTO::new).toList();
    }

    @GetMapping("/{id}")
    public InstrutorResponseDTO getById(@PathVariable Integer id) {
        return new InstrutorResponseDTO(service.getInstrutor(id));
    }

    @PutMapping("/{id}")
    public InstrutorResponseDTO update(@PathVariable Integer id, @RequestBody Instrutor instrutor) {
        return new InstrutorResponseDTO(service.updateInstrutor(id, instrutor));
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteInstrutor(id);
    }
}
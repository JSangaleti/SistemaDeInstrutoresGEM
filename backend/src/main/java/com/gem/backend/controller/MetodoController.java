/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */

import com.gem.backend.dto.MetodoResponseDTO;
import com.gem.backend.model.Metodo;
import com.gem.backend.service.MetodoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/metodos") 
public class MetodoController {

    @Autowired
    private MetodoService service;

    @PostMapping
    public MetodoResponseDTO create(@RequestBody Metodo metodo) {
        return new MetodoResponseDTO(service.createMetodo(metodo));
    }

    @GetMapping
    public List<MetodoResponseDTO> getList() {
        return service.getListMetodo().stream().map(MetodoResponseDTO::new).toList();
    }

    @GetMapping("/{id}")
    public MetodoResponseDTO getById(@PathVariable Integer id) {
        return new MetodoResponseDTO(service.getMetodo(id));
    }

    @PutMapping("/{id}")
    public MetodoResponseDTO update(@PathVariable Integer id, @RequestBody Metodo metodo) {
        return new MetodoResponseDTO(service.updateMetodo(id, metodo));
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteMetodo(id);
    }
}
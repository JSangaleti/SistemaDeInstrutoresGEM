/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */

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
    public Metodo create(@RequestBody Metodo metodo) {
        return service.createMetodo(metodo);
    }

    @GetMapping
    public List<Metodo> getList() {
        return service.getListMetodo();
    }

    @GetMapping("/{id}")
    public Metodo getById(@PathVariable Integer id) {
        return service.getMetodo(id);
    }

    @PutMapping("/{id}")
    public Metodo update(@PathVariable Integer id, @RequestBody Metodo metodo) {
        return service.updateMetodo(id, metodo);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteMetodo(id);
    }
}
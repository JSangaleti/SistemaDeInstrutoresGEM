/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.RegistroAula;
import com.gem.backend.service.RegistroAulaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/registro-aulas")
public class RegistroAulaController {

    @Autowired
    private RegistroAulaService service;

    @PostMapping
    public RegistroAula create(@RequestBody RegistroAula aula) {
        return service.createRegistroAula(aula);
    }

    @GetMapping
    public List<RegistroAula> getList() {
        return service.getListRegistroAula();
    }

    @GetMapping("/{id}")
    public RegistroAula getById(@PathVariable Integer id) {
        return service.getRegistroAula(id);
    }

    @PutMapping("/{id}")
    public RegistroAula update(@PathVariable Integer id, @RequestBody RegistroAula aula) {
        return service.updateRegistroAula(id, aula);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteRegistroAula(id);
    }
}

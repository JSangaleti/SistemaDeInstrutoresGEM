/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Instrutor;
import com.gem.backend.service.InstrutorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/instrutores")
public class InstrutorController {

    @Autowired
    private InstrutorService service;

    @PostMapping
    public Instrutor create(@RequestBody Instrutor instrutor) {
        return service.createInstrutor(instrutor);
    }

    @GetMapping
    public List<Instrutor> getList() {
        return service.getListInstrutor();
    }

    @GetMapping("/{id}")
    public Instrutor getById(@PathVariable Integer id) {
        return service.getInstrutor(id);
    }

    @PutMapping("/{id}")
    public Instrutor update(@PathVariable Integer id, @RequestBody Instrutor instrutor) {
        return service.updateInstrutor(id, instrutor);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteInstrutor(id);
    }
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.controller;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Instrumento;
import com.gem.backend.service.InstrumentoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/instrumentos")
public class InstrumentoController {

    @Autowired
    private InstrumentoService service;

    @PostMapping
    public Instrumento create(@RequestBody Instrumento instrumento) {
        return service.createInstrumento(instrumento);
    }

    @GetMapping
    public List<Instrumento> getList() {
        return service.getListInstrumento();
    }

    @GetMapping("/{id}")
    public Instrumento getById(@PathVariable Integer id) {
        return service.getInstrumento(id);
    }

    @PutMapping("/{id}")
    public Instrumento update(@PathVariable Integer id, @RequestBody Instrumento instrumento) {
        return service.updateInstrumento(id, instrumento);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        service.deleteInstrumento(id);
    }
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.repository;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Instrumento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface InstrumentoRepository extends JpaRepository<Instrumento, Integer> {
    Optional<Instrumento> findByNome(String nome);
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.repository;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.Metodo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MetodoRepository extends JpaRepository<Metodo, Integer> {
    List<Metodo> findByAluno_Id(Long alunoId);

    Optional<Metodo> findByNomeAndInstrumento_Id(String nome, Integer instrumentoId);
}

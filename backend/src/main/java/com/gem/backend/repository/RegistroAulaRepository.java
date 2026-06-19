/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.repository;

/**
 *
 * @author leonardo
 */

import com.gem.backend.model.RegistroAula;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RegistroAulaRepository extends JpaRepository<RegistroAula, Integer> {

    List<RegistroAula> findAllByOrderByDataDescIdDesc();

    List<RegistroAula> findByAluno_Pessoa_CpfOrderByDataDescIdDesc(String cpf);

    boolean existsByAluno_IdAndDescricao(Long alunoId, String descricao);
}

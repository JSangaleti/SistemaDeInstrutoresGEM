/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.repository;

/**
 *
 * @author leonardo
 */
import com.gem.backend.model.Aluno;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;

import java.util.Optional;

@Repository
public interface AlunoRepository extends JpaRepository<Aluno, Long> {

    boolean existsByPessoa_Cpf(String cpf);
    
    Optional<Aluno> findByPessoa_Cpf(String cpf);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select aluno from Aluno aluno where aluno.id = :id")
    Optional<Aluno> findByIdForUpdate(@Param("id") Long id);
}

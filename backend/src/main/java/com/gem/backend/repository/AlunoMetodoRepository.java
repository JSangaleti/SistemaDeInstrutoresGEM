package com.gem.backend.repository;

import com.gem.backend.model.AlunoMetodo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AlunoMetodoRepository extends JpaRepository<AlunoMetodo, Integer> {

    List<AlunoMetodo> findByAluno_IdOrderByMetodo_NomeAsc(Long alunoId);

    boolean existsByAluno_IdAndMetodo_Id(Long alunoId, Integer metodoId);

    void deleteByAluno_Id(Long alunoId);
}

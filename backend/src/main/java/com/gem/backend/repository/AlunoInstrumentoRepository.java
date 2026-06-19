package com.gem.backend.repository;

import com.gem.backend.model.AlunoInstrumento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AlunoInstrumentoRepository extends JpaRepository<AlunoInstrumento, Integer> {

    List<AlunoInstrumento> findByAluno_IdOrderByInstrumento_NomeAsc(Long alunoId);

    Optional<AlunoInstrumento> findByAluno_IdAndInstrumento_Id(Long alunoId, Integer instrumentoId);

    void deleteByAluno_Id(Long alunoId);
}

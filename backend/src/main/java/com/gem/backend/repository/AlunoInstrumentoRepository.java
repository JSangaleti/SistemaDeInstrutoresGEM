package com.gem.backend.repository;

import com.gem.backend.model.AlunoInstrumento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface AlunoInstrumentoRepository extends JpaRepository<AlunoInstrumento, Integer> {

    Optional<AlunoInstrumento> findByAluno_IdAndInstrumento_Id(Long alunoId, Integer instrumentoId);

    List<AlunoInstrumento> findByAluno_IdOrderById(Long alunoId);

    List<AlunoInstrumento> findByAluno_IdOrderByInstrumento_NomeAsc(Long alunoId);

    Optional<AlunoInstrumento> findByAluno_IdAndEhInstrumentoPrincipal(Long alunoId, Short principal);

    void deleteByAluno_Id(Long alunoId);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("""
            update AlunoInstrumento vinculo
               set vinculo.ehInstrumentoPrincipal = 0
             where vinculo.aluno.id = :alunoId
               and vinculo.ehInstrumentoPrincipal = 1
            """)
    int desmarcarInstrumentoPrincipal(@Param("alunoId") Long alunoId);
}

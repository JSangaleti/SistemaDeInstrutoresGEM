package com.gem.backend.service;

import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.AlunoInstrumento;
import com.gem.backend.model.Instrumento;
import com.gem.backend.repository.AlunoInstrumentoRepository;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.InstrumentoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AlunoInstrumentoService {

    private final AlunoInstrumentoRepository repository;
    private final AlunoRepository alunoRepository;
    private final InstrumentoRepository instrumentoRepository;

    public AlunoInstrumentoService(
            AlunoInstrumentoRepository repository,
            AlunoRepository alunoRepository,
            InstrumentoRepository instrumentoRepository
    ) {
        this.repository = repository;
        this.alunoRepository = alunoRepository;
        this.instrumentoRepository = instrumentoRepository;
    }

    @Transactional
    public AlunoInstrumento salvarVinculo(Long alunoId, Integer instrumentoId, boolean principal) {
        Aluno aluno = alunoRepository.findByIdForUpdate(alunoId)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));
        Instrumento instrumento = instrumentoRepository.findById(instrumentoId)
                .orElseThrow(() -> new ResourceNotFoundException("Instrumento não encontrado."));

        if (principal) {
            repository.desmarcarInstrumentoPrincipal(alunoId);
        }

        AlunoInstrumento vinculo = repository
                .findByAluno_IdAndInstrumento_Id(alunoId, instrumentoId)
                .orElseGet(AlunoInstrumento::new);
        vinculo.setAluno(aluno);
        vinculo.setInstrumento(instrumento);
        vinculo.setEhInstrumentoPrincipal(principal ? (short) 1 : (short) 0);

        return repository.save(vinculo);
    }

    @Transactional(readOnly = true)
    public List<AlunoInstrumento> listarPorAluno(Long alunoId) {
        if (!alunoRepository.existsById(alunoId)) {
            throw new ResourceNotFoundException("Aluno não encontrado.");
        }
        return repository.findByAluno_IdOrderById(alunoId);
    }
}

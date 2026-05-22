package com.gem.backend.service;

import com.gem.backend.exception.BadRequestException;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.Instrumento;
import com.gem.backend.model.Metodo;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.InstrumentoRepository;
import com.gem.backend.repository.MetodoRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MetodoService {

    private final MetodoRepository repository;
    private final InstrumentoRepository instrumentoRepository;
    private final AlunoRepository alunoRepository;

    public MetodoService(
            MetodoRepository repository,
            InstrumentoRepository instrumentoRepository,
            AlunoRepository alunoRepository
    ) {
        this.repository = repository;
        this.instrumentoRepository = instrumentoRepository;
        this.alunoRepository = alunoRepository;
    }

    public Metodo createMetodo(Metodo metodo) {
        if (metodo.getId() != null && repository.existsById(metodo.getId())) {
            throw new DuplicateResourceException("Já existe um método cadastrado com este ID.");
        }

        Instrumento instrumento = buscarInstrumentoObrigatorio(metodo);
        metodo.setInstrumento(instrumento);

        if (metodo.getAluno() != null && metodo.getAluno().getId() != null) {
            Aluno aluno = buscarAluno(metodo.getAluno().getId());
            metodo.setAluno(aluno);
        }

        return repository.save(metodo);
    }

    public List<Metodo> getListMetodo() {
        return repository.findAll();
    }

    public Metodo getMetodo(Integer id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Método não encontrado."));
    }

    public Metodo updateMetodo(Integer id, Metodo dadosAtualizados) {
        Metodo existente = getMetodo(id);

        if (dadosAtualizados.getNome() != null && !dadosAtualizados.getNome().isBlank()) {
            existente.setNome(dadosAtualizados.getNome());
        }

        if (dadosAtualizados.getInstrumento() != null) {
            Instrumento instrumento = buscarInstrumentoObrigatorio(dadosAtualizados);
            existente.setInstrumento(instrumento);
        }

        if (dadosAtualizados.getAluno() != null) {
            if (dadosAtualizados.getAluno().getId() == null) {
                throw new BadRequestException("Informe o ID do aluno vinculado ao método.");
            }

            Aluno aluno = buscarAluno(dadosAtualizados.getAluno().getId());
            existente.setAluno(aluno);
        }

        return repository.save(existente);
    }

    public void deleteMetodo(Integer id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Método não encontrado.");
        }

        repository.deleteById(id);
    }

    private Instrumento buscarInstrumentoObrigatorio(Metodo metodo) {
        if (metodo.getInstrumento() == null
                || metodo.getInstrumento().getId() == null) {
            throw new BadRequestException("Informe o ID do instrumento vinculado ao método.");
        }

        return instrumentoRepository.findById(metodo.getInstrumento().getId())
                .orElseThrow(() -> new ResourceNotFoundException("Instrumento não encontrado."));
    }

    private Aluno buscarAluno(Long id) {
        return alunoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));
    }
}

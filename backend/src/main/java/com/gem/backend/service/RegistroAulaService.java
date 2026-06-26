package com.gem.backend.service;

import com.gem.backend.dto.RegistroAulaResponseDTO;
import com.gem.backend.exception.BadRequestException;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.Instrutor;
import com.gem.backend.model.RegistroAula;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.InstrutorRepository;
import com.gem.backend.repository.RegistroAulaRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class RegistroAulaService {

    private final RegistroAulaRepository repository;
    private final AlunoRepository alunoRepository;
    private final InstrutorRepository instrutorRepository;

    public RegistroAulaService(
            RegistroAulaRepository repository,
            AlunoRepository alunoRepository,
            InstrutorRepository instrutorRepository
    ) {
        this.repository = repository;
        this.alunoRepository = alunoRepository;
        this.instrutorRepository = instrutorRepository;
    }

    @Transactional
    public RegistroAulaResponseDTO createRegistroAula(RegistroAula aula, Authentication authentication) {
        if (aula.getId() != null && repository.existsById(aula.getId())) {
            throw new DuplicateResourceException("Já existe uma aula cadastrada com este ID.");
        }

        Aluno aluno = buscarAlunoObrigatorio(aula);
        Instrutor instrutor = resolverInstrutor(aula, authentication);

        aula.setAluno(aluno);
        aula.setInstrutor(instrutor);

        if (aula.getData() == null) {
            aula.setData(LocalDate.now());
        }

        RegistroAula aulaSalva = repository.save(aula);
        return new RegistroAulaResponseDTO(aulaSalva);
    }

    public List<RegistroAulaResponseDTO> getListRegistroAula(Authentication authentication) {
        var registros = repository.findAllByOrderByDataDescIdDesc().stream();

        if (isInstrutor(authentication)) {
            Instrutor instrutorAutenticado = buscarInstrutorAutenticado(authentication);
            registros = registros.filter(registro ->
                    registro.getInstrutor() != null
                            && registro.getInstrutor().getId().equals(instrutorAutenticado.getId())
            );
        }

        return registros
                .map(RegistroAulaResponseDTO::new)
                .toList();
    }

    public List<RegistroAulaResponseDTO> getHistoricoDoAlunoAutenticado(String cpf) {
        return repository.findByAluno_Pessoa_CpfOrderByDataDescIdDesc(cpf).stream()
                .map(RegistroAulaResponseDTO::new)
                .toList();
    }

    public RegistroAulaResponseDTO getRegistroAula(Integer id) {
        RegistroAula aula = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Registro de aula não encontrado."));

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String cpfLogado = auth.getName();

        boolean isAdminOuInstrutor = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN") || a.getAuthority().equals("ROLE_INSTRUTOR"));

        if (!isAdminOuInstrutor && !aula.getAluno().getPessoa().getCpf().equals(cpfLogado)) {
            throw new AccessDeniedException("Acesso negado: Você só pode acessar seus próprios registros de aula.");
        }

        return new RegistroAulaResponseDTO(aula);
    }

    @Transactional
    public RegistroAulaResponseDTO updateRegistroAula(
            Integer id,
            RegistroAula dadosAtualizados,
            Authentication authentication
    ) {
        RegistroAula existente = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Registro de aula não encontrado."));

        if (isInstrutor(authentication)) {
            Instrutor instrutorAutenticado = buscarInstrutorAutenticado(authentication);
            if (!existente.getInstrutor().getId().equals(instrutorAutenticado.getId())) {
                throw new AccessDeniedException("Você só pode editar registros de aula de sua autoria.");
            }
            existente.setInstrutor(instrutorAutenticado);
        }

        if (dadosAtualizados.getAluno() != null) {
            Aluno aluno = buscarAlunoObrigatorio(dadosAtualizados);
            existente.setAluno(aluno);
        }

        if (!isInstrutor(authentication) && dadosAtualizados.getInstrutor() != null) {
            Instrutor instrutor = buscarInstrutorObrigatorio(dadosAtualizados);
            existente.setInstrutor(instrutor);
        }

        if (dadosAtualizados.getDescricao() != null) {
            existente.setDescricao(dadosAtualizados.getDescricao());
        }

        if (dadosAtualizados.getParaProximaAula() != null) {
            existente.setParaProximaAula(dadosAtualizados.getParaProximaAula());
        }

        if (dadosAtualizados.getPresente() != null) {
            existente.setPresente(dadosAtualizados.getPresente());
        }

        if (dadosAtualizados.getData() != null) {
            existente.setData(dadosAtualizados.getData());
        }

        return new RegistroAulaResponseDTO(repository.save(existente));
    }

    public void deleteRegistroAula(Integer id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Registro de aula não encontrado.");
        }
        repository.deleteById(id);
    }

    private Aluno buscarAlunoObrigatorio(RegistroAula aula) {
        if (aula.getAluno() == null || aula.getAluno().getId() == null) {
            throw new BadRequestException("Informe o ID do aluno vinculado ao registro de aula.");
        }
        return alunoRepository.findById(aula.getAluno().getId())
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));
    }

    private Instrutor buscarInstrutorObrigatorio(RegistroAula aula) {
        if (aula.getInstrutor() == null || aula.getInstrutor().getId() == null) {
            throw new BadRequestException("Informe o ID do instrutor vinculado ao registro de aula.");
        }
        return instrutorRepository.findById(aula.getInstrutor().getId())
                .orElseThrow(() -> new ResourceNotFoundException("Instrutor não encontrado."));
    }

    private Instrutor resolverInstrutor(RegistroAula aula, Authentication authentication) {
        if (isInstrutor(authentication)) {
            return buscarInstrutorAutenticado(authentication);
        }
        return buscarInstrutorObrigatorio(aula);
    }

    private Instrutor buscarInstrutorAutenticado(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new AccessDeniedException("Instrutor autenticado não identificado.");
        }

        return instrutorRepository.findByPessoa_Cpf(authentication.getName())
                .orElseThrow(() -> new AccessDeniedException("Instrutor autenticado não encontrado."));
    }

    private boolean isInstrutor(Authentication authentication) {
        return authentication != null && authentication.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("ROLE_INSTRUTOR"));
    }
}

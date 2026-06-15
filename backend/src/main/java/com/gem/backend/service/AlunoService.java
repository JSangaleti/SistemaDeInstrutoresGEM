package com.gem.backend.service;

import com.gem.backend.dto.AlunoResponseDTO;
import com.gem.backend.exception.BadRequestException;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.Comum;
import com.gem.backend.model.Pessoa;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.ComumRepository;
import com.gem.backend.repository.PessoaRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AlunoService {

    private final AlunoRepository repository;
    private final PessoaRepository pessoaRepository;
    private final ComumRepository comumRepository;
    private final PasswordEncoder passwordEncoder;

    public AlunoService(
            AlunoRepository repository,
            PessoaRepository pessoaRepository,
            ComumRepository comumRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.repository = repository;
        this.pessoaRepository = pessoaRepository;
        this.comumRepository = comumRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public AlunoResponseDTO createAluno(Aluno aluno) {
        if (aluno.getId() != null && repository.existsById(aluno.getId())) {
            throw new DuplicateResourceException("Já existe um aluno cadastrado com este ID.");
        }

        Pessoa pessoa = buscarPessoaObrigatoria(aluno);

        if (repository.existsByPessoa_Cpf(pessoa.getCpf())) {
            throw new DuplicateResourceException("Já existe um aluno cadastrado para este CPF.");
        }

        aluno.setPessoa(pessoa);
        aluno.setSenha(passwordEncoder.encode(aluno.getSenha()));

        if (aluno.getComum() != null && aluno.getComum().getId() != null) {
            Comum comum = comumRepository.findById(aluno.getComum().getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Comum não encontrada."));

            aluno.setComum(comum);
        }

        Aluno alunoSalvo = repository.save(aluno);
        return new AlunoResponseDTO(alunoSalvo);
    }

    public List<AlunoResponseDTO> getListAluno() {
        return repository.findAll().stream()
                .map(AlunoResponseDTO::new)
                .toList();
    }

    public AlunoResponseDTO getAluno(Long id) {
        Aluno aluno = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String cpfLogado = auth.getName();

        boolean isAdminOuInstrutor = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN") || a.getAuthority().equals("ROLE_INSTRUTOR"));

        if (!isAdminOuInstrutor && !aluno.getPessoa().getCpf().equals(cpfLogado)) {
            throw new AccessDeniedException("Acesso negado: Você só pode acessar o seu próprio perfil.");
        }

        return new AlunoResponseDTO(aluno);
    }

    public AlunoResponseDTO updateAluno(Long id, Aluno dadosAtualizados) {
        Aluno alunoExistente = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));

        if (dadosAtualizados.getSenha() != null && !dadosAtualizados.getSenha().trim().isEmpty()) {
            alunoExistente.setSenha(passwordEncoder.encode(dadosAtualizados.getSenha()));
        }

        if (dadosAtualizados.getPessoa() != null && dadosAtualizados.getPessoa().getCpf() != null) {
            Pessoa pessoa = buscarPessoaObrigatoria(dadosAtualizados);

            boolean cpfMudou = alunoExistente.getPessoa() == null
                    || !pessoa.getCpf().equals(alunoExistente.getPessoa().getCpf());

            if (cpfMudou && repository.existsByPessoa_Cpf(pessoa.getCpf())) {
                throw new DuplicateResourceException("Já existe um aluno cadastrado para este CPF.");
            }

            alunoExistente.setPessoa(pessoa);
        }

        if (dadosAtualizados.getComum() != null && dadosAtualizados.getComum().getId() != null) {
            Comum comum = comumRepository.findById(dadosAtualizados.getComum().getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Comum não encontrada."));

            alunoExistente.setComum(comum);
        }

        return new AlunoResponseDTO(repository.save(alunoExistente));
    }

    public void deleteAluno(Long id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Aluno não encontrado.");
        }

        repository.deleteById(id);
    }

    private Pessoa buscarPessoaObrigatoria(Aluno aluno) {
        if (aluno == null
                || aluno.getPessoa() == null
                || aluno.getPessoa().getCpf() == null
                || aluno.getPessoa().getCpf().trim().isEmpty()) {
            throw new BadRequestException("Informe o CPF da pessoa vinculada ao aluno.");
        }

        return pessoaRepository.findById(aluno.getPessoa().getCpf())
                .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));
    }
}
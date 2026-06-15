package com.gem.backend.service;

import com.gem.backend.dto.InstrutorResponseDTO;
import com.gem.backend.exception.BadRequestException;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Instrutor;
import com.gem.backend.model.Pessoa;
import com.gem.backend.repository.InstrutorRepository;
import com.gem.backend.repository.PessoaRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class InstrutorService {

    private final InstrutorRepository repository;
    private final PessoaRepository pessoaRepository;
    private final PasswordEncoder passwordEncoder;

    public InstrutorService(InstrutorRepository repository, PessoaRepository pessoaRepository, PasswordEncoder passwordEncoder) {
        this.repository = repository;
        this.pessoaRepository = pessoaRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public InstrutorResponseDTO createInstrutor(Instrutor instrutor) {
        if (instrutor.getId() != null && repository.existsById(instrutor.getId())) {
            throw new DuplicateResourceException("Já existe um instrutor cadastrado com este ID.");
        }

        Pessoa pessoa = buscarPessoaObrigatoria(instrutor);

        if (repository.existsByPessoa_Cpf(pessoa.getCpf())) {
            throw new DuplicateResourceException("Já existe um instrutor cadastrado para este CPF.");
        }

        instrutor.setPessoa(pessoa);
        instrutor.setSenha(passwordEncoder.encode(instrutor.getSenha()));

        return new InstrutorResponseDTO(repository.save(instrutor));
    }

    public List<InstrutorResponseDTO> getListInstrutor() {
        return repository.findAll().stream().map(InstrutorResponseDTO::new).toList();
    }

    public InstrutorResponseDTO getInstrutor(Integer id) {
        Instrutor instrutor = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Instrutor não encontrado."));
        return new InstrutorResponseDTO(instrutor);
    }

    public InstrutorResponseDTO updateInstrutor(Integer id, Instrutor dadosAtualizados) {
        Instrutor existente = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Instrutor não encontrado."));

        if (dadosAtualizados.getSenha() != null && !dadosAtualizados.getSenha().trim().isEmpty()) {
            existente.setSenha(passwordEncoder.encode(dadosAtualizados.getSenha()));
        }

        if (dadosAtualizados.getPessoa() != null && dadosAtualizados.getPessoa().getCpf() != null) {
            Pessoa pessoa = buscarPessoaObrigatoria(dadosAtualizados);
            boolean cpfMudou = existente.getPessoa() == null || !pessoa.getCpf().equals(existente.getPessoa().getCpf());

            if (cpfMudou && repository.existsByPessoa_Cpf(pessoa.getCpf())) {
                throw new DuplicateResourceException("Já existe um instrutor cadastrado para este CPF.");
            }
            existente.setPessoa(pessoa);
        }

        return new InstrutorResponseDTO(repository.save(existente));
    }

    public void deleteInstrutor(Integer id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Instrutor não encontrado.");
        }
        repository.deleteById(id);
    }

    private Pessoa buscarPessoaObrigatoria(Instrutor instrutor) {
        if (instrutor.getPessoa() == null || instrutor.getPessoa().getCpf() == null || instrutor.getPessoa().getCpf().trim().isEmpty()) {
            throw new BadRequestException("Informe o CPF da pessoa vinculada ao instrutor.");
        }
        return pessoaRepository.findById(instrutor.getPessoa().getCpf())
                .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));
    }
}
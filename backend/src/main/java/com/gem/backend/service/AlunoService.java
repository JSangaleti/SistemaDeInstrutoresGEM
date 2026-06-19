package com.gem.backend.service;

import com.gem.backend.dto.AlunoInstrumentoRequestDTO;
import com.gem.backend.dto.AlunoInstrumentoResponseDTO;
import com.gem.backend.dto.AlunoRequestDTO;
import com.gem.backend.dto.AlunoResponseDTO;
import com.gem.backend.dto.MetodoResponseDTO;
import com.gem.backend.exception.BadRequestException;
import com.gem.backend.exception.DuplicateResourceException;
import com.gem.backend.exception.ResourceNotFoundException;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.AlunoInstrumento;
import com.gem.backend.model.AlunoMetodo;
import com.gem.backend.model.Comum;
import com.gem.backend.model.Instrumento;
import com.gem.backend.model.Metodo;
import com.gem.backend.model.Pessoa;
import com.gem.backend.repository.AlunoInstrumentoRepository;
import com.gem.backend.repository.AlunoMetodoRepository;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.ComumRepository;
import com.gem.backend.repository.InstrumentoRepository;
import com.gem.backend.repository.MetodoRepository;
import com.gem.backend.repository.PessoaRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class AlunoService {

    private final AlunoRepository repository;
    private final PessoaRepository pessoaRepository;
    private final ComumRepository comumRepository;
    private final InstrumentoRepository instrumentoRepository;
    private final MetodoRepository metodoRepository;
    private final AlunoInstrumentoRepository alunoInstrumentoRepository;
    private final AlunoMetodoRepository alunoMetodoRepository;
    private final PasswordEncoder passwordEncoder;

    public AlunoService(
            AlunoRepository repository,
            PessoaRepository pessoaRepository,
            ComumRepository comumRepository,
            InstrumentoRepository instrumentoRepository,
            MetodoRepository metodoRepository,
            AlunoInstrumentoRepository alunoInstrumentoRepository,
            AlunoMetodoRepository alunoMetodoRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.repository = repository;
        this.pessoaRepository = pessoaRepository;
        this.comumRepository = comumRepository;
        this.instrumentoRepository = instrumentoRepository;
        this.metodoRepository = metodoRepository;
        this.alunoInstrumentoRepository = alunoInstrumentoRepository;
        this.alunoMetodoRepository = alunoMetodoRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public AlunoResponseDTO createAluno(AlunoRequestDTO dados) {
        Pessoa pessoa = buscarPessoaObrigatoria(dados.pessoa());

        if (repository.existsByPessoa_Cpf(pessoa.getCpf())) {
            throw new DuplicateResourceException("Já existe um aluno cadastrado para este CPF.");
        }

        if (dados.senha() == null || dados.senha().isBlank()) {
            throw new BadRequestException("Senha é obrigatória.");
        }

        Aluno aluno = new Aluno();
        aluno.setPessoa(pessoa);
        aluno.setSenha(passwordEncoder.encode(dados.senha()));
        definirComum(aluno, dados.comum());

        Aluno alunoSalvo = repository.save(aluno);
        sincronizarInstrumentos(alunoSalvo, dados.instrumentos());
        sincronizarMetodos(alunoSalvo, dados.metodoIds());
        return toResponse(alunoSalvo);
    }

    @Transactional(readOnly = true)
    public List<AlunoResponseDTO> getListAluno() {
        return repository.findAll().stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public AlunoResponseDTO getAluno(Long id) {
        Aluno aluno = buscarAluno(id);

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String cpfLogado = auth.getName();

        boolean isAdminOuInstrutor = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN")
                        || a.getAuthority().equals("ROLE_INSTRUTOR"));

        if (!isAdminOuInstrutor && !aluno.getPessoa().getCpf().equals(cpfLogado)) {
            throw new AccessDeniedException("Acesso negado: Você só pode acessar o seu próprio perfil.");
        }

        return toResponse(aluno);
    }

    @Transactional(readOnly = true)
    public AlunoResponseDTO getAlunoPorCpf(String cpf) {
        Aluno aluno = repository.findByPessoa_Cpf(cpf)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));
        return toResponse(aluno);
    }

    @Transactional
    public AlunoResponseDTO updateAluno(Long id, AlunoRequestDTO dados) {
        Aluno alunoExistente = repository.findByIdForUpdate(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));

        if (dados.senha() != null && !dados.senha().isBlank()) {
            alunoExistente.setSenha(passwordEncoder.encode(dados.senha()));
        }

        if (dados.pessoa() != null && dados.pessoa().getCpf() != null) {
            Pessoa pessoa = buscarPessoaObrigatoria(dados.pessoa());
            boolean cpfMudou = alunoExistente.getPessoa() == null
                    || !pessoa.getCpf().equals(alunoExistente.getPessoa().getCpf());

            if (cpfMudou && repository.existsByPessoa_Cpf(pessoa.getCpf())) {
                throw new DuplicateResourceException("Já existe um aluno cadastrado para este CPF.");
            }
            alunoExistente.setPessoa(pessoa);
        }

        definirComum(alunoExistente, dados.comum());
        repository.save(alunoExistente);
        sincronizarInstrumentos(alunoExistente, dados.instrumentos());
        sincronizarMetodos(alunoExistente, dados.metodoIds());
        return toResponse(alunoExistente);
    }

    @Transactional
    public void deleteAluno(Long id) {
        Aluno aluno = buscarAluno(id);

        alunoMetodoRepository.deleteByAluno_Id(id);
        alunoInstrumentoRepository.deleteByAluno_Id(id);
        alunoMetodoRepository.flush();
        alunoInstrumentoRepository.flush();

        List<Metodo> metodosLegados = metodoRepository.findByAluno_Id(id);
        metodosLegados.forEach(metodo -> metodo.setAluno(null));
        metodoRepository.saveAll(metodosLegados);
        metodoRepository.flush();

        repository.delete(aluno);
    }

    private void sincronizarInstrumentos(
            Aluno aluno,
            List<AlunoInstrumentoRequestDTO> instrumentosSolicitados
    ) {
        if (instrumentosSolicitados == null) {
            return;
        }
        if (instrumentosSolicitados.isEmpty()) {
            throw new BadRequestException("Selecione pelo menos um instrumento para o aluno.");
        }

        long quantidadePrincipais = instrumentosSolicitados.stream()
                .filter(item -> Boolean.TRUE.equals(item.principal()))
                .count();
        if (quantidadePrincipais != 1) {
            throw new BadRequestException("Selecione exatamente um instrumento principal.");
        }

        Set<Integer> idsUnicos = new HashSet<>();
        List<AlunoInstrumento> novosVinculos = new ArrayList<>();

        for (AlunoInstrumentoRequestDTO item : instrumentosSolicitados) {
            if (!idsUnicos.add(item.instrumentoId())) {
                throw new BadRequestException("Um instrumento não pode ser selecionado mais de uma vez.");
            }

            Instrumento instrumento = instrumentoRepository.findById(item.instrumentoId())
                    .orElseThrow(() -> new ResourceNotFoundException("Instrumento não encontrado."));

            AlunoInstrumento vinculo = new AlunoInstrumento();
            vinculo.setAluno(aluno);
            vinculo.setInstrumento(instrumento);
            vinculo.setEhInstrumentoPrincipal(Boolean.TRUE.equals(item.principal()) ? (short) 1 : (short) 0);
            novosVinculos.add(vinculo);
        }

        alunoInstrumentoRepository.deleteByAluno_Id(aluno.getId());
        alunoInstrumentoRepository.flush();
        alunoInstrumentoRepository.saveAll(novosVinculos);
    }

    private void sincronizarMetodos(Aluno aluno, List<Integer> metodoIds) {
        if (metodoIds == null) {
            return;
        }

        Set<Integer> idsUnicos = new HashSet<>();
        for (Integer metodoId : metodoIds) {
            if (metodoId == null) {
                throw new BadRequestException("Informe IDs de métodos válidos.");
            }
            if (!idsUnicos.add(metodoId)) {
                throw new BadRequestException("Um método não pode ser selecionado mais de uma vez.");
            }
        }

        List<Metodo> metodos = metodoRepository.findAllById(idsUnicos);
        if (metodos.size() != idsUnicos.size()) {
            throw new ResourceNotFoundException("Um ou mais métodos não foram encontrados.");
        }

        // Converte também os vínculos do modelo antigo (metodos.aluno_id) para a tabela associativa.
        List<Metodo> metodosLegados = metodoRepository.findByAluno_Id(aluno.getId());
        metodosLegados.forEach(metodo -> metodo.setAluno(null));
        metodoRepository.saveAll(metodosLegados);

        alunoMetodoRepository.deleteByAluno_Id(aluno.getId());
        alunoMetodoRepository.flush();
        List<AlunoMetodo> novosVinculos = metodos.stream().map(metodo -> {
            AlunoMetodo vinculo = new AlunoMetodo();
            vinculo.setAluno(aluno);
            vinculo.setMetodo(metodo);
            return vinculo;
        }).toList();
        alunoMetodoRepository.saveAll(novosVinculos);
    }

    private AlunoResponseDTO toResponse(Aluno aluno) {
        List<AlunoInstrumentoResponseDTO> instrumentos = alunoInstrumentoRepository
                .findByAluno_IdOrderByInstrumento_NomeAsc(aluno.getId())
                .stream()
                .map(AlunoInstrumentoResponseDTO::new)
                .toList();

        Map<Integer, Metodo> metodosPorId = new LinkedHashMap<>();
        alunoMetodoRepository.findByAluno_IdOrderByMetodo_NomeAsc(aluno.getId())
                .forEach(vinculo -> metodosPorId.put(vinculo.getMetodo().getId(), vinculo.getMetodo()));
        metodoRepository.findByAluno_Id(aluno.getId())
                .forEach(metodo -> metodosPorId.putIfAbsent(metodo.getId(), metodo));

        List<MetodoResponseDTO> metodos = metodosPorId.values().stream()
                .sorted((a, b) -> a.getNome().compareToIgnoreCase(b.getNome()))
                .map(MetodoResponseDTO::new)
                .toList();

        return new AlunoResponseDTO(aluno, instrumentos, metodos);
    }

    private Aluno buscarAluno(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não encontrado."));
    }

    private Pessoa buscarPessoaObrigatoria(Pessoa pessoaInformada) {
        if (pessoaInformada == null
                || pessoaInformada.getCpf() == null
                || pessoaInformada.getCpf().isBlank()) {
            throw new BadRequestException("Informe o CPF da pessoa vinculada ao aluno.");
        }

        return pessoaRepository.findById(pessoaInformada.getCpf())
                .orElseThrow(() -> new ResourceNotFoundException("Pessoa não encontrada."));
    }

    private void definirComum(Aluno aluno, Comum comumInformada) {
        if (comumInformada == null || comumInformada.getId() == null) {
            return;
        }

        Comum comum = comumRepository.findById(comumInformada.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Comum não encontrada."));
        aluno.setComum(comum);
    }
}

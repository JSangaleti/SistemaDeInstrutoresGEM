package com.gem.backend.service;

import com.gem.backend.dto.AlunoInstrumentoRequestDTO;
import com.gem.backend.dto.AlunoRequestDTO;
import com.gem.backend.exception.BadRequestException;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.AlunoInstrumento;
import com.gem.backend.model.AlunoMetodo;
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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AlunoServiceTest {

    @Mock
    private AlunoRepository alunoRepository;
    @Mock
    private PessoaRepository pessoaRepository;
    @Mock
    private ComumRepository comumRepository;
    @Mock
    private InstrumentoRepository instrumentoRepository;
    @Mock
    private MetodoRepository metodoRepository;
    @Mock
    private AlunoInstrumentoRepository alunoInstrumentoRepository;
    @Mock
    private AlunoMetodoRepository alunoMetodoRepository;
    @Mock
    private PasswordEncoder passwordEncoder;

    private AlunoService service;
    private Aluno aluno;

    @BeforeEach
    void setUp() {
        service = new AlunoService(
                alunoRepository,
                pessoaRepository,
                comumRepository,
                instrumentoRepository,
                metodoRepository,
                alunoInstrumentoRepository,
                alunoMetodoRepository,
                passwordEncoder
        );

        Pessoa pessoa = new Pessoa();
        pessoa.setCpf("12345678901");
        pessoa.setNome("Aluno Teste");

        aluno = new Aluno();
        aluno.setId(1L);
        aluno.setPessoa(pessoa);
        aluno.setSenha("senha-codificada");

        when(alunoRepository.findById(1L)).thenReturn(Optional.of(aluno));
        when(alunoRepository.save(any(Aluno.class))).thenAnswer(invocation -> invocation.getArgument(0));
    }

    @Test
    void devePreservarMetodosDeInstrumentosDiferentesAoTrocarPrincipal() {
        Instrumento violino = instrumento(10, "Violino");
        Instrumento trompete = instrumento(20, "Trompete");
        Metodo metodoViolino = metodo(100, "Método de violino", violino);
        Metodo metodoTrompete = metodo(200, "Método de trompete", trompete);

        when(instrumentoRepository.findById(10)).thenReturn(Optional.of(violino));
        when(instrumentoRepository.findById(20)).thenReturn(Optional.of(trompete));
        when(metodoRepository.findAllById(any())).thenReturn(List.of(metodoViolino, metodoTrompete));
        when(alunoInstrumentoRepository.findByAluno_IdOrderByInstrumento_NomeAsc(1L))
                .thenReturn(List.of());
        when(alunoMetodoRepository.findByAluno_IdOrderByMetodo_NomeAsc(1L))
                .thenReturn(List.of());
        when(metodoRepository.findByAluno_Id(1L)).thenReturn(List.of());

        AlunoRequestDTO request = new AlunoRequestDTO(
                null,
                null,
                null,
                List.of(
                        new AlunoInstrumentoRequestDTO(10, false),
                        new AlunoInstrumentoRequestDTO(20, true)
                ),
                List.of(100, 200)
        );

        service.updateAluno(1L, request);

        ArgumentCaptor<Iterable<AlunoInstrumento>> instrumentoCaptor = captor();
        verify(alunoInstrumentoRepository).saveAll(instrumentoCaptor.capture());
        Set<Integer> principais = new HashSet<>();
        for (AlunoInstrumento vinculo : instrumentoCaptor.getValue()) {
            if (vinculo.getEhInstrumentoPrincipal() == 1) {
                principais.add(vinculo.getInstrumento().getId());
            }
        }
        assertEquals(Set.of(20), principais);

        ArgumentCaptor<Iterable<AlunoMetodo>> metodoCaptor = captor();
        verify(alunoMetodoRepository).saveAll(metodoCaptor.capture());
        Set<Integer> metodosSalvos = new HashSet<>();
        for (AlunoMetodo vinculo : metodoCaptor.getValue()) {
            metodosSalvos.add(vinculo.getMetodo().getId());
        }
        assertEquals(Set.of(100, 200), metodosSalvos);
    }

    @Test
    void deveRejeitarMaisDeUmInstrumentoPrincipal() {
        AlunoRequestDTO request = new AlunoRequestDTO(
                null,
                null,
                null,
                List.of(
                        new AlunoInstrumentoRequestDTO(10, true),
                        new AlunoInstrumentoRequestDTO(20, true)
                ),
                List.of()
        );

        BadRequestException exception = assertThrows(
                BadRequestException.class,
                () -> service.updateAluno(1L, request)
        );

        assertEquals("Selecione exatamente um instrumento principal.", exception.getMessage());
    }

    private Instrumento instrumento(int id, String nome) {
        Instrumento instrumento = new Instrumento();
        instrumento.setId(id);
        instrumento.setNome(nome);
        return instrumento;
    }

    private Metodo metodo(int id, String nome, Instrumento instrumento) {
        Metodo metodo = new Metodo();
        metodo.setId(id);
        metodo.setNome(nome);
        metodo.setInstrumento(instrumento);
        return metodo;
    }

    @SuppressWarnings({"rawtypes", "unchecked"})
    private <T> ArgumentCaptor<Iterable<T>> captor() {
        return (ArgumentCaptor) ArgumentCaptor.forClass(Iterable.class);
    }
}

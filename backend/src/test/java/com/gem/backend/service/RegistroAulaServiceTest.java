package com.gem.backend.service;

import com.gem.backend.model.Aluno;
import com.gem.backend.model.Instrutor;
import com.gem.backend.model.Pessoa;
import com.gem.backend.model.RegistroAula;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.InstrutorRepository;
import com.gem.backend.repository.RegistroAulaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RegistroAulaServiceTest {

    @Mock
    private RegistroAulaRepository registroAulaRepository;

    @Mock
    private AlunoRepository alunoRepository;

    @Mock
    private InstrutorRepository instrutorRepository;

    private RegistroAulaService service;

    @BeforeEach
    void setUp() {
        service = new RegistroAulaService(
                registroAulaRepository,
                alunoRepository,
                instrutorRepository
        );
    }

    @Test
    void usaInstrutorAutenticadoAoCriarRegistro() {
        Aluno aluno = aluno(1L);
        Instrutor instrutorAutenticado = instrutor(10, "11111111111");
        RegistroAula novoRegistro = new RegistroAula();
        novoRegistro.setAluno(aluno);
        novoRegistro.setInstrutor(instrutor(99, "99999999999"));

        when(alunoRepository.findById(1L)).thenReturn(Optional.of(aluno));
        when(instrutorRepository.findByPessoa_Cpf("11111111111"))
                .thenReturn(Optional.of(instrutorAutenticado));
        when(registroAulaRepository.save(any(RegistroAula.class)))
                .thenAnswer(invocation -> {
                    RegistroAula registro = invocation.getArgument(0);
                    registro.setId(1);
                    return registro;
                });

        service.createRegistroAula(novoRegistro, autenticacaoInstrutor("11111111111"));

        assertThat(novoRegistro.getInstrutor().getId()).isEqualTo(10);
        verify(instrutorRepository, never()).findById(99);
    }

    @Test
    void impedeInstrutorDeEditarRegistroDeOutroInstrutor() {
        RegistroAula existente = new RegistroAula();
        existente.setId(1);
        existente.setAluno(aluno(1L));
        existente.setInstrutor(instrutor(20, "22222222222"));

        when(registroAulaRepository.findById(1)).thenReturn(Optional.of(existente));
        when(instrutorRepository.findByPessoa_Cpf("11111111111"))
                .thenReturn(Optional.of(instrutor(10, "11111111111")));

        assertThatThrownBy(() -> service.updateRegistroAula(
                1,
                new RegistroAula(),
                autenticacaoInstrutor("11111111111")
        )).isInstanceOf(AccessDeniedException.class);

        verify(registroAulaRepository, never()).save(any(RegistroAula.class));
    }

    private Authentication autenticacaoInstrutor(String cpf) {
        return new UsernamePasswordAuthenticationToken(
                cpf,
                null,
                List.of(new SimpleGrantedAuthority("ROLE_INSTRUTOR"))
        );
    }

    private Aluno aluno(Long id) {
        Aluno aluno = new Aluno();
        aluno.setId(id);
        Pessoa pessoa = new Pessoa();
        pessoa.setNome("Aluno Teste");
        aluno.setPessoa(pessoa);
        return aluno;
    }

    private Instrutor instrutor(Integer id, String cpf) {
        Instrutor instrutor = new Instrutor();
        instrutor.setId(id);
        Pessoa pessoa = new Pessoa();
        pessoa.setCpf(cpf);
        pessoa.setNome("Instrutor Teste");
        instrutor.setPessoa(pessoa);
        return instrutor;
    }
}

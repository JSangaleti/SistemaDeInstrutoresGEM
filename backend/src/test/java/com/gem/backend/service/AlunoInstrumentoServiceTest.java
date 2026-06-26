package com.gem.backend.service;

import com.gem.backend.dto.AlunoResponseDTO;
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
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class AlunoInstrumentoServiceTest {

    @Autowired
    private AlunoInstrumentoService service;

    @Autowired
    private AlunoService alunoService;

    @Autowired
    private AlunoInstrumentoRepository alunoInstrumentoRepository;

    @Autowired
    private AlunoMetodoRepository alunoMetodoRepository;

    @Autowired
    private AlunoRepository alunoRepository;

    @Autowired
    private InstrumentoRepository instrumentoRepository;

    @Autowired
    private MetodoRepository metodoRepository;

    @Autowired
    private PessoaRepository pessoaRepository;

    @Autowired
    private ComumRepository comumRepository;

    @Test
    void mantemSomenteUmInstrumentoPrincipalPorAluno() {
        Aluno aluno = criarAluno();
        Instrumento violino = criarInstrumento("Violino");
        Instrumento trompete = criarInstrumento("Trompete");

        service.salvarVinculo(aluno.getId(), violino.getId(), true);
        service.salvarVinculo(aluno.getId(), trompete.getId(), true);

        List<AlunoInstrumento> vinculos = alunoInstrumentoRepository
                .findByAluno_IdOrderById(aluno.getId());

        assertThat(vinculos).hasSize(2);
        assertThat(vinculos)
                .filteredOn(vinculo -> vinculo.getEhInstrumentoPrincipal() == 1)
                .singleElement()
                .extracting(vinculo -> vinculo.getInstrumento().getId())
                .isEqualTo(trompete.getId());
    }

    @Test
    void retornaInstrumentosEMetodosNoPerfilDoAluno() {
        Aluno aluno = criarAluno();
        Instrumento violino = criarInstrumento("Violino");
        service.salvarVinculo(aluno.getId(), violino.getId(), true);

        Metodo metodo = new Metodo();
        metodo.setNome("Método de violino");
        metodo.setInstrumento(violino);
        Metodo metodoSalvo = metodoRepository.save(metodo);

        AlunoMetodo alunoMetodo = new AlunoMetodo();
        alunoMetodo.setAluno(aluno);
        alunoMetodo.setMetodo(metodoSalvo);
        alunoMetodoRepository.save(alunoMetodo);

        AlunoResponseDTO perfil = alunoService.getAlunoPorCpf("12345678901");

        assertThat(perfil.instrumentos()).singleElement().satisfies(instrumento -> {
            assertThat(instrumento.id()).isEqualTo(violino.getId());
            assertThat(instrumento.principal()).isTrue();
        });
        assertThat(perfil.metodos()).singleElement().satisfies(metodoRetornado -> {
            assertThat(metodoRetornado.id()).isEqualTo(metodoSalvo.getId());
            assertThat(metodoRetornado.instrumentoId()).isEqualTo(violino.getId());
        });
    }

    private Aluno criarAluno() {
        Comum comum = new Comum();
        comum.setNome("Central");
        comum = comumRepository.save(comum);

        Pessoa pessoa = new Pessoa();
        pessoa.setCpf("12345678901");
        pessoa.setNome("Aluno Teste");
        pessoa.setComum(comum);
        pessoaRepository.save(pessoa);

        Aluno aluno = new Aluno();
        aluno.setSenha("hash-de-teste");
        aluno.setPessoa(pessoa);
        aluno.setComum(comum);
        return alunoRepository.save(aluno);
    }

    private Instrumento criarInstrumento(String nome) {
        Instrumento instrumento = new Instrumento();
        instrumento.setNome(nome);
        return instrumentoRepository.save(instrumento);
    }
}

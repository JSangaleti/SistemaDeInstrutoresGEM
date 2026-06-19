package com.gem.backend.config;

import com.gem.backend.repository.AdminRepository;
import com.gem.backend.repository.AlunoInstrumentoRepository;
import com.gem.backend.repository.AlunoMetodoRepository;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.ComumRepository;
import com.gem.backend.repository.InstrumentoRepository;
import com.gem.backend.repository.InstrutorRepository;
import com.gem.backend.repository.MetodoRepository;
import com.gem.backend.repository.PessoaRepository;
import com.gem.backend.repository.RegistroAulaRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
@ActiveProfiles("dev")
@Transactional
class DataSeederTest {

    @Autowired
    private DataSeeder dataSeeder;
    @Autowired
    private ComumRepository comumRepository;
    @Autowired
    private PessoaRepository pessoaRepository;
    @Autowired
    private AlunoRepository alunoRepository;
    @Autowired
    private InstrutorRepository instrutorRepository;
    @Autowired
    private AdminRepository adminRepository;
    @Autowired
    private InstrumentoRepository instrumentoRepository;
    @Autowired
    private MetodoRepository metodoRepository;
    @Autowired
    private AlunoInstrumentoRepository alunoInstrumentoRepository;
    @Autowired
    private AlunoMetodoRepository alunoMetodoRepository;
    @Autowired
    private RegistroAulaRepository registroAulaRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Test
    void deveCompletarDadosSemDuplicarAoExecutarNovamente() {
        dataSeeder.run();

        assertEquals(2, comumRepository.count());
        assertEquals(6, pessoaRepository.count());
        assertEquals(3, alunoRepository.count());
        assertEquals(2, instrutorRepository.count());
        assertEquals(1, adminRepository.count());
        assertEquals(3, instrumentoRepository.count());
        assertEquals(3, metodoRepository.count());
        assertEquals(4, alunoInstrumentoRepository.count());
        assertEquals(4, alunoMetodoRepository.count());
        assertEquals(3, registroAulaRepository.count());

        var aluno = alunoRepository.findByPessoa_Cpf("11111111111").orElseThrow();
        assertEquals(2, alunoInstrumentoRepository
                .findByAluno_IdOrderByInstrumento_NomeAsc(aluno.getId())
                .size());
        assertEquals(2, alunoMetodoRepository
                .findByAluno_IdOrderByMetodo_NomeAsc(aluno.getId())
                .size());

        var admin = adminRepository.findByPessoa_Cpf("00000000001").orElseThrow();
        assertTrue(passwordEncoder.matches("admin123", admin.getSenha()));
    }
}

package com.gem.backend.config;

import com.gem.backend.model.Admin;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.AlunoInstrumento;
import com.gem.backend.model.AlunoMetodo;
import com.gem.backend.model.Comum;
import com.gem.backend.model.Instrumento;
import com.gem.backend.model.Instrutor;
import com.gem.backend.model.Metodo;
import com.gem.backend.model.Pessoa;
import com.gem.backend.model.RegistroAula;
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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Component
@Profile("dev")
public class DataSeeder implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataSeeder.class);
    private static final String SENHA_USUARIO = "senha123";
    private static final String SENHA_ADMIN = "admin123";

    private final ComumRepository comumRepository;
    private final PessoaRepository pessoaRepository;
    private final AlunoRepository alunoRepository;
    private final AlunoInstrumentoRepository alunoInstrumentoRepository;
    private final AlunoMetodoRepository alunoMetodoRepository;
    private final AdminRepository adminRepository;
    private final InstrutorRepository instrutorRepository;
    private final InstrumentoRepository instrumentoRepository;
    private final MetodoRepository metodoRepository;
    private final RegistroAulaRepository registroAulaRepository;
    private final PasswordEncoder passwordEncoder;

    public DataSeeder(
            ComumRepository comumRepository,
            PessoaRepository pessoaRepository,
            AlunoRepository alunoRepository,
            AlunoInstrumentoRepository alunoInstrumentoRepository,
            AlunoMetodoRepository alunoMetodoRepository,
            AdminRepository adminRepository,
            InstrutorRepository instrutorRepository,
            InstrumentoRepository instrumentoRepository,
            MetodoRepository metodoRepository,
            RegistroAulaRepository registroAulaRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.comumRepository = comumRepository;
        this.pessoaRepository = pessoaRepository;
        this.alunoRepository = alunoRepository;
        this.alunoInstrumentoRepository = alunoInstrumentoRepository;
        this.alunoMetodoRepository = alunoMetodoRepository;
        this.adminRepository = adminRepository;
        this.instrutorRepository = instrutorRepository;
        this.instrumentoRepository = instrumentoRepository;
        this.metodoRepository = metodoRepository;
        this.registroAulaRepository = registroAulaRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(String... args) {
        logger.info("Verificando dados de desenvolvimento da seed...");

        Comum comumCentral = garantirComum(
                "Central",
                "Campo Mourão",
                "PR",
                "Centro",
                "Rua Brasil",
                "100"
        );
        Comum comumJardim = garantirComum(
                "Jardim Tropical",
                "Campo Mourão",
                "PR",
                "Jardim Tropical",
                "Avenida das Flores",
                "250"
        );

        Pessoa pessoaAluno1 = garantirPessoa("11111111111", "João da Silva", comumCentral);
        Pessoa pessoaAluno2 = garantirPessoa("22222222222", "Maria Oliveira", comumCentral);
        Pessoa pessoaAluno3 = garantirPessoa("33333333333", "Pedro Santos", comumJardim);
        Pessoa pessoaInstrutor1 = garantirPessoa("44444444444", "Carlos Instrutor", comumCentral);
        Pessoa pessoaInstrutor2 = garantirPessoa("55555555555", "Ana Instrutora", comumJardim);
        Pessoa pessoaAdmin = garantirPessoa("00000000001", "Administrador GEM", comumCentral);

        Aluno aluno1 = garantirAluno(pessoaAluno1, comumCentral);
        Aluno aluno2 = garantirAluno(pessoaAluno2, comumCentral);
        Aluno aluno3 = garantirAluno(pessoaAluno3, comumJardim);
        Instrutor instrutor1 = garantirInstrutor(pessoaInstrutor1);
        Instrutor instrutor2 = garantirInstrutor(pessoaInstrutor2);
        garantirAdmin(pessoaAdmin);

        Instrumento violino = garantirInstrumento("Violino");
        Instrumento trompete = garantirInstrumento("Trompete");
        Instrumento saxofone = garantirInstrumento("Saxofone");

        garantirAlunoInstrumento(aluno1, violino, true);
        garantirAlunoInstrumento(aluno1, saxofone, false);
        garantirAlunoInstrumento(aluno2, trompete, true);
        garantirAlunoInstrumento(aluno3, saxofone, true);

        Metodo metodoViolino = garantirMetodo("Método básico de violino", violino);
        Metodo metodoTrompete = garantirMetodo("Iniciação ao trompete", trompete);
        Metodo metodoSaxofone = garantirMetodo("Saxofone para iniciantes", saxofone);

        garantirAlunoMetodo(aluno1, metodoViolino);
        garantirAlunoMetodo(aluno1, metodoSaxofone);
        garantirAlunoMetodo(aluno2, metodoTrompete);
        garantirAlunoMetodo(aluno3, metodoSaxofone);

        garantirRegistroAula(
                aluno1,
                instrutor1,
                LocalDate.now().minusDays(7),
                "Primeira aula de violino: postura, empunhadura do arco e exercícios com cordas soltas.",
                "Treinar cordas soltas com arco inteiro e revisar postura diante do espelho."
        );
        garantirRegistroAula(
                aluno2,
                instrutor1,
                LocalDate.now().minusDays(5),
                "Primeira aula de trompete: respiração, embocadura e emissão das primeiras notas.",
                "Praticar notas longas com foco em estabilidade de som e respiração."
        );
        garantirRegistroAula(
                aluno3,
                instrutor2,
                LocalDate.now().minusDays(3),
                "Primeira aula de saxofone: montagem do instrumento, postura e emissão inicial do som.",
                "Praticar emissão de som com boquilha e palheta, mantendo coluna de ar constante."
        );

        logger.info("Seed de desenvolvimento verificada com sucesso.");
    }

    private Comum garantirComum(
            String nome,
            String cidade,
            String estado,
            String bairro,
            String logradouro,
            String numero
    ) {
        return comumRepository.findByNomeAndCidade(nome, cidade).orElseGet(() -> {
            Comum comum = new Comum();
            comum.setNome(nome);
            comum.setCidade(cidade);
            comum.setEstado(estado);
            comum.setBairro(bairro);
            comum.setLogradouro(logradouro);
            comum.setNumero(numero);
            return comumRepository.save(comum);
        });
    }

    private Pessoa garantirPessoa(String cpf, String nome, Comum comum) {
        return pessoaRepository.findById(cpf).orElseGet(() -> {
            Pessoa pessoa = new Pessoa();
            pessoa.setCpf(cpf);
            pessoa.setNome(nome);
            pessoa.setComum(comum);
            return pessoaRepository.save(pessoa);
        });
    }

    private Aluno garantirAluno(Pessoa pessoa, Comum comum) {
        return alunoRepository.findByPessoa_Cpf(pessoa.getCpf()).orElseGet(() -> {
            Aluno aluno = new Aluno();
            aluno.setSenha(passwordEncoder.encode(SENHA_USUARIO));
            aluno.setPessoa(pessoa);
            aluno.setComum(comum);
            return alunoRepository.save(aluno);
        });
    }

    private Instrutor garantirInstrutor(Pessoa pessoa) {
        return instrutorRepository.findByPessoa_Cpf(pessoa.getCpf()).orElseGet(() -> {
            Instrutor instrutor = new Instrutor();
            instrutor.setSenha(passwordEncoder.encode(SENHA_USUARIO));
            instrutor.setPessoa(pessoa);
            return instrutorRepository.save(instrutor);
        });
    }

    private void garantirAdmin(Pessoa pessoa) {
        adminRepository.findByPessoa_Cpf(pessoa.getCpf()).orElseGet(() -> {
            Admin admin = new Admin();
            admin.setSenha(passwordEncoder.encode(SENHA_ADMIN));
            admin.setPessoa(pessoa);
            return adminRepository.save(admin);
        });
    }

    private Instrumento garantirInstrumento(String nome) {
        return instrumentoRepository.findByNome(nome).orElseGet(() -> {
            Instrumento instrumento = new Instrumento();
            instrumento.setNome(nome);
            return instrumentoRepository.save(instrumento);
        });
    }

    private Metodo garantirMetodo(String nome, Instrumento instrumento) {
        return metodoRepository.findByNomeAndInstrumento_Id(nome, instrumento.getId()).orElseGet(() -> {
            Metodo metodo = new Metodo();
            metodo.setNome(nome);
            metodo.setInstrumento(instrumento);
            return metodoRepository.save(metodo);
        });
    }

    private void garantirAlunoInstrumento(Aluno aluno, Instrumento instrumento, boolean principalDesejado) {
        var vinculoExistente = alunoInstrumentoRepository
                .findByAluno_IdAndInstrumento_Id(aluno.getId(), instrumento.getId());

        if (vinculoExistente.isPresent()) {
            AlunoInstrumento vinculo = vinculoExistente.get();
            boolean semPrincipal = alunoInstrumentoRepository
                    .findByAluno_IdOrderByInstrumento_NomeAsc(aluno.getId())
                    .stream()
                    .noneMatch(item -> item.getEhInstrumentoPrincipal() == 1);
            if (principalDesejado && semPrincipal) {
                vinculo.setEhInstrumentoPrincipal((short) 1);
                alunoInstrumentoRepository.save(vinculo);
            }
            return;
        }

        boolean jaPossuiPrincipal = alunoInstrumentoRepository
                .findByAluno_IdOrderByInstrumento_NomeAsc(aluno.getId())
                .stream()
                .anyMatch(item -> item.getEhInstrumentoPrincipal() == 1);

        AlunoInstrumento vinculo = new AlunoInstrumento();
        vinculo.setAluno(aluno);
        vinculo.setInstrumento(instrumento);
        vinculo.setEhInstrumentoPrincipal(principalDesejado && !jaPossuiPrincipal ? (short) 1 : (short) 0);
        alunoInstrumentoRepository.save(vinculo);
    }

    private void garantirAlunoMetodo(Aluno aluno, Metodo metodo) {
        if (alunoMetodoRepository.existsByAluno_IdAndMetodo_Id(aluno.getId(), metodo.getId())) {
            return;
        }

        AlunoMetodo vinculo = new AlunoMetodo();
        vinculo.setAluno(aluno);
        vinculo.setMetodo(metodo);
        alunoMetodoRepository.save(vinculo);
    }

    private void garantirRegistroAula(
            Aluno aluno,
            Instrutor instrutor,
            LocalDate data,
            String descricao,
            String paraProximaAula
    ) {
        if (registroAulaRepository.existsByAluno_IdAndDescricao(aluno.getId(), descricao)) {
            return;
        }

        RegistroAula registro = new RegistroAula();
        registro.setAluno(aluno);
        registro.setInstrutor(instrutor);
        registro.setData(data);
        registro.setPresente((short) 1);
        registro.setDescricao(descricao);
        registro.setParaProximaAula(paraProximaAula);
        registroAulaRepository.save(registro);
    }
}

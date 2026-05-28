package com.gem.backend.config;

import com.gem.backend.model.Admin;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.Comum;
import com.gem.backend.model.Instrumento;
import com.gem.backend.model.Instrutor;
import com.gem.backend.model.Metodo;
import com.gem.backend.model.Pessoa;
import com.gem.backend.model.RegistroAula;
import com.gem.backend.repository.AdminRepository;
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
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import java.time.LocalDate;
import java.util.List;

@Configuration
@Profile("dev")
public class DataSeeder {

    private static final Logger logger = LoggerFactory.getLogger(DataSeeder.class);

    @Bean
    CommandLineRunner seedDatabase(
            ComumRepository comumRepository,
            PessoaRepository pessoaRepository,
            AlunoRepository alunoRepository,
            AdminRepository adminRepository,
            InstrutorRepository instrutorRepository,
            InstrumentoRepository instrumentoRepository,
            MetodoRepository metodoRepository,
            RegistroAulaRepository registroAulaRepository
    ) {
        return args -> {
            if (comumRepository.count() > 0
                    || pessoaRepository.count() > 0
                    || alunoRepository.count() > 0
                    || adminRepository.count() > 0
                    || instrutorRepository.count() > 0
                    || instrumentoRepository.count() > 0
                    || metodoRepository.count() > 0
                    || registroAulaRepository.count() > 0) {
                logger.info("Seed ignorada: banco já possui dados.");
                return;
            }

            Comum comumCentral = criarComum(
                    "Central",
                    "Campo Mourão",
                    "PR",
                    "Centro",
                    "Rua Brasil",
                    "100"
            );

            Comum comumJardim = criarComum(
                    "Jardim Tropical",
                    "Campo Mourão",
                    "PR",
                    "Jardim Tropical",
                    "Avenida das Flores",
                    "250"
            );

            comumRepository.saveAll(List.of(comumCentral, comumJardim));

            Pessoa pessoaAluno1 = criarPessoa("11111111111", "João da Silva", comumCentral);
            Pessoa pessoaAluno2 = criarPessoa("22222222222", "Maria Oliveira", comumCentral);
            Pessoa pessoaAluno3 = criarPessoa("33333333333", "Pedro Santos", comumJardim);

            Pessoa pessoaInstrutor1 = criarPessoa("44444444444", "Carlos Instrutor", comumCentral);
            Pessoa pessoaInstrutor2 = criarPessoa("55555555555", "Ana Instrutora", comumJardim);

            Pessoa pessoaAdmin = criarPessoa("00000000001", "Administrador GEM", comumCentral);

            pessoaRepository.saveAll(List.of(
                    pessoaAluno1,
                    pessoaAluno2,
                    pessoaAluno3,
                    pessoaInstrutor1,
                    pessoaInstrutor2,
                    pessoaAdmin
            ));

            Aluno aluno1 = criarAluno("$2a$12$M0cwptYjFvAN5icWicqIo.Ls4GjCpuPONrfJPEiwdPePjueM1X69q", pessoaAluno1, comumCentral);
            Aluno aluno2 = criarAluno("$2a$12$M0cwptYjFvAN5icWicqIo.Ls4GjCpuPONrfJPEiwdPePjueM1X69q", pessoaAluno2, comumCentral);
            Aluno aluno3 = criarAluno("$2a$12$M0cwptYjFvAN5icWicqIo.Ls4GjCpuPONrfJPEiwdPePjueM1X69q", pessoaAluno3, comumJardim);

            alunoRepository.saveAll(List.of(aluno1, aluno2, aluno3));

            Instrutor instrutor1 = criarInstrutor("$2a$12$M0cwptYjFvAN5icWicqIo.Ls4GjCpuPONrfJPEiwdPePjueM1X69q", pessoaInstrutor1);
            Instrutor instrutor2 = criarInstrutor("$2a$12$M0cwptYjFvAN5icWicqIo.Ls4GjCpuPONrfJPEiwdPePjueM1X69q", pessoaInstrutor2);

            instrutorRepository.saveAll(List.of(instrutor1, instrutor2));

            Admin admin = criarAdmin("$2a$12$klTvMCuhc40EUESyz0MM6uIgSfzIMyk/K3Ff592DEsj52cfGZbgPi", pessoaAdmin);

            adminRepository.save(admin);

            Instrumento violino = criarInstrumento("Violino");
            Instrumento trompete = criarInstrumento("Trompete");
            Instrumento saxofone = criarInstrumento("Saxofone");

            instrumentoRepository.saveAll(List.of(
                    violino,
                    trompete,
                    saxofone
            ));

            Metodo metodoViolinoAluno1 = criarMetodo(
                    "Método básico de violino",
                    violino,
                    aluno1
            );

            Metodo metodoTrompeteAluno2 = criarMetodo(
                    "Iniciação ao trompete",
                    trompete,
                    aluno2
            );

            Metodo metodoSaxofoneAluno3 = criarMetodo(
                    "Saxofone para iniciantes",
                    saxofone,
                    aluno3
            );

            metodoRepository.saveAll(List.of(
                    metodoViolinoAluno1,
                    metodoTrompeteAluno2,
                    metodoSaxofoneAluno3
            ));

            RegistroAula aula1 = criarRegistroAula(
                    aluno1,
                    instrutor1,
                    LocalDate.now().minusDays(7),
                    (short) 1,
                    "Primeira aula de violino: postura, empunhadura do arco e exercícios com cordas soltas.",
                    "Treinar cordas soltas com arco inteiro e revisar postura diante do espelho."
            );

            RegistroAula aula2 = criarRegistroAula(
                    aluno2,
                    instrutor1,
                    LocalDate.now().minusDays(5),
                    (short) 1,
                    "Primeira aula de trompete: respiração, embocadura e emissão das primeiras notas.",
                    "Praticar notas longas com foco em estabilidade de som e respiração."
            );

            RegistroAula aula3 = criarRegistroAula(
                    aluno3,
                    instrutor2,
                    LocalDate.now().minusDays(3),
                    (short) 1,
                    "Primeira aula de saxofone: montagem do instrumento, postura e emissão inicial do som.",
                    "Praticar emissão de som com boquilha e palheta, mantendo coluna de ar constante."
            );

            registroAulaRepository.saveAll(List.of(
                    aula1,
                    aula2,
                    aula3
            ));

            logger.info("Seed executada com sucesso.");
        };
    }

    private Comum criarComum(
            String nome,
            String cidade,
            String estado,
            String bairro,
            String logradouro,
            String numero
    ) {
        Comum comum = new Comum();
        comum.setNome(nome);
        comum.setCidade(cidade);
        comum.setEstado(estado);
        comum.setBairro(bairro);
        comum.setLogradouro(logradouro);
        comum.setNumero(numero);
        return comum;
    }

    private Pessoa criarPessoa(String cpf, String nome, Comum comum) {
        Pessoa pessoa = new Pessoa();
        pessoa.setCpf(cpf);
        pessoa.setNome(nome);
        pessoa.setComum(comum);
        return pessoa;
    }

    private Aluno criarAluno(String senha, Pessoa pessoa, Comum comum) {
        Aluno aluno = new Aluno();
        aluno.setSenha(senha);
        aluno.setPessoa(pessoa);
        aluno.setComum(comum);
        return aluno;
    }

    private Instrutor criarInstrutor(String senha, Pessoa pessoa) {
        Instrutor instrutor = new Instrutor();
        instrutor.setSenha(senha);
        instrutor.setPessoa(pessoa);
        return instrutor;
    }

    private Admin criarAdmin(String senha, Pessoa pessoa) {
        Admin admin = new Admin();
        admin.setSenha(senha);
        admin.setPessoa(pessoa);
        return admin;
    }

    private Instrumento criarInstrumento(String nome) {
        Instrumento instrumento = new Instrumento();
        instrumento.setNome(nome);
        return instrumento;
    }

    private Metodo criarMetodo(String nome, Instrumento instrumento, Aluno aluno) {
        Metodo metodo = new Metodo();
        metodo.setNome(nome);
        metodo.setInstrumento(instrumento);
        metodo.setAluno(aluno);
        return metodo;
    }

    private RegistroAula criarRegistroAula(
            Aluno aluno,
            Instrutor instrutor,
            LocalDate data,
            Short presente,
            String descricao,
            String paraProximaAula
    ) {
        RegistroAula registroAula = new RegistroAula();
        registroAula.setAluno(aluno);
        registroAula.setInstrutor(instrutor);
        registroAula.setData(data);
        registroAula.setPresente(presente);
        registroAula.setDescricao(descricao);
        registroAula.setParaProximaAula(paraProximaAula);
        return registroAula;
    }
}

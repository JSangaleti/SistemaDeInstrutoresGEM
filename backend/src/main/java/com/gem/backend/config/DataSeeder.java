package com.gem.backend.config;

import com.gem.backend.model.Admin;
import com.gem.backend.model.Aluno;
import com.gem.backend.model.Comum;
import com.gem.backend.model.Pessoa;
import com.gem.backend.repository.AdminRepository;
import com.gem.backend.repository.AlunoRepository;
import com.gem.backend.repository.ComumRepository;
import com.gem.backend.repository.PessoaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

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
            AdminRepository adminRepository
    ) {
        return args -> {
            if (comumRepository.count() > 0 || pessoaRepository.count() > 0 || alunoRepository.count() > 0 || adminRepository.count() > 0) {
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

            Pessoa pessoa1 = criarPessoa("11111111111", "João da Silva", comumCentral);
            Pessoa pessoa2 = criarPessoa("22222222222", "Maria Oliveira", comumCentral);
            Pessoa pessoa3 = criarPessoa("33333333333", "Pedro Santos", comumJardim);
            Pessoa pessoaAdmin = criarPessoa("00000000001", "Administrador GEM", comumCentral);

            pessoaRepository.saveAll(List.of(pessoa1, pessoa2, pessoa3, pessoaAdmin));

            Aluno aluno1 = criarAluno("senha123", pessoa1, comumCentral);
            Aluno aluno2 = criarAluno("senha123", pessoa2, comumCentral);
            Aluno aluno3 = criarAluno("senha123", pessoa3, comumJardim);

            Admin admin = criarAdmin("admin123", pessoaAdmin);

            adminRepository.save(admin);

            alunoRepository.saveAll(List.of(aluno1, aluno2, aluno3));

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

    private Admin criarAdmin(String senha, Pessoa pessoa) {
        Admin admin = new Admin();
        admin.setSenha(senha);
        admin.setPessoa(pessoa);
        return admin;
    }
}

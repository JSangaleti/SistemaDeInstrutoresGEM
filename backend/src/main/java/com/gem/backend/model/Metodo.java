package com.gem.backend.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Entity
@Table(name = "metodos")
public class Metodo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank(message = "Nome do método é obrigatório.")
    @Size(max = 64, message = "Nome do método deve ter no máximo 64 caracteres.")
    @Column(nullable = false, length = 64)
    private String nome;

    @NotNull(message = "Instrumento é obrigatório.")
    @ManyToOne
    @JoinColumn(name = "instrumento_id", nullable = false)
    private Instrumento instrumento;

    @ManyToOne
    @JoinColumn(name = "aluno_id")
    private Aluno aluno;

    public Metodo() {
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public Instrumento getInstrumento() {
        return instrumento;
    }

    public void setInstrumento(Instrumento instrumento) {
        this.instrumento = instrumento;
    }

    public Aluno getAluno() {
        return aluno;
    }

    public void setAluno(Aluno aluno) {
        this.aluno = aluno;
    }
}

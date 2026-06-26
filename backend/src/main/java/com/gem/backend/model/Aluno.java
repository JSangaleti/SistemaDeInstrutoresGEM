/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.gem.backend.model;

/**
 *
 * @author leonardo
 */
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import com.gem.backend.validation.ValidationGroups;

@Entity
@Table(name = "aluno")
public class Aluno {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Senha é obrigatória.", groups = ValidationGroups.Create.class)
    @Size(max = 255, message = "Senha deve ter no máximo 255 caracteres.")
    @Column(nullable = false, length = 255)
    private String senha;

    @NotNull(message = "Pessoa é obrigatória.")
    @OneToOne
    @JoinColumn(
            name = "pessoa_cpf",
            referencedColumnName = "cpf",
            nullable = false,
            unique = true
    )
    private Pessoa pessoa;

    @ManyToOne
    @JoinColumn(name = "comum_id", referencedColumnName = "id")
    private Comum comum;

    public Aluno() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public Pessoa getPessoa() {
        return pessoa;
    }

    public void setPessoa(Pessoa pessoa) {
        this.pessoa = pessoa;
    }

    public Comum getComum() {
        return comum;
    }

    public void setComum(Comum comum) {
        this.comum = comum;
    }
}

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
import jakarta.validation.constraints.Pattern;

@Entity
@Table(name = "pessoa")
public class Pessoa {

    @Id
    @NotBlank(message = "CPF é obrigatório.")
    @Pattern(regexp = "\\d{11}", message = "CPF deve conter exatamente 11 dígitos numéricos.")
    @Column(length = 11, nullable = false)
    private String cpf;

    @NotBlank(message = "Nome é obrigatório.")
    @Size(max = 64, message = "Nome deve ter no máximo 64 caracteres.")
    @Column(length = 64, nullable = false)
    private String nome;

    @NotNull(message = "Comum é obrigatória.")
    @ManyToOne
    @JoinColumn(name = "id_comum", referencedColumnName = "id", nullable = false)
    private Comum comum;

    public Pessoa() {
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public Comum getComum() {
        return comum;
    }

    public void setComum(Comum comum) {
        this.comum = comum;
    }
}

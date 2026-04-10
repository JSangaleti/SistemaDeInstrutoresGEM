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

@Entity
@Table(name = "aluno")
public class Aluno {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 16)
    private String senha;

    @Column(name = "cpf_pessoa", nullable = false, length = 11, unique = true)
    private String cpfPessoa;

    public Aluno() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }

    public String getCpfPessoa() { return cpfPessoa; }
    public void setCpfPessoa(String cpfPessoa) { this.cpfPessoa = cpfPessoa; }
}

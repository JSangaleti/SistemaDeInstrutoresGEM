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
import java.util.List;

@Entity
@Table(name = "instrutores")
public class Instrutor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(length = 16, nullable = false)
    private String senha;

    @OneToOne
    @JoinColumn(name = "pessoa_cpf", referencedColumnName = "cpf")
    private Pessoa pessoa;

    @OneToMany(mappedBy = "instrutor")
    private List<RegistroAula> aulas;

    public Instrutor() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }

    public Pessoa getPessoa() { return pessoa; }
    public void setPessoa(Pessoa pessoa) { this.pessoa = pessoa; }

    public List<RegistroAula> getAulas() { return aulas; }
    public void setAulas(List<RegistroAula> aulas) { this.aulas = aulas; }
}

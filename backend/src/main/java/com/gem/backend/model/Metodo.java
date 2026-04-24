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
@Table(name = "metodos")
public class Metodo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 64) // Corrigido de smallint para String
    private String nome;

    @ManyToOne
    @JoinColumn(name = "instrumento_id")
    private Instrumento instrumento;

    @ManyToOne
    @JoinColumn(name = "aluno_id")
    private Aluno aluno;

    public Metodo() {}

    // Getters e Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public Instrumento getInstrumento() { return instrumento; }
    public void setInstrumento(Instrumento instrumento) { this.instrumento = instrumento; }

    public Aluno getAluno() { return aluno; }
    public void setAluno(Aluno aluno) { this.aluno = aluno; }
}
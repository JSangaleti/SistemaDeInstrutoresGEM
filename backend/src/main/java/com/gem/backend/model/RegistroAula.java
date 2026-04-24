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
import java.time.LocalDate;

@Entity
@Table(name = "registro_aulas")
public class RegistroAula {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "aluno_id")
    private Aluno aluno;

    @ManyToOne
    @JoinColumn(name = "instrutor_id")
    private Instrutor instrutor;

    @Column(nullable = false)
    private LocalDate data;

    private Short presente;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;

    @Column(name = "para_proxima_aula", columnDefinition = "TEXT")
    private String paraProximaAula;

    public RegistroAula() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Aluno getAluno() { return aluno; }
    public void setAluno(Aluno aluno) { this.aluno = aluno; }

    public Instrutor getInstrutor() { return instrutor; }
    public void setInstrutor(Instrutor instrutor) { this.instrutor = instrutor; }

    public LocalDate getData() { return data; }
    public void setData(LocalDate data) { this.data = data; }

    public Short getPresente() { return presente; }
    public void setPresente(Short presente) { this.presente = presente; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }

    public String getParaProximaAula() { return paraProximaAula; }
    public void setParaProximaAula(String paraProximaAula) { this.paraProximaAula = paraProximaAula; }
}
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
@Table(name = "alunos_has_instrumentos")
public class AlunoInstrumento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "aluno_id")
    private Aluno aluno;

    @ManyToOne
    @JoinColumn(name = "instrumento_id")
    private Instrumento instrumento;

    @Column(name = "eh_instrumento_principal")
    private Short ehInstrumentoPrincipal;

    public AlunoInstrumento() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Aluno getAluno() { return aluno; }
    public void setAluno(Aluno aluno) { this.aluno = aluno; }

    public Instrumento getInstrumento() { return instrumento; }
    public void setInstrumento(Instrumento instrumento) { this.instrumento = instrumento; }

    public Short getEhInstrumentoPrincipal() { return ehInstrumentoPrincipal; }
    public void setEhInstrumentoPrincipal(Short ehInstrumentoPrincipal) { this.ehInstrumentoPrincipal = ehInstrumentoPrincipal; }
}
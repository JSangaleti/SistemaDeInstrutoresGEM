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
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

@Entity
@Table(name = "instrutores_has_instrumentos")
public class InstrutorInstrumento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotNull(message = "Instrutor é obrigatório.")
    @ManyToOne
    @JoinColumn(name = "instrutor_id")
    private Instrutor instrutor;

    @NotNull(message = "Instrumento é obrigatório.")
    @ManyToOne
    @JoinColumn(name = "instrumento_id")
    private Instrumento instrumento;

    @NotNull(message = "Informe se é o instrumento principal.")
    @Min(value = 0, message = "Instrumento principal deve ser 0 ou 1.")
    @Max(value = 1, message = "Instrumento principal deve ser 0 ou 1.")
    @Column(name = "eh_instrumento_principal")
    private Short ehInstrumentoPrincipal;

    public InstrutorInstrumento() {
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Instrutor getInstrutor() {
        return instrutor;
    }

    public void setInstrutor(Instrutor instrutor) {
        this.instrutor = instrutor;
    }

    public Instrumento getInstrumento() {
        return instrumento;
    }

    public void setInstrumento(Instrumento instrumento) {
        this.instrumento = instrumento;
    }

    public Short getEhInstrumentoPrincipal() {
        return ehInstrumentoPrincipal;
    }

    public void setEhInstrumentoPrincipal(Short ehInstrumentoPrincipal) {
        this.ehInstrumentoPrincipal = ehInstrumentoPrincipal;
    }
}

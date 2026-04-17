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
@Table(name = "pessoa")
public class Pessoa {

    @Id
    @Column(length = 11, nullable = false)
    private String cpf;

    @Column(length = 64, nullable = false)
    private String nome;

    @ManyToOne
    @JoinColumn(name = "id_comum", referencedColumnName = "id")
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

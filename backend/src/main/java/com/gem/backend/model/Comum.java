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
import jakarta.validation.constraints.Size;

@Entity
@Table(name = "comum")
public class Comum {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank(message = "Nome da comum é obrigatório.")
    @Size(max = 32, message = "Nome da comum deve ter no máximo 32 caracteres.")
    @Column(length = 32, nullable = false)
    private String nome;

    @Size(max = 32, message = "Cidade deve ter no máximo 32 caracteres.")
    @Column(length = 32)
    private String cidade;

    @Size(max = 2, message = "Estado deve ter no máximo 2 caracteres.")
    @Column(length = 2)
    private String estado;

    @Size(max = 32, message = "Bairro deve ter no máximo 32 caracteres.")
    @Column(length = 32)
    private String bairro;

    @Size(max = 32, message = "Logradouro deve ter no máximo 32 caracteres.")
    @Column(length = 32)
    private String logradouro;

    @Size(max = 8, message = "Número deve ter no máximo 8 caracteres.")
    @Column(length = 8)
    private String numero;

    public Comum() {
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

    public String getCidade() {
        return cidade;
    }

    public void setCidade(String cidade) {
        this.cidade = cidade;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getBairro() {
        return bairro;
    }

    public void setBairro(String bairro) {
        this.bairro = bairro;
    }

    public String getLogradouro() {
        return logradouro;
    }

    public void setLogradouro(String logradouro) {
        this.logradouro = logradouro;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }
}

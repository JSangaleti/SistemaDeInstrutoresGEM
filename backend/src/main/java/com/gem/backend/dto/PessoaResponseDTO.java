package com.gem.backend.dto;

import com.gem.backend.model.Pessoa;

public record PessoaResponseDTO(
        String cpf,
        String nome,
        Integer comumId,
        String comumNome,
        String comumCidade,
        String comumUF
        ) {

    public PessoaResponseDTO(Pessoa pessoa) {
        this(
                pessoa.getCpf(),
                pessoa.getNome(),
                pessoa.getComum() != null ? pessoa.getComum().getId() : null,
                pessoa.getComum() != null ? pessoa.getComum().getNome() : "",
                pessoa.getComum() != null ? pessoa.getComum().getCidade() : "",
                pessoa.getComum() != null ? pessoa.getComum().getEstado() : ""
        );
    }
}

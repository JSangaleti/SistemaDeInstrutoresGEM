package com.gem.backend.dto;

import com.gem.backend.model.Admin;

public record AdminResponseDTO(Integer id, String cpf, String nome, String comum) {

    public AdminResponseDTO(Admin admin) {
        this(
                admin.getId(),
                admin.getPessoa() != null ? admin.getPessoa().getCpf() : null,
                admin.getPessoa() != null ? admin.getPessoa().getNome() : null,
                admin.getPessoa() != null && admin.getPessoa().getComum() != null
                ? admin.getPessoa().getComum().getNome()
                : null
        );
    }
}

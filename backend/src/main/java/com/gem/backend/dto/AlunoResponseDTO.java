package com.gem.backend.dto;

import com.gem.backend.model.Aluno;
import com.gem.backend.model.Comum;

public record AlunoResponseDTO(
        Long id,
        String cpf,
        String nome,
        Integer comumId,
        String comumNome,
        String comumCidade,
        String comumUF
) {
    public AlunoResponseDTO(Aluno aluno) {
        this(
                aluno.getId(),
                aluno.getPessoa() != null ? aluno.getPessoa().getCpf() : null,
                aluno.getPessoa() != null ? aluno.getPessoa().getNome() : "",
                getComum(aluno) != null ? getComum(aluno).getId() : null,
                getComum(aluno) != null ? getComum(aluno).getNome() : "",
                getComum(aluno) != null ? getComum(aluno).getCidade() : "",
                getComum(aluno) != null ? getComum(aluno).getEstado() : ""
        );
    }

    private static Comum getComum(Aluno aluno) {
        if (aluno.getComum() != null) {
            return aluno.getComum();
        }

        if (aluno.getPessoa() != null && aluno.getPessoa().getComum() != null) {
            return aluno.getPessoa().getComum();
        }

        return null;
    }
}
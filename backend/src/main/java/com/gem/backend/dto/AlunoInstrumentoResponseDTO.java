package com.gem.backend.dto;

import com.gem.backend.model.AlunoInstrumento;

public record AlunoInstrumentoResponseDTO(Integer id, String nome, boolean principal) {

    public AlunoInstrumentoResponseDTO(AlunoInstrumento alunoInstrumento) {
        this(
                alunoInstrumento.getInstrumento().getId(),
                alunoInstrumento.getInstrumento().getNome(),
                alunoInstrumento.getEhInstrumentoPrincipal() == 1
        );
    }
}

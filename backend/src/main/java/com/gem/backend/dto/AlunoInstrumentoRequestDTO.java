package com.gem.backend.dto;

import jakarta.validation.constraints.NotNull;

public record AlunoInstrumentoRequestDTO(
        @NotNull(message = "Informe o ID do instrumento.") Integer instrumentoId,
        @NotNull(message = "Informe se o instrumento é o principal.") Boolean principal
) {
}

package com.gem.backend.dto;

import com.gem.backend.model.Comum;
import com.gem.backend.model.Pessoa;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record AlunoRequestDTO(
        @Size(max = 255, message = "Senha deve ter no máximo 255 caracteres.") String senha,
        Pessoa pessoa,
        Comum comum,
        List<@NotNull(message = "Informe um instrumento válido.") @Valid AlunoInstrumentoRequestDTO> instrumentos,
        List<Integer> metodoIds
) {
}

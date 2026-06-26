package com.gem.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AlterarSenhaRequestDTO(
        @NotBlank(message = "Senha antiga é obrigatória.")
        String senhaAntiga,

        @NotBlank(message = "Nova senha é obrigatória.")
        @Size(max = 255, message = "Nova senha deve ter no máximo 255 caracteres.")
        String novaSenha,

        @NotBlank(message = "Confirmação da nova senha é obrigatória.")
        String confirmacaoNovaSenha
) {
}

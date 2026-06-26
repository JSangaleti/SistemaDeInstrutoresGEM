package com.gem.backend.dto;

import com.gem.backend.enums.Perfil;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record AdminAlterarSenhaRequestDTO(
        @NotNull(message = "Perfil é obrigatório.")
        Perfil perfil,

        @NotNull(message = "ID do usuário é obrigatório.")
        Long usuarioId,

        @NotBlank(message = "Nova senha é obrigatória.")
        @Size(max = 255, message = "Nova senha deve ter no máximo 255 caracteres.")
        String novaSenha,

        @NotBlank(message = "Confirmação da nova senha é obrigatória.")
        String confirmacaoNovaSenha
) {
}
